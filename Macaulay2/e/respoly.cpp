// Copyright 1996 Michael E. Stillman

#include "respoly.hpp"
#include "text_io.hpp"
#include "polyring.hpp"
#include "freemod.hpp"

res_poly::res_poly(PolynomialRing *RR)
: R(RR), M(R->Nmonoms()), K(R->Ncoeffs())
{
  bump_up(K);
  bump_up(R);

  pstash = R->resstash;
}

res_poly::~res_poly()
{
  bump_down(R);
  bump_down(K);
}

inline int res_poly::compare(const resterm *a, const resterm *b) const
{
  int cmp = M->compare(a->monom, b->monom);
  if (cmp != 0) return cmp;
  cmp = a->comp->compare_num - b->comp->compare_num;
  if (cmp > 0) return 1;
  if (cmp < 0) return -1;
  return 0;
}

resterm *res_poly::new_term() const
{
  resterm *result = (resterm *) pstash->new_elem();
  result->next = NULL;
  return result;
}
resterm *res_poly::new_term(ring_elem c, const int *m, res_pair *x) const
    // Note: this does NOT copy 'c'
{
  resterm *result = new_term();
  result->coeff = c;
  M->copy(m, result->monom);
  result->comp = x;
  return result;
}

resterm *res_poly::mult_by_monomial(const resterm *f, const int *m) const
{
  resterm head;
  resterm *result = &head;
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    {
      result->next = new_term();
      result = result->next;
      result->comp = tm->comp;
      result->coeff = K->copy(tm->coeff);
      M->mult(tm->monom, m, result->monom);
    }
  result->next = NULL;
  return head.next;
}

resterm *res_poly::copy(const resterm *f) const
{
  resterm head;
  resterm *result = &head;
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    {
      result->next = new_term();
      result = result->next;
      result->comp = tm->comp;
      result->coeff = K->copy(tm->coeff);
      M->copy(tm->monom, result->monom);
    }
  result->next = NULL;
  return head.next;
}
void res_poly::remove(resterm *&f) const
{
  while (f != NULL)
    {
      resterm *tmp = f;
      f = f->next;
      K->remove(tmp->coeff);
      pstash->delete_elem(tmp);
    }
}

resterm *res_poly::mult_by_term(const resterm *f, ring_elem c, const int *m) const
{
  resterm head;
  resterm *result = &head;
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    {
      result->next = new_term();
      result = result->next;
      result->comp = tm->comp;
      result->coeff = K->mult(c, tm->coeff);
      M->mult(tm->monom, m, result->monom);
    }
  result->next = NULL;
  return head.next;
}
resterm *res_poly::ring_mult_by_term(const ring_elem f, 
				     ring_elem c, const int *m, res_pair *x) const
{
  resterm head;
  resterm *result = &head;
  for (const Nterm *tm = f; tm != NULL; tm = tm->next)
    {
      result->next = new_term();
      result = result->next;
      result->comp = x;
      result->coeff = K->mult(c, tm->coeff);
      M->mult(tm->monom, m, result->monom);
    }
  result->next = NULL;
  return head.next;
}

void res_poly::make_monic(resterm *&f) const
{
  if (f == NULL) return;
  ring_elem c_inv = K->invert(f->coeff);

  for (resterm *tm = f; tm != NULL; tm = tm->next)
    K->mult_to(tm->coeff, c_inv);

  K->remove(c_inv);
}


void res_poly::add_to(resterm * &f, resterm * &g) const
{
  if (g == NULL) return;
  if (f == NULL) { f = g; g = NULL; return; }
  resterm head;
  resterm *result = &head;
  while (1)
    switch (compare(f, g))
      {
      case -1:
	result->next = g;
	result = result->next;
	g = g->next;
	if (g == NULL) 
	  {
	    result->next = f; 
	    f = head.next;
	    return;
	  }
	break;
      case 1:
	result->next = f;
	result = result->next;
	f = f->next;
	if (f == NULL) 
	  {
	    result->next = g; 
	    f = head.next;
	    g = NULL;
	    return;
	  }
	break;
      case 0:
	resterm *tmf = f;
	resterm *tmg = g;
	f = f->next;
	g = g->next;
	K->add_to(tmf->coeff, tmg->coeff);
	if (K->is_zero(tmf->coeff))
	  pstash->delete_elem(tmf);
	else
	  {
	    result->next = tmf;
	    result = result->next;
	  }
	pstash->delete_elem(tmg);
	if (g == NULL) 
	  {
	    result->next = f; 
	    f = head.next;
	    return;
	  }
	if (f == NULL) 
	  {
	    result->next = g; 
	    f = head.next;
	    g = NULL;
	    return;
	  }
	break;
      }
}

