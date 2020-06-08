simpleDocFrob = method()
simpleDocFrob(ZZ, Matrix) := (n, M) -> directSum(n:M)

docExample = "doc ///
  Key
    simpleDocFrob
    (simpleDocFrob,ZZ,Matrix)
  Headline
    a sample documentation node
  Usage
    x = simpleDocFrob(n,M)
  Inputs
    n:ZZ
      positive
    M:Matrix
      which is square
  Outputs
    x:Matrix
      A block diagonal matrix with {\\tt n}
      copies of {\\tt M} along the diagonal
  Consequences
   Item
    The first side effect of the function, if any, is described here.
   Item
    The second side effect of the function is described here, and so on.
  Description
   Text
     Each paragraph of text begins with \"Text\".  The following
     line starts a sequence of Macaulay2 example input lines.
     However, see @TO (matrix,List)@.

     The output in the following example was automatically generated at the time
     of package installation.
   Example
     M = matrix\"1,2;3,4\";
     simpleDocFrob(3,M)
   Text
     The following example was generated by the documentation author.
   CannedExample
      i1 : 4+
           4

      o1 = 8

      i1000 = 2+2

      o1000 = 4
   Text
     See @ TO \"docExample\" @ for the code used to create this documentation.
  Acknowledgement
    Acknowledge funding sources or collaborators here.
  Contributors
    Acknowledge contributors who are not listed as authors here.
  References
    Provide references for further reading.
  Caveat
    This is not a particularly useful function.
  SeeAlso
    matrix
    (directSum,List)
///"

testExample = "TEST /// -* test for simpleDocFrob *-
  assert(simpleDocFrob(2,matrix{{1,2}}) == matrix{{1,2,0,0},{0,0,1,2}})
///"
