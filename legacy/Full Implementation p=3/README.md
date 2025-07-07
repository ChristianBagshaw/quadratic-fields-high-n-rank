## Full Implementation for p=3


This directory contains the code necessary for a large-scale, full implementation of Algorithm 3.2 for the case p=3. The only difference between this and the code contained with `full_p_rank_searchstep.sage` and `full_p_rank_idealstep.sage` is that the code contained here chooses the optimal branch of Algorithm 3.2 for p=3 and only works for p=3.  An example of how to run this implementation is given at the bottom of this file, with an example. 

The only real difference between this, and the code for Algorithm 3.2 contained within the directory `p_rank_algorithms` is 
* this only works when p=3,
* an implementation of the factoring sieve,
* data is not stored in memory but is written to files. This means that "manual" processing of data is required throughout, but this is detailed and explained below. 

Throughout we suppose that SageMath v9.2 can be run from the command line with the command `sage`. 

An example of how to run this is given at the bottom of this file, but we first describe the two files needed. 

There are two necessary files: `full_3_rank_searchstep.sage` and `full_3_rank_idealstep.sage` which should both be downloaded (this entire directory can be downloaded for simplicity). First, we describe what each does:

### full_3_rank_searchstep.sage
 * This file carries out, essentially, lines 1-26 of Algorithm 3.2 for the case p=3, but data is stored in .txt files instead of a dictionary.
 * If executed as is, say 
    ```
    sage full_3_rank_searchstep.sage
    ```
    is executed from the command line, then the user will be prompted to input a value for lambda1, lambda2, lower_m1, upper_m1 and a sieve_bound (the largest prime to sieve over, set to 0 to skip sieving). The first 26 lines of Algorithm 3.2 will be run with these parameters. 
 * To run more directly from the command line, one should run

    ```
    sage full_3_rank_searchstep.sage lambda1 lambda2 lower_m1 upper_m1 sieve_bound
    ```
    with desired parameters. The output of this will be the file `3optimal_lambda1_lambda2_lower_m1_upper_m1_searchdata.txt`. For example, if the command 

    ```
    sage full_3_rank_searchstep.sage 1 1 3 512 0
    ```
    was run from the command line, the output file would be `3optimal_1_1_3_512_searchdata.txt`. Each line of this file is of the form "*$\Delta$, m*" where $\Delta$ denotes a fundamental discriminant, and *m* the norm of an ideal in $\mathbb{Q}(\sqrt {\Delta})$ of order 3 which was found during the search. 
 * Additionally, the time taken for this computation will be output into the file `3optimal_lambda1_lambda2_lower_m1_upper_m1_searchdata_time.txt`

          
 ### full_3_rank_idealstep.sage
 * This file carries out, essentially, lines 27-29 in Algorithm 3.2, but data is read from a file containing data output from `full_3_rank_searchstep.sage`. Suppose we call this file `3optimal_searchdata_sorted.txt`.
 *  THE DATA IN `3optimal_searchdata_sorted.txt` MUST BE SORTED BY ABSOLUTE VALUE OF THE FIRST ENTRY ON EACH LINE. This is to be able to collect all data corresponding to a given discriminant together quickly, without storing the entire contents of the file into memory. An example of how to do this is given below. 
 *  If executed as is, say  
    ```
    sage full_3_rank_idealstep.sage
    ```
    is executed from the command line, then the user will be prompted to enter the name of the file to be read (input without the .txt extension). 
    
 * This could also be run directly from the command line, as 
    ```
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted
    ```
    The output of this will be a .txt file `3optimal_searchdata_sorted_discs.txt` containing discriminants whose corresponding quadratic field has a q-rank of at least 2. 
      

 * There are multiple ways to parallelize this step, but one is implemented as follows. The command 
    ```
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted a b
    ```
      can be run from the command line for integers a > b. This will simply mean that only discriminants congruent to b mod a will be processed. This does cause a small amount of unnecessary work (reading lines unnecessarily), but is simple and faster than sorting/ splitting the file another way.    

 * Similar to above, the time taken to compute the data now stored in the file     
    ```
    3optimal_searchdata_sorted_discs_time.txt
    ```



