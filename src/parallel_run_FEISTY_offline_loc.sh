#!/bin/bash

# List of locations
locations=(BATS GOM GMX GMX_2) # BATS CCE GOM NS GMX GOM_2
exp='2D'

# Loop through each location and run the script
for loc in "${locations[@]}"; do
    echo "Running FEISTY offline at location: $loc"
            
    # 
    if [ -d "../output/netcdf/offline/$loc/$exp" ]; then 
        echo "Directory to save netcdf data for $loc/$exp exists, cleaning it up"
        rm -rf ../output/netcdf/offline/$loc/$exp/*
    else
        echo "Directory to save netcdf data for $loc/$exp does not exists"
        mkdir -p ../output/netcdf/offline/$loc/$exp
        if [ -d "../output/netcdf/offline/$loc/$exp" ]; then 
            echo "Directory created"
        else
            echo "Directory creation failed"
            exit 1
        fi
    fi

    # change location and run spinup
    sed -i 's|loc = ".*"|loc = "'"$loc"'"|' input.nml
    sed -i 's|Spinup_logical = ..*.|Spinup_logical = .true.|' input.nml
    ./FEISTY

    # Move IC condition file to the location folder
    echo "moving IC to proper directory: /project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/"$loc"/"
    yes | cp -i ../output/netcdf/offline/$loc/$exp/FEISTY_2D_2023_10_spinup_subset.nc /project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/"$loc"/

    # run non spinup 
    sed -i 's|Spinup_logical = ..*.|Spinup_logical = .false.|' input.nml
    ./FEISTY

    # RUN MATLAB ANALYSIS FOR THE LOCATION
    matlab -batch "netcdf_read_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay -nosplash
    matlab -batch "vis_FEISTY_Offline_BATS('$loc')" -nodesktop -nodisplay -nosplash
done

make clean
