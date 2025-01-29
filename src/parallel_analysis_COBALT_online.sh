#!/bin/bash
#
# Rémy Denéchère <rdenechere@ucsd.edu>
#
# USAGE: ./parallel_analysis_COBALT_online.sh BATS Consumption
# 
# SCRIPT TO PARALLELIZED THE ANALYSIS OF THE OUTPUT FROM COBALT-FEISTY ONLINE AND OFFLINE
# THE SCRIPT WILL RUN THE MATLAB FUNCTION netcdf_read_FEISTY_Online_BATS.m, netcdf_read_FEISTY_Offline_BATS.m,
#  vis_FEISTY_Online_BATS.m, AND vis_FEISTY_Offline_BATS.m, FOR EACH EXPERIMENTATION NAME


# FILE NAMES
FILE_EXP='experiment_name.txt'
FILE_YEAR='nmb_yr.txt'

# INPUT PARAMETERS:
if [ "$#" -eq 2 ]; then 
    # ASSIGN ARGUMENT
    LOC="$1"
    EXP_NAME="$2" 
else
    echo "wrong number of arguments."
    echo "USAGE: ./parallel_analysis_COBALT_online.sh <Experimentation location> <Experimentation Name> "
    exit 1
fi

# IF experiment_name.txt ALREADY EXIST THEN CLEAR IT
if [ -f "$FILE_EXP" ]; then
	rm -f "$FILE_EXP"
fi

if [ -f "$FILE_YEAR" ]; then
	rm -f "$FILE_YEAR"
fi

# RUN MATALB FUNCTION TO GET EXPERIMENTATION NAME LIST
matlab -batch "getExpList('$EXP_NAME', '$LOC');" -nodesktop -nosplash -nojvm 

# WAIT FOR MATLAB TO BE DONE 
wait

# READ THE LIST of EXPERIMENTATION and NUMBER OF YEAR TO RUN THE MODEL:
EXP_LIST=$(cat experiment_name.txt)
NUM_YEAR=$(cat nmb_yr.txt)

# if [ "$NUM_YEAR" -gt 29 ]; then
#     echo " The Number of year excide 30, is currently "$NUM_YEAR". The model fails at year 30 so far! "
# fi

# COUNT THE NUMBER OF LINES IN OUTPUTS
NUM_LINES=$(wc -l < experiment_name.txt)

# PRINT SIMULATION PARAMETERS:
echo "Start analysis netcdf output from COBALT online for the "$NUM_LINES" experiments spined up over "$NUM_YEAR" yr(s)"

# RUN THE NETCDF ANALYSIS OF THE ONLINE COBALT-FEISTY FOR EVERY EXPERIMENTATION NAME 
start_time=$(date +%s)
for ((i=1; i<=NUM_LINES; i++))
do  
    # GET THE TEXT IN EACH LINE
    name=$(sed "${i}q;d" experiment_name.txt)
    echo "Extracted name: $name"

    # RUN MATALB FOR EACH EXPERIMENT NAME 
    matlab -batch "netcdf_read_FEISTY_Online_BATS('$name', '$LOC', '$NUM_YEAR', '$EXP_NAME' )" -nodesktop -nodisplay &
done

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait

end_netcdf_time=$(date +%s)

# RUN THE NETCDF ANALYSIS OF THE OFFLINE COBALT-FEISTY FOR EVERY EXPERIMENTATION NAME:
echo "Start analysis netcdf output from COBALT offline at " $LOC
matlab -batch "netcdf_read_FEISTY_Offline_BATS('$LOC')" -nodesktop -nodisplay


# RUN THE VISUALISATION FOR ALL THE EXPERIMENTATION NAMES
echo "Start making visualisation for the "$NUM_LINES" COBALT online experiments "
for ((i=1; i<=NUM_LINES; i++))
do  
    # GET THE TEXT IN EACH LINE
    name=$(sed "${i}q;d" experiment_name.txt)
    
    # RUN MATALB FOR EACH EXPERIMENT NAME
    matlab -batch "vis_FEISTY_Online_BATS(true, '$name', '$LOC', '$NUM_YEAR', '$EXP_NAME')" -nodesktop -nodisplay -nosplash &
done

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait
end_vis_time=$(date +%s)

# RUN THE VISUALISATION FOR THE OFFLINE COBALT-FEISTY
echo "Start making visualisation for the COBALT offline at " $LOC
matlab -batch "vis_FEISTY_Offline_BATS('$LOC')" -nodesktop -nodisplay -nosplash

# PRINT SIMULATION TIME 
netcdf_time=$((end_netcdf_time-start_time))
vis_time=$((end_vis_time-end_netcdf_time))
echo "The netcdf analysis and visulation are done for the "$NUM_LINES"  "$EXP_NAME" experiments!!!"
echo " Time execution netcdf_read_FEISTY_Online_BATS.m "$netcdf_time" seconds"
echo " Time execution vis_FEISTY_Online_BATS.m         "$vis_time"    seconds"
