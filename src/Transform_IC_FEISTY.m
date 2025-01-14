%% Create a netcdf file for the 2D version: 
dir_input='/project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/BATS/FEISTY_2023_10_spinup_subset.nc';
dir_output='/project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/BATS/FEISTY_2D_2023_10_spinup_subset.nc';

% Open the input NetCDF file
ncid = netcdf.open(dir_input, 'NOWRITE');

% Get the number of variables in the file
[~, nvars, ~, ~] = netcdf.inq(ncid);

% Create the output NetCDF file
outid = netcdf.create(dir_output, 'CLOBBER');

try
    % Loop through all variables in the input file
    for varid = 0:nvars-1
        % Get variable information
        [varname, xtype, dimids, ~] = netcdf.inqVar(ncid, varid);

        % Read the variable data
        data = netcdf.getVar(ncid, varid);

        % If the variable has at least 3 dimensions, sum along the 3rd dimension
        if length(dimids) >= 3
            data = sum(data, 3, 'omitnan'); % Summing along the 3rd dimension
        elseif length(dimids) == 0
            [dimname, dimlen] = netcdf.inqDim(ncid, 0);
            netcdf.defDim(outid, dimname, dimlen);
        end

        % Define dimensions in the output file
        for i = 1:length(dimids)
            netcdf.defDim(outid, dimname, dimlen);
        end

        % Define the variable in the output file
        outDimIds = dimids(dimids < 3); % Exclude higher dimensions
        outVarId = netcdf.defVar(outid, varname, xtype, outDimIds);

        % Write the modified data to the new file
        netcdf.putVar(outid, outVarId, data);
    end

    % Close the output file
    netcdf.close(outid);
    disp(['Modified data saved to ', outputFile]);
catch ME
    % Close files in case of error
    netcdf.close(ncid);
    netcdf.close(outid);
    rethrow(ME);
end

% Close the input file
netcdf.close(ncid);