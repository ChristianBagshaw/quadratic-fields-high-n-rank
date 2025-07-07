
# Individual Algorithms 

Here we have included implementations of several search methods discussed in the paper. The best way to understand these would be to read the relevant sections of the paper, as well as the references therein. 

Importing modules and packages in Sage can be annoying at times, so the simplest way to access these implementations is to load the files in this directory into Sage. Each of the search methods will then be available as a function (names, locations, and descriptions of these functions are given below). To load these into Sage, there are two options:
1. Download the files contained here, and to load a file `x.txt` simply run in Sage, `load('x.txt')`.
2. To load them all simultaneously, from the command line on a system with git, run 

    ```
    git clone https://github.com/ChristianBagshaw/Improved-methods-for-finding-imaginary-quadratic-fields-with-high-n-rank.git
    ```

    Then open Sage, and run the following 

    ```python 
    from os import walk
    folder = next(walk("Improved-methods-for-finding-imaginary-quadratic-fields-with-high-n-rank/Individual Algorithms"))
    for filename in folder[2]:
        if filename.endswith('.sage'):
            load("Improved-methods-for-finding-imaginary-quadratic-fields-with-high-n-rank/Individual Algorithms/"+filename)
    ```

The function names (and descriptions of what they are implementations of and where to find them) are as follows:

## p_rank_allsteps()
This function runs a full implementation of Algorithm 3.2 from the paper, and is found in the file `p_rank_allsteps.sage`.  This is definitively the most successful and efficient algorithm for generating fields with $p$-rank at least 2, and should be used if one is interested in quickly generating examples. This will run the entire algorithm on one node, in one computation. Thus, it is suitable for smaller computations, where all data can be stored in dictionaries. The best source for understanding this would be to read the paper, or one can ask Sage for help via `help(p_rank_allsteps)`. But we will give a sketch of what the function does, and then give an example of using it. 

First, we fix an odd prime $p$, which is the first input for the function. The initial goal is to generate many integer solutions to the equation 
$$4m^p = y^2 - z^2\Delta, $$
where $\Delta$ is a fundamental discriminant, that satisfy Proposition 2.3(a) from the paper.  Additionally for each value of $\Delta$ we want multiple unique solutions corresponding to it. To do this, we input a list of integer tuples $[(\lambda_{1,i}, \lambda_{2,i})]$ , a value $\texttt{lower}\textunderscore m_1$ and a value of $\texttt{upper}\textunderscore m_1$. For each pair $(m_1, m_2)$ with $\texttt{lower}\textunderscore m_1 \leq m_2 < m_1 \leq \texttt{upper}\textunderscore m_1$,  and each pair $(\lambda_{1,i}, \lambda_{2,i})$, the function generates many integer solutions $(y_1, y_2, z, \Delta)$ to the simultaneous system

$$4m_1^p = y_1^2 - \lambda_{1,i}^2z^2\Delta, ~~~~ 4m_2^p = y_2^2 - \lambda_{2,i}^2z^2\Delta$$
 
and we only keep those individual solutions that satisfy Proposition 2.3(a).  

After this step, we group all tuples $(m,y, z\lambda)$ that correspond to  a given $\Delta$. By Proposition 2.3(a), each solution will correspond to an ideal class in the class group of $\mathbb{Q}(\sqrt{\Delta})$ of order $p$.  We can then either use Proposition 2.3(b) or Theorem 2.4 to output each $\Delta$ whose corresponding solutions generate a subgroup isomorphic to $(\mathbb{Z}/p\mathbb{Z})^k$ for some $k \geq 2$

When $p=3$, by default Proposition 2.3(b) is used. 

When $p > 3$, the function always uses Theorem 2.4 to test for this. We can use Theorem 2.4 to obtain an explicit $\mathbb{Z}$-basis for each ideal class, and we can use Sage's built-in `BinaryQF` package to perform arithmetic with them. For $p=3$ this is not optimal, but can be forced by setting `explicit_testing_3=True` in the function input. 

The output of the function will be a list of discriminants, such that for each discriminant $\Delta$ the ideal class group of $\mathbb{Q}(\sqrt{\Delta})$ has a $p$-rank of at least 2. 

### Example
We will run this with parameters `p=5`, `lambda_pairs=[(1,1), (1,2)]`, `lower_m1=3` and `upper_m1=1024`. We will save the output to a list `D`. In Sage, this is run simply via the command 
```python
D = p_rank_allsteps(3, [(1,1), (1,2)], 3, 1024)
```
While running, it outputs the following as updates (these can be disabled by setting `print_progress=False` in the function input)
```
Running Algorithm 3.2 for
p=3, lambdas = [(1, 1), (1, 2)], lower_m1 = 3, upper_m1 = 1024
  Searching for solutions/ generating ideals...
    Done!
  Checking number of ideals found...
    Done!
  Returning 202727 discriminants with 3-rank > 1
```
This computation took approximately 9 minutes. `D` now contains 202727 discriminants of 3-rank at least 2: 
```
[-3299, -3896, -4027, -5703, -6583, -8751, -9748, -10015, -11651, -12067,...
```

## dyd_ext()
This is an implementation of Diaz Y Diaz's original search method (as well as its natural extension to $p > 3$) as described in Section 3.1 of the paper. It is found in the file `dyd_ext.sage`. Section 3.1 is the best source for understanding this function, as well as asking Sage for help via `help(dyd_ext)`. Similar to `p_rank_allsteps`, it takes as input parameters for a search and outputs a list of discriminants with $p$-rank at least 2. 

It can be considered an older variant of `p_rank_allsteps`, with a slightly different way of searching for solutions. But the main difference is as follows: if one reads the description of `p_rank_allsteps` above, after solutions are found we must process these solutions. `p_rank_allsteps` applies Theorem 2.4, while `dyd_ext` applies Proposition 2.3(b). 

This is only meant to serve as an implementation for testing and is very sub-optimal when compared with `p_rank_allsteps`, especially for $p > 3$. 
### Example
We will run `dyd_ext` with parameters `p=3`, `lower_m1 = 15` and `upper_m1 = 20`. We will save the output to a list `D`. In Sage, this is run simply via the command 
```python
D = dyd_ext(3, 15, 20)
```
While running, it outputs the following as updates (it outputs more regular updates than `p_rank_allsteps`, because it is much slower)
```
Running DyD Ext for
p= 3, lower_m1 = 15, upper_m1 = 20
   status on m1:
     m1 = 15
     m1 = 16
     m1 = 17
     m1 = 18
     m1 = 19
     m1 = 20
   Done!
Returning 16 discriminants with 3-rank > 1
```
This computation took approximately 30 seconds. `D` now contains 16 discriminants of 3-rank at least 2: 
```
[-3299, -3896, -4027, -6583, -11651, -16627, -17399, -19427, -19651, -19679, -27355, -28031, -28279, -31271, -31639, -31999]
```


## mestre_curve()

coming soon...
