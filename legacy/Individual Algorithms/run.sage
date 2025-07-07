from p_rank_allsteps.sage import p_rank_allsteps

# Now call the function (with example arguments):  
p = 3                         # Example: prime  
lambda_pairs = [(1,2),(3,4)]  # Example: your list of pairs  
lower_m1 = 5  
upper_m1 = 10  
explicit_testing_3 = False    # or True, as needed  
print_progress = True         # or False  
  
# Call the algorithm and store the result  
D = p_rank_allsteps(p, lambda_pairs, lower_m1, upper_m1, explicit_testing_3, print_progress)  
  
print(D)                      # Or do whatever you want with the result  