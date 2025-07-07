
# Methods for Finding Imaginary Quadratic Fields with High n-Rank

This repository contains the main algorithm described in the paper titled "Improved Methods for Finding Imaginary Quadratic Fields with High n-Rank". This is an implementation oof the most successful method for finding discriminants of imaginary quadratic number fields whose class groups have a subgroup isomorphic to $(\mathbb{Z}/p\mathbb{Z})^2$ (for a given prime $p$). 

A PDF of the paper can be viewed in this directory. The main implementation contained here is Algorithm 3.2 from the paper. The best way to understand this algorithm is to read the paper.

The repository serves two main purposes:
* For researchers and developers working on algorithms and methods for finding quadratic number fields with non-trivial p-rank, this code facilitates easy testing and comparison.
* For those in need of examples of quadratic number fields with non-trivial p-rank, the code here allows for the rapid generation of such examples.

All code is written to be run in Sage v9.2 (earlier/ later versions of Sage/Python may/ may not work perfectly). Sage is essentially a python wrapper, with many additional in-built functions for mathematics. 



## How to Run
1. Ensure SageMath is installed, and callable from the command line as `sage`.
2. From the root folder of the repository, run the script using:

    ```bash
    sage scripts/run.sage <p> <lambda_pairs> <lower_m1> <upper_m1> [output_file] [verbose] [explicit]
    ```

- `<p>`  
  An odd prime number.

- `<lambda_pairs>`  
  A string of semicolon-separated integer pairs, formatted like `'1,1;2,3'`.

- `<lower_m1>` and `<upper_m1>`  
  Integer bounds defining the range of $m_1$ values to test.

- `[output_file]` (optional)  
  Name of the output file (must end in `.txt`). The file is stored in the directory `data`. Default: `discriminants.txt`.

- `[verbose]` (optional)  
  Whether to print progress updates (`true` or `false`). Default: `true`.

- `[explicit]` (optional)  
  Whether to use explicit ideal class testing for `p = 3`. Default: `false`.

See below for an example (after the explanation of the algorithm). 

## What the Algorithm does
First, we fix an odd prime $p$, which is the first input for the function. The initial goal is to generate many integer solutions to the equation 
$$4m^p = y^2 - z^2\Delta, $$
where $\Delta$ is a fundamental discriminant, that satisfy Proposition 2.3(a) from the paper.  Additionally for each value of $\Delta$ we want multiple unique solutions corresponding to it. To do this, we input a list of integer tuples $[(\lambda_{1,i}, \lambda_{2,i})]$ , a value $m_1$ and a value of $m_2$. For each pair $(m_1, m_2)$ with $2 \leq m_2 < m_1$,  and each pair $(\lambda_{1,i}, \lambda_{2,i})$, the function generates many integer solutions $(y_1, y_2, z, \Delta)$ to the simultaneous system

$$4m_1^p = y_1^2 - \lambda_{1,i}^2z^2\Delta, ~~~~ 4m_2^p = y_2^2 - \lambda_{2,i}^2z^2\Delta$$
 
and we only keep those individual solutions that satisfy Proposition 2.3(a).  

After this step, we group all tuples $(m,y, z\lambda)$ that correspond to  a given $\Delta$. By Proposition 2.3(a), each solution will correspond to an ideal class in the class group of $\mathbb{Q}(\sqrt{\Delta})$ of order $p$.  We can then either use Proposition 2.3(b) or Theorem 2.4 to output each $\Delta$ whose corresponding solutions generate a subgroup isomorphic to $(\mathbb{Z}/p\mathbb{Z})^k$ for some $k \geq 2$

When $p=3$, by default Proposition 2.3(b) is used. When $p > 3$, the function always uses Theorem 2.4 to test for this. We can use Theorem 2.4 to obtain an explicit $\mathbb{Z}$-basis for each ideal class, and we can use Sage's built-in `BinaryQF` package to perform arithmetic with them. For $p=3$ this is not optimal, but can be forced by setting `explicit=True` in the call.

The output of the function will be a list of discriminants, such that for each discriminant $\Delta$ the ideal class group of $\mathbb{Q}(\sqrt{\Delta})$ has a $p$-rank of at least 2. 

### Example
We will run this with parameters `p=5`, `lambda_pairs=[(1,1), (1,2)]`, `lower_m1=3` and `upper_m1=1024`. We will save the output to a file `D.txt`. This is run via the command
```python
sage scripts.run.sage 5 '1,1;1,2' 3 1024 D.txt
```
While running, it outputs the following:
```
🔄 Processing...

==============================================
🚀 Starting Algorithm 3.2 🚀
==============================================
    Prime (p): 5
    Lambda Pairs: [(1, 1), (1, 2)]
    m1 Range: [3, 1024]
----------------------------------------------

🔍 Step 1: Searching for solutions & generating ideals...
Processing lambda pair: (1,1) m1: |███████████████████████████| 1022/1022 [02:40s]
Processing lambda pair: (1,2) m1: |███████████████████████████| 1022/1022 [01:35s]

📊 Step 2: Testing collected ideals...
Performing full independence testing with rankcheck...
Discriminants: |██████████████████████████████████████| 289909/289909 [02:38s]

✅ Analysis Complete!
🎉 Found 131199 discriminants with 5-rank > 1.

💾 Saving 131199 discriminants to /mnt/c/Users/ChristianBagshaw/quadratic-fields-high-n-rank/data/D.txt...
💾 Save successful.
🗑️  Cleaned up temporary files
✨ Complete!
```
This computation took approximately 5.5 minutes. `D.txt` now contains 131199 discriminants of 5-rank at least 2: 
```
-11199
-53079
-58424
-61556
-62632
...
```