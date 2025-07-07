# The file small_p_rank_allsteps.sage is a better source for understanding these functions. 
# see README in this directory

import time
from math import sqrt
import threading
import itertools
import numpy 


        
    
def all_divisors(f): 
    """
Taken from Sage's "divisors" documentation
For an integer n with prime factorization (p_1^{e_1})*(p_2^{e_2})...(p_k^{e_k}), all_divisors takes as input the list [(p_1, e_1), (p_2, e_2), ..., (p_k, e_k)] and outputs a list of all positive divisors of n. 
    """
    one = parent(1)(1)
    output = [one]
    for p, e in f:
        prev = output[:]
        pn = one
        for i in range(e):
            pn *= p
            output.extend(a * pn for a in prev)
    output.sort()
    return output

def roots_generate(p, sieve_bound, lambda1, lambda2):
    """
Produces a dictionary containing, for each prime q up to sieve_bound, the roots of x^p - (lambda2/lambda1) = 0 mod q, and is called upon by Fac_Sieve
    """
    roots = {}
    for q in prime_range(2, sieve_bound+1):
        Zq = Integers(q)  # Zq is the ring of integers modulo q, Z/qZ
        if not q.divides(lambda1):
            lambda1inv = inverse_mod(lambda1, q)
        else:
            continue
        roots[q] =  Zq((lambda2*lambda1inv)^2).nth_root(p, all=True)  # computes the roots of x^p - (lambda2/lambda1)^2 = 0 mod q
    return(roots)



def fac_sieve(p, m1, sieve_bound, lambda1, lambda2):
    """ 
Factoring Sieve as in Algorithm 3.1
    """
    factor_array = [[] for m2 in range(0, m1)]
    roots = roots_generate(p, sieve_bound, lambda1, lambda2)
    for q in roots:
        for x in roots[q]:
            xm1 = (x*m1)%q
            for m2 in range (xm1, m1, q):
                factor_array[m2].append(q)
    return(factor_array)
        
        

# Solution_to_Ideals carries out lines 11-22 in Algorithm 3.2, and also carries out the ideas described in Theorem 2.4. 
    # it returns the ideal as described in line 19 as a list of coefficients [A,B,C] of a binary quadratic form. 
    # If any of the "if" statements are not satisfied, it simply returns a list containing False. 
