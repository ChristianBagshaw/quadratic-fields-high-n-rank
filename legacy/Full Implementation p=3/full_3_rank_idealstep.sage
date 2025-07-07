# The file p_rank_allsteps.sage is a better source for understanding these functions. 
# see README in this directory

import time
from math import sqrt
import threading
import itertools
import numpy 




def RemoveDuplicates(dict1):
    for d in dict1:
        dict1[d] = list(set(dict1[d]))
    return dict1




def full_3_rank_idealstep(searchfilename, discfilename, modulus, mod):
    
    """
    The data output from full_3_rank_searchstep (after it is sorted) is read and for each discriminant, we check if there are multiple ideals of different norms associated to it. If so, we can conclude that the field has a 3-rank of at least 2. 
    
    Similar to full_p_rank_idealstep, the main obstacle is not being able to read the entire file in at once. 
    
    """
    
    discfile = open(discfilename + ".txt", 'w')
    
    
    with open(searchfilename+".txt", "rbU") as f:
        TOTAL_LINES = sum(1 for _ in f)

    
    F = open(searchfilename+".txt", 'r')
    
    line = F.readline()
    lines_read = 1
 
    while lines_read <= TOTAL_LINES:

        currentline  = str(line)
        currentline = currentline.split(',')
 
      
        d = Integer(currentline[0])
        m = Integer(currentline[1])



   

        d_holder = d

        norms = []
        
        while d_holder == d:
            
            norms.append(m)

            line = F.readline()
            lines_read += 1

            currentline  = str(line)
            currentline = currentline.replace('\n', ' ')
            currentline = currentline.split(',')
         
            if lines_read > TOTAL_LINES:
                d_holder = 0 
                continue
            else:
                d_holder = Integer(currentline[0])
                m = Integer(currentline[1])



            

        norms = list(set(norms))
        
        if (d % modulus) == mod:

            if len(set(norms)) > 1:
                discfile.write("%s" % d)
                discfile.write("%s" % "\n")


            

        
        
    discfile.close() 
    F.close()





if len(sys.argv) < 2:
    searchfilename = raw_input("search data file name (without .txt):  ")
else:
    searchfilename = str(sys.argv[1])

if len(sys.argv) < 3:
    modulus = 1
    mod = 0
else:
    modulus = int(sys.argv[2])
    mod = int(sys.argv[3])

# searchfilename should contain the sorted ideal data


if modulus != 1:    
    discfilename = searchfilename+"_discs_"+str(modulus)+"_"+str(mod)
else:  
    discfilename = searchfilename+"_discs"



timefilename_ideals = discfilename+"_time"
start = time.time()
full_3_rank_idealstep(searchfilename, discfilename, modulus, mod)
idealtime =  time.time() - start


FILE_time = open(str(timefilename_ideals)+".txt", 'a+')
FILE_time.write("%s" % idealtime)
FILE_time.write("%s" % "\n")
FILE_time.close()
    
    
print(discfilename, "done finding discriminants")
