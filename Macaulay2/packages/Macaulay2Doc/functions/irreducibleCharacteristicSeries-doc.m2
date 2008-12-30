--- status: Draft
--- author(s): Decker
--- notes: 

document { 
     Key => {irreducibleCharacteristicSeries,(irreducibleCharacteristicSeries,Ideal)},
     Headline => "irreducible characteristic series of an ideal",
     Usage => "(ics,p) = irreducibleCharacteristicSeries I",
     Inputs => {"I" => Ideal },
     Outputs => {
	  "ics" => List => {"a list of matrices, representing an irreducible characteristic series for ", TT "I"},
	  "p" => RingMap => {"an isomorphism from the ring of ", TT "I", " to the ring of the characteristic series.
	       The ring retains the names and degrees of the variables, but reorders the variables and uses a
	       default monomial ordering."
	       }
	  },
     PARA {
	  TEX ///
	  As we see in the example below, an irreducible characteristic series
	  for $I$ consists of a collection of triangular sets. Here,
	  given a polynomial $f$,  write $lvar(f)$ for the 
	  largest variable appearing in $f$ (with respect to the lexicographic order).
	  In the example, $lvar(-w*y+z^2) = w$ . A triangular set consists
	  of polynomials $f_1,\dots,f_r$ such that $lvar(f_1)< \dots < lvar(f_r)$.
	  In the example, $lvar(-x*y^2+z^3) =x < w = lvar(-w*y+z^2)$ . If 
	  $T_1,\dots,T_s$ form an irreducible characteristic series for $I$ , and if
	  $J_i$ is the ideal generated by the largest variables of the
	  elements of $T_i$ , then the algebraic set $V(I)$ 
	  defined by $I$ is the union of the sets $V(T_i) \setminus V(I_i)$, for $i=1,\dots,s$.
	  The minimal associated primes of $I$ can thus be recovered from the
	  irreducible characteristic series by saturation and by throwing away superfluous primes.
	  ///,
	  "This is done by ", TO "minimalPrimes", ", which uses this routine."
     	  },	    
     EXAMPLE lines ///
     R = QQ[w,x,y,z];
     (L,p) = irreducibleCharacteristicSeries ideal(x^2-y*w,x^3-z*w^2)
     apply(L, m -> p m)
     p^-1
     ///,
     SeeAlso => {minimalPrimes}
     }

TEST ///
R = QQ[w,x,y,z];
(L,p) = irreducibleCharacteristicSeries ideal(x^2-y*w,x^3-z*w^2)
n = apply(L, m -> p m)
assert( n === {matrix {{x^3-w^2*z, x^2-w*y}}, matrix {{x, w}}} )
///
