# File for Algorithm 3.2 - Improved Alg
# The main function contained here is p_rank_full_search, which carries out Algorithm 3.2 in full


from math import sqrt
import itertools
import numpy 
  
  
def p_rank_allsteps(p, lambda_pairs, lower_m1, upper_m1, explicit_testing_3 = False, print_progress = True):

    """

    Algorithm 3.2 - "Improved Alg"

    This runs Algorithm 3.2. The best way to understand this is to read this algorithm in the paper. Note that this function runs the algorithm in full, on one node in one computation. Thus, it is suitable for smaller computations to generate discriminants with non-trivial p-rank. 

    Algorithm 3.2 uses two slightly different ideas, depending on whether p=3 or p > 3. By default, this function runs the optimal algorithm for a given value of p, but there is a flag provided to allow p=3 to run the other branch (perform explicit ideal independence testing). This will produce more discriminants for a given input, but is not worth the increase in run-time. 
    
    Note that memory will quickly become an issue if this code is run verbatim for a large computation, since a lot of data is being stored in dictionaries. In a large computation, this data should be stored outside of memory. 
  
    Input
        p: an odd prime number (int)
        lambda: a list of integer pairs [(lambda_i1, lambda_i2)]
        lower_m1: lower bound on m_1
        upper_m1: upper bound on m_1 
        explicit_testing_3: either True or False, which can force p=3 to perform explicit ideal independence testing
        print_progress: either True or False, whether or not to print the progress of the computation to the console

    Output
        D: a list consisting of discriminants, each corresponding to a non-empty set of triples {(m_i, y_i, (lambda_ij)*z_i)} satisfying Proposition (2.3) (a) for n=p with lower_m1 <= m_1 <= upper_m1 and 2 <= m_2 < m_1, such that the ideal classes corresponding to the triples {(m_i, y_i, (lambda_ij)z_i)} generate a subgroup of the ideal class group of Q(sqrt{delta}) isomorphic to (Z/pZ)^k for some k > 1. 

    
    """

    print("Running Algorithm 3.2 for")
    print("p="+str(p)+", lambda_pairs = "+str(lambda_pairs)+", lower_m1 = "+str(lower_m1)+", upper_m1 = "+str(upper_m1))
    if p ==3 and not explicit_testing_3: 
        progress(print_progress, "  Searching for solutions/ generating ideals...")
        ideals = {}

        for (lambda1, lambda2) in lambda_pairs:
            for m1 in range(lower_m1, upper_m1 + 1):
                N1 = 4*lambda2^2*m1^3
                
                for m2 in range(2, m1):

                    N = N1 - 4*lambda1^2*m2^3
                    if N <= 0:
                        continue 
                    sqN = sqrt(N)
                    
                    for a in divisors(N):
                        if a <= sqN:
                            b = N/a
                            
                            if (2*lambda2).divides(a+b):
                                passed, delta = kuroda_test(m1, lambda2, a+b)
                                if passed:
                                    if delta in ideals:
                                        ideals[delta].append(m1)
                                    else:
                                        ideals[delta] = [m1]
                                
                            if (2*lambda1).divides(a-b):
                                passed, delta = kuroda_test(m2, lambda1, a-b)
                                if passed:
                                    if m2 < sqrt(-delta/4):
                                        if delta in ideals:
                                            ideals[delta].append(m2)
                                        else:
                                            ideals[delta] = [m2]


        progress(print_progress,"    Done!")


        # the following carries out lines 27-29 in Algorithm 3.2
        D = []
        progress(print_progress,"  Checking number of ideals found...")
        for delta in ideals:
            if len(set(ideals[delta])) > 1:
                D.append(delta)
                
        
        progress(print_progress,"    Done!")
        D = sorted(list(set(D)),reverse=True)
        progress(print_progress,"  Returning "+str(len(D))+" discriminants with "+str(p)+"-rank > 1")
        print("")
        return(D)
    
    else:
        
        if p == 3:
            print("Forcing explicit ideal testing for p=3...")
        
        progress(print_progress, "  Searching for solutions/ generating ideals...")
        ideals = {}
    
        for (lambda1, lambda2) in lambda_pairs:
            for m1 in range(lower_m1, upper_m1 + 1):
                N1 = 4*lambda2^2*m1^p
                for m2 in range(2, m1):

                    N = N1 - 4*lambda1^2*m2^p
                    if N == 0:
                        continue 
                    sqN = sqrt(abs(N))
                    for a in divisors(N):
                        if a <= sqN:
                            b = N/a
                            if (2*lambda2).divides(a+b):

                                y1 = (a+b)/(2*lambda2)

                                passed, delta, ideal_coeffs = Solution_to_Ideals(p, y1, m1) # carries out lines 11-23 in Algorithm 3.4

                                # if all of the "if" statements between lines 11-23 in Algorithm 3.4 have passed, we now carry out line 23. 
                                if passed:
                                    if delta in ideals:
                                        ideals[delta].append(ideal_coeffs)
                                    else:
                                        ideals[delta] = [ideal_coeffs]


                            if (2*lambda1).divides(a-b):
                                y2 = (a-b)/(2*lambda1)

                                passed, delta, ideal_coeffs = Solution_to_Ideals(p, y2, m2) # carries out line 26 in Algorithm 3.2

                                if passed:
                                    if delta in ideals:
                                        ideals[delta].append(ideal_coeffs)
                                    else:
                                        ideals[delta] = [ideal_coeffs]







        progress(print_progress,"    Done!")

        progress(print_progress,"  Starting independence testing...")

        # the following carries out lines 27-32 in Algorithm 3.2
       
        D = []
        for delta in ideals:
            if rankcheck(p, ideals[delta]):
                D.append(delta)
       
        

        progress(print_progress,"    Done!")
        D = sorted(list(set(D)),reverse=True)
        progress(print_progress,"  Returning "+str(len(D))+" discriminants with "+str(p)+"-rank > 1")
        progress(print_progress,"")
        return(D)
      
  
  
       