void res_poly::subtract_multiple_to(resterm *& f, ring_elem c, 
				    const int *m, const resterm *g) const
    // f := f - c * m * g
{
  ring_elem minus_c = K->negate(c);
  resterm *h = mult_by_term(g, minus_c, m);
  add_to(f, h);
  K->remove(minus_c);
}
void res_poly::ring_subtract_multiple_to(resterm *& f, ring_elem c, 
					 const int *m, res_pair *x, const ring_elem g) const
    // f := f - c * m * g * x, where g is a ring element
{
  ring_elem minus_c = K->negate(c);
  resterm *h = ring_mult_by_term(g, minus_c, m, x);
  add_to(f, h);
  K->remove(minus_c);
}

int res_poly::n_terms(const resterm *f) const
{
  int result = 0;
  for ( ; f != NULL; f = f->next)
    result++;
  return result;
}

void res_poly::elem_text_out(const resterm *f) const
{
  if (f == NULL)
    {
      cerr << "0";
      return;
    }

  int old_one = p_one;
  int old_parens = p_parens;
  int old_plus = p_plus;

  p_one = 0;
  p_parens = 1;
  p_plus = 0;
  for (const resterm *t = f; t != NULL; t = t->next)
    {
      int isone = M->is_one(t->monom);
      K->elem_text_out(cerr,t->coeff);
      if (!isone)
	M->elem_text_out(cerr, t->monom);
      cerr << "<" << t->comp->me << ">";
      p_plus = 1;
    }

  p_one = old_one;
  p_parens = old_parens;
  p_plus = old_plus;
}

vec res_poly::to_vector(const resterm *f, const FreeModule *F, 
			    int /*to_minimal*/) const
{
  vecterm *result = NULL;
  int *mon = M->make_one();
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    {
//    int x = (to_minimal ? tm->comp->minimal_me : tm->comp->me);
      int x = tm->comp->minimal_me; // MES: Currently used for non-minimal as well...
      M->divide(tm->monom, tm->comp->base_monom, mon);
      vecterm *tmp = F->term(x, K->copy(tm->coeff), mon);
      M->mult(tmp->monom, F->base_monom(x), tmp->monom);
      tmp->next = result;
      result = tmp;
    }
  F->sort(result);
  M->remove(mon);
  return result;
}

resterm *res_poly::from_vector(const array<res_pair *> &base, const vec v) const
{
  // The 'base' and the freemodule of 'v' are assumed to be the same: same monomial order,
  // same Schreyer monomials, etc.

  resterm head;
  resterm *result = &head;
  for (vecterm *t = v; t != NULL; t = t->next)
    {
      result->next = new_term();
      result = result->next;
      result->comp = base[t->comp];
      result->coeff = K->copy(t->coeff);
      M->copy(t->monom, result->monom);
    }
  result->next = NULL;
  return head.next;
}

resterm *res_poly::strip(const resterm *f) const
{
  resterm head;
  resterm *result = &head;
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    if (tm->comp->syz_type != SYZ_NOT_MINIMAL)
      {
	result->next = new_term();
	result = result->next;
	result->comp = tm->comp;
	result->coeff = K->copy(tm->coeff);
	M->copy(tm->monom, result->monom);
      }
  result->next = NULL;
  return head.next;
}

const resterm *res_poly::component_occurs_in(const res_pair *x, 
					  const resterm *f) const
{
  for (const resterm *tm = f; tm != NULL; tm = tm->next)
    if (tm->comp == x) return tm;
  return NULL;
}
