#!/bin/bash

# List of locations
locations=(BATS CCE GOF NS) # 

# Loop through each location and run the script
for loc in "${locations[@]}"; do
    echo "Running FEISTY offline at location: $loc"
            
    # 
    if [ -d "../output/netcdf/offline/$loc" ]; then 
        echo "Directory to save netcdf data for $loc exists"
    else
        echo "Directory to save netcdf data for $loc does not exists"
        mkdir -p ../output/netcdf/offline/$loc
        if [ -d "../output/netcdf/offline/$loc" ]; then 
            echo "Directory created"
        else
            echo "Directory creation failed"
            exit 1
        fi
    fi


    # change location and run spinup
    sed -i 's|character(LEN=280), parameter :: loc = ".*"|character(LEN=280), parameter :: loc = "'"$loc"'"|' Parameters.f90
    sed -i 's|logical :: Spinup = ..*.|logical :: Spinup = .true.|' Run_physiology.f90
    make
    ./FEISTY
    make clean

    # Move IC condition file to the location folder
    cp ../output/netcdf/offline/$loc/FEISTY_2D_2023_10_spinup_subset.nc /project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/"$loc"/

    # run non spinup 
    sed -i 's|logical :: Spinup = ..*.|logical :: Spinup = .false.|' Run_physiology.f90
    make
    ./FEISTY
    make clean

    # RUN MATLAB ANALYSIS FOR THE LOCATION
    matlab -batch "netcdf_read_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay -nosplash
    matlab -batch "vis_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay -nosplash
done

make clean