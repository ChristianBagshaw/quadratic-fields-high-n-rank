

# Full Implementation

This directory contains the code necessary for a large-scale, full implementation of Algorithm 3.2 with explicit ideal independence testing. Thus, for the prime p=3 this is not optimal, and the directory `Full Implementation p=3` should be looked at. But, this implementation will still work incredibly well for p=3. An example of how to run this implementation is given at the bottom of this file, with an example. 

When discussing finding fields of high p-rank, this document the variable "q" is used instead of "p" to avoid confusion with the "p" used in the names of files.

The only real difference between this, and the code for Algorithm 3.2 contained within the directory `p_rank_algorithms` is 
* an implementation of the factoring sieve,
* data is not stored in memory but is written to files. This means that "manual" processing of data is required throughout, but this is detailed and explained below. 

Throughout we suppose that SageMath v9.2 can be run from the command line with the command `sage`. 

An example of how to run this is given at the bottom of this file, but we first describe the two files needed. 

There are two necessary files: `full_p_rank_searchstep.sage` and `full_p_rank_idealstep.sage` which should both be downloaded (this entire directory can be downloaded for simplicity). First, we describe what each does:

### full_p_rank_searchstep.sage
 * This file carries out, essentially, lines 1-26 of Algorithm 3.2, but data is stored in .txt files instead of a dictionary.
 * If executed as is, say 
    ```
    sage full_p_rank_searchstep.sage
    ```
    is executed from the command line, then the user will be prompted to input a value for q, lambda1, lambda2, lower_m1, upper_m1 and a sieve_bound (the largest prime to sieve over, set to 0 to skip sieving). The first 26 lines of Algorithm 3.2 will be run with these parameters. 
 * To run more directly from the command line, one should run

    ```
    sage full_p_rank_searchstep.sage q lambda1 lambda2 lower_m1 upper_m1 sieve_bound
    ```
    with desired parameters. The output of this will be the file `q_lambda1_lambda2_lower_m1_upper_m1_searchdata.txt`. For example, if the command 

    ```
    sage full_p_rank_searchstep.sage 5 1 1 3 512 0
    ```
    was run from the command line, the output file would be `5_1_1_3_512_searchdata.txt`. Each line of this file is of the form "*$\Delta$, [A, B, C]*" where $\Delta$ denotes a fundamental discriminant, and *[A,B,C]* denotes the coefficients of a binary quadratic form, corresponding to an ideal class in $\mathbb{Q}(\sqrt {\Delta})$ of order q which was found during the search. 
 * Additionally, the time taken for this computation will be output into the file `q_lambda1_lambda2_lower_m1_upper_m1_searchdata_time.txt`

          
 ### full_p_rank_idealstep.sage
 * This file carries out, essentially, lines 27-31 in Algorithm 3.2, but data is read from a file containing data output from `full_p_rank_searchstep.sage`. Suppose we call this file `q_searchdata_sorted.txt`.
 *  THE DATA IN `q_searchdata_sorted.txt` MUST BE SORTED BY ABSOLUTE VALUE OF THE FIRST ENTRY ON EACH LINE. This is to be able to collect all data corresponding to a given discriminant together quickly, without storing the entire contents of the file into memory. An example of how to do this is given below. 
 *  If executed as is, say  
    ```
    sage full_p_rank_idealstep.sage
    ```
    is executed from the command line, then the user will be prompted to input a value for q, as well as the name of the file to be read (input without the .txt extension). 
    
 * This could also be run directly from the command line, as 
    ```
    sage full_p_rank_idealstep.sage q q_searchdata_sorted
    ```
    The output of this will be a .txt file `q_searchdata_sorted_discs.txt` containing discriminants whose corresponding quadratic field has a q-rank of at least 2. 
      

 * There are multiple ways to parallelize this step, but one is implemented as follows. The command 
    ```
    sage full_p_rank_idealstep.sage q q_searchdata_sorted a b
    ```
      can be run from the command line for integers a > b. This will simply mean that only discriminants congruent to b mod a will be processed. This does cause a small amount of unnecessary work (reading lines unnecessarily), but is simple and faster than sorting/ splitting the file another way.    

 * Similar to above, the time taken to compute the data now stored in the file     
    ```
    q_searchdata_sorted_discs_time.txt
    ```