def Solution_to_Ideals(p, y, m):
    t = ZZ(y^2 - 4*m^p)
    if t < 0:
        delta = t.squarefree_part()
        if delta % 4 != 1:
            delta = 4*delta
        if delta.divides(t):
            z = ZZ(sqrt(t/delta))
            c = ZZ(gcd(m, z))
            if c.divides(delta) and not 4.divides(c):
                    
               #the following carries out the ideas described in Theorem 2.4    
            
                if 4.divides(delta):
                    e = 0
                else:
                    e = 1
                z_prime = Integer(z//(c^((p-1)/2)))
                y_prime = Integer(y//(c^((p-1)/2)))
                if z_prime % 2 == 1:
                    bezout = xgcd(4*m, z_prime)
                    z_star = bezout[2]
                    x = (z_star*y_prime) % (4*m)  

                else:
                    bezout = xgcd(m, z_prime)
                    z_star = bezout[2]

                    x = crt(z_star*y_prime, e , m, 4)

                t = (x-e)//2

                if t < m:
                    A = m
                    B = x
                    C = (B^2 - delta)//(4*A)
                else:
                    A = m
                    B = x - 2*m
                    C = (B^2 - delta)//(4*A)

                return([True, delta, [A, B, C]])
            
    return([False])



# this is essentially the first part of Alg_3_2 from /Code/"Algorithm 3.2 Improved Alg". The only differences are the following:
    # this version uses a factoring sieve, Fac_Sieve, to assist with factoring
    # this version prints ideal data to a file, instead of storing in dictionaries. 
def full_3_rank_searchstep(lower_m1, upper_m1, lambda1, lambda2, sieve_bound, searchfilename):
    
    """

    Algorithm 3.2 - "Improved Alg" for the case of p=3

    This runs Algorithm 3.2 for p=3. The best way to understand this is to read this algorithm in the paper. 

    Input
        lower_m1: lower bound on m_1
        upper_m1: upper bound on m_1 
        lambda1: an integer
        lambda2: an integer
        sieve_bound: a non-negative integer
        searchfilename: the name of the file to which data will be stored

    Output
        a .txt file, searchfilename.txt, containing discriminants (and norms of certain ideals in the quadratic field of such discriminant) as described in line 23 of Algorithm 3.2

    
    """
    
    p = 3
    FILE_search = open(str(searchfilename)+".txt", 'w')
    
    for m1 in range(lower_m1, upper_m1 + 1):
        
        if sieve_bound > 0:
            
            facarray = Fac_Sieve(p, m1, sieve_bound, lambda1, lambda2)
        

        N1 = (lambda2^2)*m1^p
        
        for m2 in range(2, m1):
                
                
                
                N = N1 - (lambda1^2)*m2^p  
                
                if N == 0:
                    continue
                sq = sqrt(4*abs(N))
                
                if sieve_bound > 0:
                    # the following, until the line "for all a in all_divisors(f)" simply adds the additional divisors of 
                        # N that are not already contained within fac_array_m2. 
                    fac_array_m2 = facarray[m2]

                    new_factors = []
                    for prime in set(fac_array_m2):
                        prime_i = prime^(facarray[m2].count(prime) + 1)
                        while (N % prime_i) == 0:
                            new_factors.append(prime)
                            prime_i = prime_i*prime
                    fac_array_m2.extend(new_factors)

                    N_divided = Integer(N / prod(fac_array_m2))

                    F = factor(N_divided)
                    fac_array_m2.extend([prime for (prime, m) in F for _ in xsrange(m)])
                    fac_array_m2.extend([2,2])
                    f = [(fac,fac_array_m2.count(fac) ) for fac in list(set(fac_array_m2))]
                else:
                    f = list(factor(4*N))
                
                
                for a in all_divisors(f):
                    if a <= sq:
                        b = (4*N/a)
                        if (2*lambda2).divides(a+b):
                            if (2*lambda2).divides(a+b):

                                y1 = (a+b)/(2*lambda2)

                                t = y1^2 - 4*m1^3
                                if t < 0:
                                    delta = t.squarefree_part()
                                    if delta % 4 != 1:
                                          delta = 4*delta
                                 
                                    if delta.divides(t):
                                          z1 = int(sqrt(t/delta))
                                          c1 = gcd(m1,z1)
                                          
                                          if c1.divides(delta) and not 4.divides(c1):
                                              if m1 < sqrt(-delta/4):
                                
                                                  FILE_search.write("%s" % delta)
                                                  FILE_search.write("%s" % ",")
                                                  FILE_search.write("%s" % m1)
                                                  FILE_search.write("%s" % "\n")



                            if (2*lambda1).divides(a-b):
                                y2 = (a-b)/(2*lambda1)

                                t = y2^2 - 4*m2^3
                                if t < 0:
                                    delta = t.squarefree_part()
                                    if delta % 4 != 1:
                                          delta = 4*delta
                                    
                                    if delta.divides(t):
                                          z2 = int(sqrt(t/delta))
                                          c2 = gcd(m2,z2)
                                          if c2.divides(delta) and not 4.divides(c2):
                                              if m2 < sqrt(-delta/4):
                                                  FILE_search.write("%s" % delta)
                                                  FILE_search.write("%s" % ",")
                                                  FILE_search.write("%s" % m2)
                                                  FILE_search.write("%s" % "\n")
                                
                               
    FILE_search.close()

##################################################################


p=3

try:
    l1 = Integer(sys.argv[1])
except:
    l1 = int(input("lambda1 =    "))

try:
    l2 = Integer(sys.argv[2])
except:
    l2 = int(input("lambda2 =    "))
    
try:
    lower_m1 = Integer(sys.argv[3])
except:
    lower_m1 = int(input("lower_m1:   "))
    
try:
    upper_m1= Integer(sys.argv[4])
except:
    upper_m1 = int(input("upper_m1:   "))
    
try: # set prime_bound to 0 to skip sieving 
    sieve_bound= Integer(sys.argv[5])
except:
    sieve_bound = int(input("prime sieve bound (0 to skip sieving):   "))


    
    

# the ideal data corresponding to the parameters above will be stored in the file below. 
searchfilename = str(p)+"optimal_"+str(l1)+"_"+str(l2)+"_"+str(lower_m1)+"_"+str(upper_m1)+"_searchdata"

t = time.time()

full_3_rank_searchstep(lower_m1, upper_m1, l1, l2, sieve_bound, searchfilename)

search_time = time.time() - t

timefilename = searchfilename+"_time"
timefile = open(str(timefilename)+".txt", 'w')
timefile.write(str(search_time))
timefile.close()


print(searchfilename, "done searching")