def progress(print_progress, string):
    if print_progress:
        print(string)


def kuroda_test(m, lambda0, a_pm_b):
    """
    Checks if the conditions of Theorem 2.2 and Propostion 2.3 are satisfied for the case p=3. That is, it carries out lines 10-20 in Algorithm 3.2
    
    Input
        m, lambda0, a_pm_b: either y1, lambda2, a+b or y2, lambda1, a-b as described in Algorithm 3.2

    Output
        Passed, delta: if the conditions of Theorem 2.2 and Proposition 2.3 are satisfied, then passed is returned as True and delta is the value of delta as described in Algorithm 3.2. Otherwise, it returns False, None
    """

    y = (a_pm_b)/(2*lambda0)
    t = y^2 - 4*m^3
    if t < 0:
        delta = t.squarefree_part()
        if delta % 4 != 1:
            delta = 4*delta
        if delta.divides(t):
            z = int(sqrt(t/delta))
            c = gcd(m,z)
            if c.divides(delta) and not 4.divides(c):
                if m < sqrt(-delta/4):
                    return(True, delta)
    return(False, None)
    

        
 
def Solution_to_Ideals(p, y, m):

    """
    This carries out lines 11-23 in Algorithm 3.2, and also carries out the ideas described in Theorem 2.4. It returns the ideal as described in line 23 as a list of coefficients [A,B,C] of a binary quadratic form. If any of the required conditions are not satisfied, it simply returns False. 

    Input
        p, y, m: values of p, y_i, m_i generated by Algorithm 3.2
    
    Output
        delta: the value of delta as in line 12 of Algorithm 3.2
        coeffs: a list [A,B,C] of the coefficients of a binary quadratic form corresponding to the ideal described in line 23 of Algorithm 3.2
    """
    

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

                coeffs = [A,B,C]
                return(True, delta, coeffs)
            
    return(False, None, None)

                   
                        
                  
    




def rankcheck(p, forms_coeffs):
    """
    Takes in a list of coefficients, corresponding to binary quadratic forms of equal discriminant of order p, and returns True if these forms generate a subgroup of order at least p^2. This function makes use of Sage's BinaryQF package

    Input:
        p: an odd prime p, which must correspond to the order of the binary quadratic forms of equal discriminant of order p
        forms_coeffs: a list of lists [ [A_i, B_i, C_i] ] of coefficients of binary quadratic forms 
    """
    
    forms = []
    for coeff in forms_coeffs:
        
        # convert coefficients to binary quadratic forms using Sage's built in BinaryQF
        Qform = BinaryQF([coeff[0], coeff[1], coeff[2]]).reduced_form() 
        if Qform not in forms:
            forms.append(Qform)
    
    # full generated will contain the subgroup generated by the forms 
    full_generated = []

    counter = 0

    while counter < len(forms):


        if counter == 0:
            
            # the following adds powers of the first form to the subgroup
            f = forms[counter]
            f1 = f
            full_generated.append(f)
            counter = counter+1
            for power in range(1, p):
                f = (f*f1).reduced_form()
                full_generated.append(f)
            
        else:

            f = forms[counter] 
            counter += 1
            if f in full_generated:
                continue 

            # the following puts powers of the next forms into current_subgroup 
            current_subgroup = []
            f1 = f
            current_subgroup.append(f)
            for power in range(1, p):
                f = (f*f1).reduced_form()
                current_subgroup.append(f)

            # the product of current_subgroup and full_generated is taken and replaces full_generated
            new_generated = set()
            for element in itertools.product(current_subgroup, full_generated):
                new  = (numpy.prod(element)).reduced_form()
                new_generated.add(new)
            full_generated = list(new_generated)
            
            
            if len(full_generated) > p: #if the forms generate a subgroup of size larger than p, then we can conclude k > 1. 
    
                return(True)

    # return False if the forms do not generate a large enough subgroup.       
    return(False)


p = 3                         # Example: prime  
lambda_pairs = [(1,2),(3,4)]  # Example: your list of pairs  
lower_m1 = 5  
upper_m1 = 100 
explicit_testing_3 = False    # or True, as needed  
print_progress = True         # or False  
  
# Call the algorithm and store the result  
D = p_rank_allsteps(p, lambda_pairs, lower_m1, upper_m1, explicit_testing_3, print_progress)  
  
print(D)      