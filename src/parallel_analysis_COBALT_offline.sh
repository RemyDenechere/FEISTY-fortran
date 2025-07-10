#!/bin/bash
#
# Rémy Denéchère <rdenechere@ucsd.edu>
#
# USAGE: ./parallel_analysis_COBALT_offline.sh 20 2D
# 
# SCRIPT TO PARALLELIZED THE ANALYSIS OF THE OUTPUT FROM COBALT OFFLINE AT EACH LOCATION TESTED 
# THE SCRIPT WILL RUN THE MATLAB FUNCTION netcdf_read_COBALT_offline.m, AND vis_COBALT_Offline.m,
# 
#
# Function to kill all child processes
cleanup() {
    echo "Terminated by user (Ctrl+C)."
    # Kill all child processes of this script
    pkill -P $$
    exit 1
}

# INPUT PARAMETERS:
if [ "$#" -eq 2 ]; then 
    # ASSIGN ARGUMENT
    SPINUP_YEARS="$1"
    EXP_NAME="$2"
    MULTIYEAR='false' # default value
elif [ "$#" -eq 3 ]; then 
    # ASSIGN ARGUMENT
    SPINUP_YEARS="$1"
    EXP_NAME="$2"
    MULTIYEAR="$3"
else
    echo "wrong number of arguments."
    echo "USAGE: ./parallel_analysis_COBALT_offline.sh <Spinup year> <Experimentation Name> <MultiYear>"
    echo "Default experimentation name is <20> <2D> <true/false>"
    exit 1
fi

locations=( BATS ) # list of locations BATS GBK GMX GMX_2 
echo ""
echo "--------------------------------------------------------------------"
echo " Running for the current location list: ${locations[@]} "

# Loop through each location and run the script
start_time=$(date +%s)

echo ""
echo "--------------------------------------------------------------------"
echo "Analysing COBALT offline for $SPINUP_YEARS "
echo "--------------------------------------------------------------------"
echo ""
for loc in "${locations[@]}"; do
    # RUN THE NETCDF ANALYSIS OF THE OFFLINE COBALT 
    if   [ "$MULTIYEAR" = "false" ]; then
    	matlab -batch "netcdf_read_COBALT_Offline(loc='$loc', exp='$EXP_NAME', yr_spinup='$SPINUP_YEARS');" -nodesktop -nosplash &
    elif [ "$MULTIYEAR" = "true" ]; then 
        matlab -batch "netcdf_read_COBALT_Offline(loc='$loc', exp='$EXP_NAME', yr_spinup='$SPINUP_YEARS', multiyear=true);" -nodesktop -nosplash &
    fi 
done 

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait

echo ""
echo "--------------------------------------------------------------------"
echo "Visualisation of COBALT offline for $SPINUP_YEARS "
echo "--------------------------------------------------------------------"
echo ""

for loc in "${locations[@]}"; do
    # RUN THE NETCDF ANALYSIS OF THE OFFLINE COBALT 
    if   [ "$MULTIYEAR" = "false" ]; then
    	matlab -batch "vis_COBALT_Offline(loc='$loc', exp='$EXP_NAME', yr_spinup='$SPINUP_YEARS');" -nodisplay -nosplash&
    elif [ "$MULTIYEAR" = "true" ]; then
        matlab -batch "vis_COBALT_Offline(loc='$loc', exp='$EXP_NAME', yr_spinup='$SPINUP_YEARS', multiyear=true);" -nodisplay -nosplash&
    fi
done 

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait
echo "--------------------------------------------------------------------"
echo " "
echo "The netcdf analysis and visulation are done for the $SPINUP_YEARS Spinup Years at each location: ${locations[@]}"
echo " "
echo "--------------------------------------------------------------------"
# PRINT SIMULATION TIME 
end_time=$(date +%s)
time=$((end_time-start_time))
echo "The script took $time seconds to run"