## HOW TO RUN 
1. Fix a prime q for which one wishes to search for discriminants with large q-rank. 
  1. `full_p_rank_searchstep.sage` and `full_p_rank_idealstep.sage` should be downloaded (or, just this directory). Again, we suppose that Sage v9.2 can be run from the command line with the command `sage`. 
 2. For all  quadruples of (lambda1, lambda2, lower_m1, upper_m1)  which are desired to be searched over, the command 
    ```
    sage full_p_rank_searchstep.sage q lambda1 lambda2 lower_m1 upper_m1 sieve_bound
    ```
      should be run from the command line (with a desired sieve_bound). The key is that many of these can be run in parallel. 
 3. The output files from these should be combined and sorted by the first column. This can of course also be parallelized. If the only files in the directory of the form `q_*_searchdata.txt` are the ones output by the commands above, then the commands
    ```
    cat q_*_searchdata.txt > q_searchdata.txt
    sort -n -r q_searchdata.txt -o q_searchdata_sorted.txt
    ```

       can be run from the command line to achieve this (although for a very large run, one would want to delete files once they are copied and sorted to save storage, and the sorting should be parallelized). Also, to ensure that commas are not misinterpreted, one should first run the command 
    ```
    export LC_NUMERIC=Ct
    ```       
2. The file from the previous step can then be called by `full_p_rank_idealstep.sage` as
    ```
    sage full_p_rank_idealstep.sage q q_searchdata_sorted
    ```     
      to finish Algorithm 3.2. The output of this would be the file `q_searchdata_sorted_discs.txt`. 
3.  Alternatively, one could split the final step as described above. For some integer b, the commands 
    ```
    sage full_p_rank_idealstep.sage q q_searchdata_sorted b 0
    sage full_p_rank_idealstep.sage q q_searchdata_sorted b 1
    ....
    sage full_p_rank_idealstep.sage q q_searchdata_sorted b b-1
    ```     
       could all be run. This would output files 
    ```
    q_searchdata_sorted_discs_b_0.txt
    q_searchdata_sorted_discs_b_1.txt
    ...
    q_searchdata_sorted_discs_b_b-1.txt
    ```    
       with the file  `*b_a.txt`containing the processed discriminants congruent to a mod b. 

## EXAMPLE
   We will conduct a search for fields with large 5-rank
   * without sieving
   * over the lambda pairs (1,1), (2,1), (3,1), (4,1), (5,1)
   * from lower_m1 = 512 to upper_m1 = 639
   
   We will split the search into 10 computations, given by the following parameters 
             
   * the lambda pair (1,1) and lower_m1 = 512 to upper_m1 = 575
   * the lambda pair (1,1) and lower_m1 = 576 to upper_m1 = 639
   * the lambda pair (2,1) and lower_m1 = 512 to upper_m1 = 575
   * the lambda pair (2,1) and lower_m1 = 576 to upper_m1 = 639
   * the lambda pair (3,1) and lower_m1 = 512 to upper_m1 = 575
   * the lambda pair (3,1) and lower_m1 = 576 to upper_m1 = 639
   * the lambda pair (4,1) and lower_m1 = 512 to upper_m1 = 575
   * the lambda pair (4,1) and lower_m1 = 576 to upper_m1 = 639
   * the lambda pair (5,1) and lower_m1 = 512 to upper_m1 = 575
   * the lambda pair (5,1) and lower_m1 = 576 to upper_m1 = 639

To do so, we first run the following from the command line:
   ```
    sage full_p_rank_searchstep.sage 5 1 1 512 575 0 &
    sage full_p_rank_searchstep.sage 5 2 1 512 575 0 &
    sage full_p_rank_searchstep.sage 5 3 1 512 575 0 &
    sage full_p_rank_searchstep.sage 5 4 1 512 575 0 &
    sage full_p_rank_searchstep.sage 5 5 1 512 575 0 &
    sage full_p_rank_searchstep.sage 5 1 1 576 639 0 &
    sage full_p_rank_searchstep.sage 5 2 1 576 639 0 &
    sage full_p_rank_searchstep.sage 5 3 1 576 639 0 &
    sage full_p_rank_searchstep.sage 5 4 1 576 639 0 &
    sage full_p_rank_searchstep.sage 5 5 1 576 639 0 &
``` 

 Once these jobs have completed, we combine the output into one file and sort
     
    cat 5_*_searchdata.txt > 5_searchdata.txt
    sort -n -r 5_searchdata.txt -o 5_searchdata_sorted.txt
We then process these and split them up modulo 11 (not 10, since discriminants have a bias mod 2) by running 

    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 0 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 1 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 2 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 3 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 4 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 5 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 6 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 7 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 8 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 9 &
    sage full_p_rank_idealstep.sage 5 5_searchdata_sorted 11 10 &
  The output files now contain a total of 31411 unique discriminants whose fields have 5-rank at least 2. 
        
        
