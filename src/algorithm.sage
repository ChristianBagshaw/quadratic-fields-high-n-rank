load("src/ideals.sage")
load("src/rankcheck.sage")
load("src/reporting.sage")
from math import sqrt

def p_rank_allsteps(
    p, lambda_pairs, lower_m1, upper_m1,
    output_file=None,
    explicit_testing_3=False, verbose=True
):
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
        output_file: Optional path to a file to save the discriminants (string)
        explicit_testing_3: either True or False, which can force p=3 to perform explicit ideal independence testing
        verbose: either True or False, whether or not to print the progress of the computation to the console

    Output
        D: a list consisting of discriminants, each corresponding to a non-empty set of triples {(m_i, y_i, (lambda_ij)*z_i)} satisfying Proposition (2.3) (a) for n=p with lower_m1 <= m_1 <= upper_m1 and 2 <= m_2 < m_1, such that the ideal classes corresponding to the triples {(m_i, y_i, (lambda_ij)z_i)} generate a subgroup of the ideal class group of Q(sqrt{delta}) isomorphic to (Z/pZ)^k for some k > 1.
    """

    report = Reporter(verbose)
    report.start(p, lambda_pairs, lower_m1, upper_m1)

    # Determine which method to use for p=3.
    use_p3_optimization = (p == 3 and not explicit_testing_3)

    report.search_step()
    ideals = {}

    # ------------------ Main loops
    for (lambda1, lambda2) in lambda_pairs:
        report.lambda_pair(lambda1, lambda2)

        m1_range = range(lower_m1, upper_m1 + 1)
        for m1 in progress_bar(m1_range, desc="  m1", verbose=verbose):
            N1 = 4 * lambda2**2 * m1**p

            m2_range = range(2, m1)
            for m2 in progress_bar(m2_range, desc=f"    m2 (m1={m1})", verbose=verbose, leave=False):
                N = N1 - 4 * lambda1**2 * m2**p

                if (use_p3_optimization and N <= 0) or (not use_p3_optimization and N == 0):
                    continue

                sqN = sqrt(abs(N))

                for a in divisors(N):
                    if a > sqN:
                        break

                    b = N // a

                    if use_p3_optimization:
                        if (a + b) % (2 * lambda2) == 0:
                            passed, delta = kuroda_test(m1, lambda2, a + b)
                            if passed:
                                ideals.setdefault(delta, []).append(m1)
                    else:
                        if (2 * lambda2).divides(a + b):
                            y1 = (a + b) // (2 * lambda2)
                            passed, delta, ideal_coeffs = Solution_to_Ideals(p, y1, m1)
                            if passed:
                                ideals.setdefault(delta, []).append(ideal_coeffs)

                    if a != b:
                        if use_p3_optimization:
                            if (b - a) % (2 * lambda1) == 0:
                                passed, delta = kuroda_test(m2, lambda1, b - a)
                                if passed and m2 < sqrt(-delta / 4):
                                    ideals.setdefault(delta, []).append(m2)
                        else:
                            if (2 * lambda1).divides(b - a):
                                y2 = (b - a) // (2 * lambda1)
                                passed, delta, ideal_coeffs = Solution_to_Ideals(p, y2, m2)
                                if passed:
                                    ideals.setdefault(delta, []).append(ideal_coeffs)

    # ------------------ Ideal testing
    report.testing_step(use_p3_optimization)
    D = []

    if use_p3_optimization:
        for delta in progress_bar(ideals.keys(), desc="  discriminants", verbose=verbose):
            if len(set(ideals[delta])) > 1:
                D.append(delta)
    else:
        for delta in progress_bar(ideals.keys(), desc="  discriminants", verbose=verbose):
            if rankcheck(p, ideals[delta]):
                D.append(delta)

    # ------------------ Final results
    D = sorted(list(set(D)), reverse=True)
    report.result(p, len(D))

    #  ----------------- Save
    if output_file:
        report.saving(len(D), output_file)
        try:
            with open(output_file, 'w') as f:
                for discriminant in D:
                    f.write(f"{discriminant}\n")
            report.saved()
        except IOError as e:
            report.save_error(e)

    return D
