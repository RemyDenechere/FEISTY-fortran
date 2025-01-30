% GET THE LIST OF SUBFOLDER IN the FOLDER EXP_NAME
% 
% Rémy Denéchère <rdenechere@ucsd.edu>
%
% USAGE: getSubDir()dir_FE  
%        getSubDir('Consumption')
%        matlab -batch "getSubDir()"
%        matlab -batch "getSubDir('Consumption')"
%
function [EXP_LIST, YR_RUN] = getExpList(EXP_NAME, LOC)
    arguments
        EXP_NAME        char = 'FEISTY--non-vertical'
        LOC             char = 'BATS'
    end 

    % path to directory
    DIR_EXP = ['../../COBALT_output/parallel/' LOC '/' EXP_NAME];

    % Check if the input is a valid directory
    if ~isfolder(DIR_EXP)
        error('The specified path is not a valid directory. Check DIR_EXP');
    end
    LIST_SUBDIR = dir(DIR_EXP);
    LIST_SUBDIR = {LIST_SUBDIR.name};

    % Define variables
    EXP = "";
    YR = zeros(1, length(LIST_SUBDIR)-2);

    for i = 3:length(LIST_SUBDIR)
        FOLDER = LIST_SUBDIR{i};
        idx = strfind(FOLDER, 'yr_');

        EXP(i-2, 1) = string(FOLDER(1:(idx+2)));
        YR(i-2)  = str2num(FOLDER((idx+3):end));
    end 
    
    EXP_LIST = unique(EXP);
    YR_RUN = max(YR);

    FID = fopen('experiment_name.txt', 'w');  % Open a file for writing
    fprintf(FID, '%s\n', EXP_LIST);  % Write the result to the file
    fclose(FID);  % Close the file

    FID = fopen('nmb_yr.txt', 'w');  % Open a file for writing
    fprintf(FID, '%s\n', num2str(YR_RUN));  % Write the result to the file
    fclose(FID);  % Close the file
end 
