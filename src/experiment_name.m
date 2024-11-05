function [exp_name] = experiment_name()
% ...
%                     nonFmort_sart, nonFmort_end, nonFmort_nbr,...
%                     encounter_sart, encounter_end, encounter_nbr,... 
%                     k_sart, k_end, k_nbr
% Get names of the folders for the experiment to test

% nonFmort = linspace(nonFmort_sart, nonFmort_end, nonFmort_nbr);
% encounter = linspace(encounter_sart, encounter_end, encounter_nbr);
% k = linspace(k_sart, k_end, k_nbr);

nonFmort = ["0", ".250", ".500", ".750", "1"]'; 
encounter= ["70"]; % ["30","50.000","70.000","90.000","110"]';
k = ["1", "10"]';
k50 = ["1", "6.000", "11.000", "16.000", "21"];
loc = "BATS"; 
years = linspace(1, 10, 10);

exp_name = "";
e = 0;
for i = 1:length(nonFmort)
    for j = 1:length(encounter)
        for l = 1:length(k)
            for m = 1:length(k50)
                e = e+1;
                exp_name(1, e) = strcat(loc, "_nonFmort_", nonFmort(i), "_encounter_", ...
                    encounter(j), "_k_", k(l),"_k50_", k50(m), "_yr_"); 
            end 
        end 
    end 
end 

fid = fopen('experiment_name.txt', 'w');  % Open a file for writing
fprintf(fid, '%s\n', exp_name);  % Write the result to the file
fclose(fid);  % Close the file