## HOW TO RUN 
  1. `full_3_rank_searchstep.sage` and `full_3_rank_idealstep.sage` should be downloaded (or, just this directory). Again, we suppose that Sage v9.2 can be run from the command line with the command `sage`. 
 2. For all  quadruples of (lambda1, lambda2, lower_m1, upper_m1)  which are desired to be searched over, the command 
    ```
    sage full_3_rank_searchstep.sage lambda1 lambda2 lower_m1 upper_m1 sieve_bound
    ```
      should be run from the command line (with a desired sieve_bound). The key is that many of these can be run in parallel. 
 3. The output files from these should be combined and sorted by the first column. This can of course also be parallelized. If the only files in the directory of the form `3optimal_*_searchdata.txt` are the ones output by the commands above, then the commands
    ```
    cat 3optimal_*_searchdata.txt > 3optimal_searchdata.txt
    sort -n -r 3optimal_searchdata.txt -o 3optimal_searchdata_sorted.txt
    ```

       can be run from the command line to achieve this (although for a very large run, one would want to delete files once they are copied and sorted to save storage, and the sorting should be parallelized). Also, to ensure that commas are not misinterpreted, one should first run the command 
    ```
    export LC_NUMERIC=Ct
    ```       
2. The file from the previous step can then be called by `full_3_rank_idealstep.sage` as
    ```
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted
    ```     
      to finish Algorithm 3.2. The output of this would be the file `3optimal_searchdata_sorted_discs.txt`. 
3.  Alternatively, one could split the final step as described above. For some integer b, the commands 
    ```
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted b 0
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted b 1
    ....
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted b b-1
    ```     
       could all be run. This would output files 
    ```
    3optimal_searchdata_sorted_discs_b_0.txt
    3optimal_searchdata_sorted_discs_b_1.txt
    ...
    3optimal_searchdata_sorted_discs_b_b-1.txt
    ```    
       with the file  `*b_a.txt`containing the processed discriminants congruent to a mod b. 

## EXAMPLE
   We will conduct a search for fields with large 3-rank
   * without sieving
   * over the lambda pairs (1,1), (2,1)
   * from lower_m1 = 1025 to upper_m1 = 2048
   
   We will split the search into 4 computations, given by the following parameters 
             
   * the lambda pair (1,1) and lower_m1 = 1025 to upper_m1 = 1536
   * the lambda pair (1,1) and lower_m1 = 1537 to upper_m1 = 2048
   * the lambda pair (2,1) and lower_m1 = 1025 to upper_m1 = 1536
   * the lambda pair (2,1) and lower_m1 = 157 to upper_m1 = 2048

To do so, we first run the following from the command line:
   ```
    sage full_3_rank_searchstep.sage 1 1 1025 1536 0 &
    sage full_3_rank_searchstep.sage 1 1 1537 2048 0 &
    sage full_3_rank_searchstep.sage 2 1 1025 1536 0 &
    sage full_3_rank_searchstep.sage 2 1 1537 2048 0 &
   ``` 

 Once these jobs have been completed, we combine the output into one file and sort
     
    cat 3optimal_*_searchdata.txt > 3optimal_searchdata.txt
    sort -n -r 3optimal_searchdata.txt -o 3optimal_searchdata_sorted.txt
We then process these and split them up modulo 11 (not 10, since discriminants have a bias mod 2) by running 

    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted 5 0 &
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted 5 1 &
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted 5 2 &
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted 5 3 &
    sage full_3_rank_idealstep.sage 3optimal_searchdata_sorted 5 4 &
    
  The output files now contain a total of 624805 unique discriminants whose fields have 3-rank at least 2. The total run time of the computation was 876.62 seconds, but this was done in 4 parallel computations so took only a few minutes in real time. 
        
        
