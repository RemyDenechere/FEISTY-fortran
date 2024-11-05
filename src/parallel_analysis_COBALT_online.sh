#!/bin/bash
#
# Rémy Denéchère <rdenechere@ucsd.edu>
#
# USAGE: ./parallel_analysis_COBALT_online.sh 
# 
# SCRIPT TO PARALLELIZED THE ANALYSIS OF THE COBALT OUTPUT NETCDF FILES
FILE='experiment_name.txt'

# INPUT PARAMETERS:
if [ "$#" -eq 2 ]; then 
    # ASSIGN ARGUMENT
    LOC="$1"
    NUM_YEAR="$2" 

else
    echo "wrong number of arguments."
    echo "USAGE: ./parallel_analysis_COBALT_online.sh <Experimentation location> <Number of Years> "
    exit 1
fi

if [ "$NUM_YEAR" -gt 29 ]; then
    echo " The Number of year excide 30, is currently "$NUM_YEAR". The model fails at year 30 so far! "
fi


# IF experiment_name.txt ALREADY EXIST THEN CLEAR IT
if [ -f "$FILE" ]; then
	rm -f "$FILE"
fi

# RUN MATALB FUNCTION TO GET EXPERIMENTATION NAME LIST
matlab -batch "experiment_name();" -nodesktop -nosplash -nojvm 

# WAIT FOR MATLAB TO BE DONE 
wait

# READ THE OUTPUTS
result=$(cat experiment_name.txt)
cat experiment_name.txt

# COUNT THE NUMBER OF LINES IN OUTPUTS
num_lines=$(wc -l < experiment_name.txt)

# PRINT SIMULATION PARAMETERS:
echo "Start analysis netcdf output from COBALT online for the "$num_lines" experiments "

# RUN THE NETCDF ANALYSIS FOR EVERY EXPERIMENTATION NAME 
start_time=$(date +%s)
for ((i=1; i<=num_lines; i++))
do  
    # GET THE TEXT IN EACH LINE
    name=$(sed "${i}q;d" experiment_name.txt)
    echo "Extracted name: $name"

    # RUN MATALB FOR EACH EXPERIMENT NAME 
    matlab -batch "netcdf_read_FEISTY_Online_BATS('$name', '$LOC', $NUM_YEAR)" -nodesktop -nodisplay &
done

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait
end_netcdf_time=$(date +%s)

echo "Start making visualisation for the "$num_lines" COBALT online experiments "

# RUN THE VISUALISATION FOR ALL THE EXPERIMENTATION NAMES
for ((i=1; i<=num_lines; i++))
do  
    # GET THE TEXT IN EACH LINE
    name=$(sed "${i}q;d" experiment_name.txt)
    
    # RUN MATALB FOR EACH EXPERIMENT NAME
    matlab -batch "vis_FEISTY_Online_BATS(false, '$name', '$LOC', $NUM_YEAR)" -nodesktop -nodisplay -nosplash &
done

# WAIT FOR ALL BACKGROUND PROCESSES (MATLAB JOBS) TO FINISH
wait
end_vis_time=$(date +%s)

# PRINT SIMULATION TIME 
netcdf_time=$((end_netcdf_time-start_time))
vis_time=$((end_vis_time-end_netcdf_time))
echo "The netcdf analysis and visulation are done for the "$num_lines" experiments !!!"
echo " Time execution netcdf_read_FEISTY_Online_BATS.m "$netcdf_time" seconds"
echo " Time execution vis_FEISTY_Online_BATS.m         "$vis_time"    seconds"
