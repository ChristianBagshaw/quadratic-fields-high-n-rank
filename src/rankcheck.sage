def rankcheck(p, forms_coeffs):
    """
    Checks if a list of binary quadratic forms generate a p-torsion subgroup of rank at least 2.

    Input
        p: A prime number (int), which is the order of the torsion subgroup being checked.
        forms_coeffs: A list where each element is a list of three integer coefficients [a, b, c]
                      corresponding to a binary quadratic form. All forms must share the
                      same discriminant.

    Output
        A boolean value: Returns True if the ideal classes corresponding to the input forms
        generate a subgroup of the ideal class group isomorphic to (Z/pZ)^k for k > 1.
        Returns False otherwise.
    """

    # --------------- reduce forms
    unique_forms = list({BinaryQF(c).reduced_form() for c in forms_coeffs})

    if not unique_forms:
        return False

    # -------------- grab the first form and compute the subgroup it generates
    initial_generator = unique_forms.pop(0)
    generated_subgroup = set()
    current_power = initial_generator
    for _ in range(p):
        generated_subgroup.add(current_power)
        current_power = (current_power * initial_generator).reduced_form()

    # --------- check if any other forms are indepdent of the first
    for next_generator in unique_forms:
        if next_generator in generated_subgroup:
            continue

        cyclic_subgroup_next = set()
        current_power = next_generator
        for _ in range(p):
            cyclic_subgroup_next.add(current_power)
            current_power = (current_power * next_generator).reduced_form()

        generated_subgroup = {
            (g * h).reduced_form()
            for g in generated_subgroup
            for h in cyclic_subgroup_next
        }

        if len(generated_subgroup) >= p**2:
            return True
            
    # ---------- the forms did not generate a subgroup of size at least p**2. 
    return False

