// (c) 1994 Michael E. Stillman
#ifndef _assprime_hh
#define _assprime_hh

#include "monideal.hpp"

class AssociatedPrimes
    // A class which enables one to compute the codimension and 
    // associated primes of minimal codimension, of a monomial ideal.
{
  enum { do_codim, do_primes } state;
  int min_codim;
  int nvars;

  MonomialIdeal mi;			// A radical monomial ideal

  MonomialIdeal ass_primes;		// Assoc. primes of minimal codim, stored
				// in a monideal, where each monomial
				// corresponds to a prime monomial ideal
				// whose generators are the variables occuring
				// in the monomial.

  intarray exps;

  void ass_prime_generator(Nmi_node *p, const int *exp, int codim);

public:
  AssociatedPrimes(const MonomialIdeal &mi);
  AssociatedPrimes(const MonomialIdeal &mi, int codim);

  int codimension();
  MonomialIdeal associated_primes();
};

#endif
