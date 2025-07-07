
def dyd_ext(p, lower_m1, upper_m1):
    """
    This contains an implementation of Diaz y Diaz's original method, as well as it's natural extension to p > 3. This is described in detail in Section 3.1 of the paper. In Section 4 this is referred to as "Dyd Ext". 

    This function serves simply to isolate and test the Dyd Ext algorithm. 
    NOTE: this code is slow, will not handle large values of upper_m1 well at all, and will struggle to produce much for p > 3. The core ideas here are the foundation and core of our Algorithm 3.2, but the main issue with this variant is the way the values of m1 and m2 are searched over. 
    
    Input
       p: an odd prime
       lower_m1: lower bound on m1
       upper_m1: upper bound on m1
       
    Output
    D: a list of all discriminants of quadratic number fields corresponding to pairs of triples (m1, y1, z1), (m2, y2, z2) satisfying Proposition (2.3) (b) for n=p with lower_m1 <= m1 <= upper_m1 and m1 < m2 < m1^(p/2). In particular, all discriminants output will have a p-rank of at least 2. 

    """
    print("Running DyD Ext for")
    print("p= "+str(p)+", lower_m1 = "+str(lower_m1)+", upper_m1 = "+str(upper_m1))
    print("   status on m1:")
    D = set() 
    for m1 in range(lower_m1, upper_m1 + 1):
        print("     m1 = "+str(m1))
        t = 1
        while t < m1^(p/2) - m1:
            m2 = m1 + t
            N = (m2^p - m1^p)/t
            for t_prime in divisors(t):
                t_prime_prime = t/t_prime
                for N_prime in divisors(N):
                    if N_prime <= N^(1/2):
                        N_prime_prime = N/N_prime
                        y = t_prime*N_prime - t_prime_prime*N_prime_prime
                        if y^2 - 4*m1^p < 0:
                            delta = squarefree_part(y^2 - 4*m1^p)
                            if delta % 4 != 1:
                                delta= 4*delta
                            if (y^2-4*m1^p) % delta == 0:
                                z = ((y^2-4*m1^p)/delta)^(1/2)
                                c1 = gcd(m1, z)
                                c2 = gcd(m2, z)
                                if delta % c1 == 0 and delta % c2 == 0 and c1 % 4 != 0 and c2 % 4 != 0:
                                    if m2 < (-delta/4)^(1/2):
                                        if p == 3:
                                            D.add(delta)
                                        else:
                                            if m1^((p-1)/2) % m2 != 0 and m1^((p-1)/2) < (-delta/4)^(1/2):
                                                D.add(delta)
                                                
            t += 1
    print("   Done!")
    print("Returning "+str(len(D))+" discriminants with "+str(p)+"-rank > 1")
    return(sorted(list(D), reverse = True))






