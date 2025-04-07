#!/bin/bash
#
# Rémy Denéchère <rdenechere@ucsd.edu>
#
# USAGE: ./parallel_analysis_COBALT.sh FEISTY--non-vertical
# 
# SCRIPT TO PARALLELIZED THE ANALYSIS OF THE OUTPUT FROM COBALT-FEISTY ONLINE AND OFFLINE
# THE SCRIPT WILL RUN THE MATLAB FUNCTION netcdf_read_FEISTY_Online_BATS.m, netcdf_read_FEISTY_Offline_BATS.m,
#  vis_FEISTY_Online_BATS.m, AND vis_FEISTY_Offline_BATS.m, FOR EACH EXPERIMENTATION NAME


# FILE NAMES
FILE_EXP='experiment_name.txt'
FILE_YEAR='nmb_yr.txt'

# INPUT PARAMETERS:
if [ "$#" -eq 1 ]; then 
    # ASSIGN ARGUMENT
    EXP_NAME="$1" 
else
    echo "wrong number of arguments."
    echo "USAGE: ./loop_analysis_COBALT.sh <Experimentation Name> "
    echo "Default experimentation name is <FEISTY--non-vertical> "
    exit 1
fi

locations=(GOM) # list of locations BATS GOM GMX CCE NS 
echo ""
echo "--------------------------------------------------------------------"
echo " Running for the current location list: ${locations[@]} "

# Loop through each location and run the script
start_time=$(date +%s)
for loc in "${locations[@]}"; do
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Analysing COBALT online and offline at location: $loc"
    echo "--------------------------------------------------------------------"
    echo ""

    # IF experiment_name.txt and nmb_yr.txt ALREADY EXIST THEN CLEAR IT
    if [ -f "$FILE_EXP" ]; then
        rm -f "$FILE_EXP"
    fi
    if [ -f "$FILE_YEAR" ]; then
        rm -f "$FILE_YEAR"
    fi

    # RUN MATALB FUNCTION TO GET EXPERIMENTATION NAME LIST          
    matlab -batch "getExpList('$EXP_NAME', '$loc');" -nodesktop -nosplash -nojvm 

    # WAIT FOR MATLAB TO BE DONE 
    wait

    # READ THE LIST of EXPERIMENTATION and NUMBER OF YEAR TO RUN THE MODEL:
    EXP_LIST=$(cat experiment_name.txt)
    NUM_YEAR=$(cat nmb_yr.txt)

    # COUNT THE NUMBER OF LINES IN OUTPUTS
    NUM_LINES=$(wc -l < experiment_name.txt)

    # PRINT SIMULATION PARAMETERS:
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Start analysis netcdf output from COBALT online at $loc for the $NUM_LINES experiments spined up over $NUM_YEAR yr(s)"

    # RUN THE NETCDF ANALYSIS OF THE ONLINE COBALT-FEISTY FOR EVERY EXPERIMENTATION NAME 
    for ((i=1; i<=NUM_LINES; i++))
    do  
        # GET THE TEXT IN EACH LINE
        name=$(sed "${i}q;d" experiment_name.txt)
        echo "Extracted name: $name"

        # RUN MATALB FOR EACH EXPERIMENT NAME 
        matlab -batch "netcdf_read_FEISTY_Online_BATS('$name', '$loc', '$NUM_YEAR', '$EXP_NAME' )" -nodesktop -nodisplay &
    done

    # WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
    wait

    # RUN THE NETCDF ANALYSIS OF THE OFFLINE COBALT-FEISTY FOR EVERY EXPERIMENTATION NAME:
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Start analysis netcdf output from COBALT offline at " $loc
    matlab -batch "netcdf_read_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay


    # RUN THE VISUALISATION FOR ALL THE EXPERIMENTATION NAMES
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Start making visualisation for the "$NUM_LINES" COBALT online experiments "
    for ((i=1; i<=NUM_LINES; i++))
    do  
        # GET THE TEXT IN EACH LINE
        name=$(sed "${i}q;d" experiment_name.txt)
        
        # RUN MATALB FOR EACH EXPERIMENT NAME
        matlab -batch "vis_FEISTY_Online_BATS(true, '$name', '$loc', '$NUM_YEAR', '$EXP_NAME')" -nodesktop -nodisplay -nosplash &
    done

    # WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
    wait
    
    # RUN THE VISUALISATION FOR THE OFFLINE COBALT-FEISTY
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Start making visualisation for the COBALT offline at " $loc
    matlab -batch "vis_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay -nosplash

    echo "The netcdf analysis and visulation are done for the $NUM_LINES  experiment in $EXP_NAME for $loc"

    # RUN MATALB ANALYSIS OF ALL EXPERIMENT EXPERIMENTATION NAME LIST
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Start comparison analysis of the $NUM_LINES experiments in $EXP_NAME for $loc"
    matlab -batch "vis_Comparison_exp("exp", '$EXP_NAME', "loc", '$loc');" -nodesktop -nosplash -nojvm
done

# PRINT SIMULATION TIME 
end_time=$(date +%s)
time=$((end_time-start_time))
echo "The script took $time seconds to run"
