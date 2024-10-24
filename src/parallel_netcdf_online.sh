#!/bin/bash
#
# SCRIPT TO PARALLELIZED THE ANALYSIS OF THE COBALT OUTPUT NETCDF FILES

# RUN MATALB FUNCTION TO GET EXPERIMENTATION NAME LIST
matlab -batch -nodesktop - nodisplay -nojvm "experiment_name()"

# WAIT FOR MATLAB TO BE DONE 
wait

# READ THE OUTPUTS
result=$(cat experiment_name.txt)
cat experiment_name.txt

# COUNT THE NUMBER OF LINES IN OUTPUTS
num_lines=$(wc -l < experiment_name.txt)

# RUN THE NETCDF ANALYSIS FOR EVERY EXPERIMENTATION NAME 
for ((i=1; i<=num_lines; i++))
do  
    # GET THE TEXT IN EACH LINE
    name=$(sed "${i}q;d" experiment_name.txt)
    echo "Extracted name: $name"

    # RUN MATALB FOR EACH EXPERIMENT NAME 
    matlab -nodesktop - nodisplay -nojvm -r "netcdf_read_FEISTY_Online_BATS('$name'); exit" &
done

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait
