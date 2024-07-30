% Visualize output of FEISTY
% CESM FOSI
% Time series plots and maps
close all
clear all
addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')
%% Root directory: 
param.Rockfish =  false; % true; %  
param = param_setup(param);

%! get directory containing output
exp = 'COBALT_offline_BATS_';
Spinup = {'_Spinup_Time_Serie', ''}; 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE', 'dZm', 'dZl'}; 


%! get directory containing output
dir = '../output/Matlab_Average/'; 
save_dir = '../Fig/';
 
% new saving paths: -------------------------------------------------------
fpath='../Fig/'; % path with the data
if (~isfolder(fpath))
    mkdir(fpath)
end

%% colors
cm10=[0.5 0.5 0;... %tan/army
    0 0.7 0;...     %g
    1 0 1;...       %m
    1 0 0;...       %r
    0.5 0 0;...     %maroon
    0/255 206/255 209/255;... %turq
    0 0.5 0.75;...  %med blue
    0 0 0.75;...    %b
    0.5 0.5 0.5; ...%med grey
    0 0 0];...      %black

% set(groot,'defaultAxesColorOrder', cm10);

%% plot Spinup 
% Load Data: -------------------------------------------------------------- 
%! Spinup time series: 
figure(1)
axes_formating(gcf, "defaultAxesColorOrder", cm10)

load([dir exp 'Time_Means' Spinup{1} '.mat']);

% Sum per functional group: 
F_tmean = Sf_tmean + Mf_tmean;
P_tmean = Sp_tmean + Mp_tmean + Lp_tmean;
D_tmean = Sd_tmean + Md_tmean + Ld_tmean;

t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding","compact");
xtime = length(time);

% plot all sizes: 
nexttile
hold on 
for i = 1:(length(var)-2)
    plot(time(1:xtime), eval([var{i} '_tmean(1:xtime)']), '-')
end 
hold off 
legend(var{1:(end-2)}, 'Location', 'best')
set(gca, "YScale", "log", "XLim", [0, xtime*1.2], "Ylim", [10^(-7) 10^(2)])
title("All size")

% Plot all functional groups:
nexttile
hold on 
plot(time(1:xtime), F_tmean(1:xtime), ...
     time(1:xtime), P_tmean(1:xtime), ...
     time(1:xtime), D_tmean(1:xtime), ...
     time(1:xtime), BE_tmean(1:xtime))
hold off 
legend('Forage', 'Pelagics', 'Demersals', 'Benthos', 'Location', 'east')
set(gca, "YScale", "log", "XLim", [0, xtime*1.2], "Ylim", [10^(-3) 10^(2)])
title("Functional group")
set(gca, "YScale", "log")

title(t, [exp(1:(end-1)) Spinup{1}], Interpreter = 'none')
ylabel(t, 'Integrated biomass over water column (g WW m-2)')
xlabel(t, 'Spinup time (days)')

save_graph(gcf, "png", [save_dir exp(1:(end-1)) Spinup{1}], 22, 12)
%% plot time series: 
%! Time series: 
fig = figure(2);
axes_formating(gcf, "defaultAxesColorOrder", cm10)

load([dir exp 'Time_Means' Spinup{2} '.mat']);

% Sum per functional group: 
F_tmean = Sf_tmean + Mf_tmean;
P_tmean = Sp_tmean + Mp_tmean + Lp_tmean;
D_tmean = Sd_tmean + Md_tmean + Ld_tmean;

t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding","compact");
start_date = datetime("2004-01-01");
end_date   = datetime("2004-12-30");
time = start_date:end_date;

nexttile
hold on 
for i = 1:(length(var)-3)
    plot(time, eval([var{i} '_tmean']), '-')
end 
hold off 
legend(var{1:(end-3)})
set(gca, "YScale", "log", 'Ylim', [10^(-5) 5])
title("All size")

nexttile
hold on 
plot(time, F_tmean, time, P_tmean, time, D_tmean)
hold off 
set(gca, "YScale", "log", 'Ylim', [10^(-5) 10^(2)])
legend('Forage', 'Pelagics', 'Demersals', 'Benthos')
title("Functional group")
title(t, [exp 'Time_Means' Spinup{2}], Interpreter = 'none')
ylabel(t, 'Integrated biomass over water column (g WW m-2)')
xlabel(t, 'Time (days)')

save_graph(gcf, "png", [save_dir exp 'Time_Means' Spinup{2} ], 22, 12)

%% plot Depth average: 
%! Time series: 
figure(3);
axes_formating(gcf, "defaultAxesColorOrder", cm10)

load([dir exp 'Depth_Means' Spinup{2} '.mat']);

% Sum per functional group: 
F_zmean = Sf_zmean + Mf_zmean;
P_zmean = Sp_zmean + Mp_zmean + Lp_zmean;
D_zmean = Sd_zmean + Md_zmean + Ld_zmean;

t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding","compact");

nexttile
hold on 
for i = 1:(length(var)-3)
    plot(eval([var{i} '_zmean']), -depth, '-')
end 
hold off 
set(gca, "XScale", 'log', 'XLim', [10^(-5) 10])
legend(var{1:(end-3)})
title("All size")

nexttile
hold on 
plot(F_zmean, -depth, P_zmean, -depth, D_zmean, -depth)
hold off 
set(gca, "XScale", "log", 'XLim', [10^(-5) 10])
legend('Forage', 'Pelagics', 'Demersals', 'Benthos')
title("Functional group")
title(t, [exp 'Depth_Means' Spinup{2}], Interpreter = 'none')
xlabel(t, 'Time averaged biomass over depth (g WW m-2)')
ylabel(t, 'Layers')

save_graph(gcf, "png", [save_dir exp 'Depth_Means' Spinup{2}], 22, 12)

%% plot diagnostic Time Seire 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld'};
var_diag = {'f', 'cmax', 'cons', 'met', 'mu_p', 'mu_f', 'mu_a', 'mu',...
            'E_A', 'Fout', 'Repro', 'f_Zm', 'f_Zl', 'f_Sf', 'f_Sp', 'f_Sd',... 
            'f_Mf', 'f_Mp', 'f_Md', 'f_Lp', 'f_Ld', 'f_BE'};
FuncGrp = {'F_', 'P_', 'D_'};
dimension_average = {'_tmean'};
dimensions = {'time'};
load(['../output/Matlab_Average/' exp 'Time_Means_Diag' Spinup{2} '.mat'])

%!! Calcul mean per functional group:
for j = 1:length(dimension_average)
    for i = 1:length(var_diag)
        eval(['F_' var_diag{i} dimension_average{j} ' = Sf_' var_diag{i} dimension_average{j} ' + Mf_' var_diag{i} dimension_average{j} ';']);
        eval(['P_' var_diag{i} dimension_average{j} ' = Sp_' var_diag{i} dimension_average{j} ' + Md_' var_diag{i} dimension_average{j} ' + Lp_' var_diag{i} dimension_average{j} ';']);
        eval(['D_' var_diag{i} dimension_average{j} ' = Sd_' var_diag{i} dimension_average{j} ' + Md_' var_diag{i} dimension_average{j} ' + Ld_' var_diag{i} dimension_average{j} ';']);
    end 
end

% ! Plot per group of diagnostic variable
close all 
grp(1).name = 'Mortality rates'     ; grp(1).idx = 5:8;                 grp(1).panel_grid = [2, 2];
grp(2).name = 'Feeding levels'      ; grp(2).idx = 12:22;               grp(2).panel_grid = [3, 4];
grp(3).name = 'Physiological rates' ; grp(3).idx = [1:4, 9:11];         grp(3).panel_grid = [3, 3];
grp(1).leg_loc = 'best'             ; grp(2).leg_loc = 'best';          grp(3).leg_loc = 'best'; 
n=3;

% Functional groups: ------------------------------------------------------
for i = 1:3
    n = n+1;
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10)

    t = tiledlayout(grp(i).panel_grid(1), grp(i).panel_grid(2), ...
                    "TileSpacing", "compact", "Padding", "compact");
  
    % loop over diagnostic for each group:
    for j = 1:length(grp(i).idx)
        ti = nexttile;
        hold on
        % Loop over all fish for each diagnostic: 
        for v = 1:length(FuncGrp) 
            plot(ti, eval(dimensions{1}), eval([FuncGrp{v} var_diag{grp(i).idx(j)} dimension_average{1}]))
        end 
        hold off 
        title(ti, var_diag{grp(i).idx(j)}, Interpreter='none')
    end
    L = legend(FuncGrp, 'Location', grp(i).leg_loc);
    title(t, [exp 'Diagnostic_' grp(i).name '_' dimension_average{1}(2:end) '_Functional_grp'], Interpreter='none')
    save_graph(gcf, "png", [save_dir exp 'Diagnostic_' grp(i).name '_' dimension_average{1}(2:end) '_Functional_grp'], 16, 12)
end

%% Check Initial condition for Online simulations: 
load(['../output/Matlab_Average/' 'COBALT_IC' '.mat'])
% Per functional group: 
F_spacemean = Sf_spacemean + Mf_spacemean;
P_spacemean = Sp_spacemean + Mp_spacemean + Lp_spacemean;
D_spacemean = Sd_spacemean + Md_spacemean + Ld_spacemean;

figure(4)
axes_formating(gcf, "defaultAxesColorOrder", cm10)
t = tiledlayout(1,2,"TileSpacing","compact","Padding","compact");

% plot all sizes: 
nexttile
hold on 
for i = 1:(length(var)-2)
    plot(eval([var{i} '_zmean']), -depth)
end
hold off
set(gca, "XScale", "log", ...
         "Xlim", [10^(-5) 80])
legend(var{1:(end-2)})
title("All Sizes")

% plot Functional group:
nexttile
hold on 
plot(F_spacemean, -depth, ...
     P_spacemean, -depth, ...
     D_spacemean, -depth, ...
     BE_spacemean, -depth)
hold off
set(gca, "XScale", "log", ...
         "Xlim", [10^(-5) 80])
legend('Forage', 'Pelagic', 'Demersal', 'Benthos')
title("Functional group")

xlabel(t, "Biomass (g WW m-3)")
ylabel(t, "Layer depth")
title(t, "Initial Conditions for COBALT Online")

save_graph(gcf, "png", [save_dir 'Initial_Conditions_for_COBALT_Online'], 16, 12)


%% Plot forcing data: 

%! Load data: 
load([dir exp 'Time_Depth_Means_forcing_files'  '.mat'])
load([dir exp 'Time_Means_forcing_files'  '.mat'])
load([dir exp 'Depth_Means_forcing_files'  '.mat'])

%! forcing variable names: 
var = {'thetao', 'nmdz', 'jhploss_n_Mdz', 'nlgz', 'jhploss_n_Lgz', 'Pop_btm'};

%! Time periode: 
start_date = datetime("2004-01-01");
end_date   = datetime("2004-12-31");
time = start_date:end_date;

%! Plot forcing data: ------------------------------------------------
fig = figure(5);
axes_formating()

t = tiledlayout(1, 2, "TileSpacing","compact", "Padding","compact");

% Panel 1: time average: 
t1 = nexttile(t); 
hold(t1, 'all')
for i = 1:length(var)
    plot(t1, time, eval([var{i} '_tmean']), '-')
end 
hold(t1, 'off')
set(t1, 'YScale', 'log', 'Ylim',[1.74969307072006e-05 1749.69307072006]);
title(t1, 'Time average')
legend(t1, var{:}, Interpreter = 'none', EdgeColor = 'none', Color = 'none', ...
    Position = [0.179283105674276 0.269803790877946 0.223263506063947 0.271164021164021]);

% Panel 2: depth average
t2 = nexttile(t); 
hold(t2, 'all')
for i = 2:length(var)
    plot(t2, eval([var{i} '_zmean']), -depth,  '-')
end 
hold(t2, 'off')
t2.XLabel.String = 'gC WW m-3';
t2.XLim = [-0.00404600305473225, 0.245953996945268];
t2.YLim = [-75.9854668425813, 4.01453315741872];
title(t2, 'Depth average')


% add axis:
t3 = copyobj(t2, t);
plot(t3, eval([var{1} '_zmean']), -depth,  '-', 'Color',  [1.00,0.41,0.16])

% Change axis properties: 
t3.XAxisLocation = 'bottom';
t3.XAxis.Color = [1.00,0.41,0.16];
t3.Color = 'none';
%t3.XLabel.Position(3) = t2.XLabel.Position(3); 
%t3.XLabel.Position(2) = t3.XLabel.Position(2)+5;
t3.XRuler.TickLabelGapOffset = 35;
t3.XLabel.String = 'Temperature'; 
t3.XAxis.TickLabelColor = [1.00,0.41,0.16];
t3.XLim = [-3.23244336814286 21.7675566318571];
t3.YLim = [-75.9997853215371 4.00021467846288];

legend(t2, var{2:end}, Interpreter = 'none', Color = 'none', EdgeColor = 'none', ...
    Position = [0.703623414303576,0.455079749385228,0.223263506063947,0.189705882352941]);  
legend(t3, var{1}, Interpreter = 'none', Color = 'none', EdgeColor = 'none', ...
    Position = [0.703623414303576,0.342804281561458,0.142778390297685,0.044117647058824]);


% Labels
ylabel(t, 'Unit to check!')
xlabel(t, 'Time (days)')
title(t, [exp 'forcing_files'], Interpreter = 'none')

save_graph(gcf, "png", [save_dir exp 'forcing_files' Spinup{2}], 16, 12)

%% Comparison Detritus flux to sea bed between COBALT output and FEISTY 2019
param.Rockfish =  false; % true; %  
param = param_setup(param);

% data from COBALT reanalysis: --------------------------------------------
load([param.rootdir '/Feisty/Fish-MIP/Phase3/QuarterDeg/gfdl-mom6-cobalt2_ctrlclim_expc-bot_15arcmin_global_monthly_1961_2010.mat']); 

%% 
load_unit = "mol m-2 s-1";      % before conversion
unit = 'gC WW m-2 d-1';         % after conversion 
conversion = 6.625*12.01*9.0*24.0*60.0*60.0;
%! BATS coordinate in file: 
idx_lon = find(lon > -64.17);
idx_lat = find(lat <  31.83);
lon_BATS = lon(idx_lon(1):idx_lon(2));
lat_BATS = lat(idx_lat(1)-1:idx_lat(1));
disp(['BATS longitude : -64.17' ])
disp(['BATS latitude  :  31.83' ])
%! dimensions:
dim = size(det_btm); 

det_btm_BATS = det_btm(idx_lon(1):idx_lon(2), idx_lat(1)-1:idx_lat(1), :);
det_btm_BATS = mean(det_btm_BATS, [1, 2]);
det_btm_BATS = squeeze(det_btm_BATS * conversion);


% Time line COBALT output: 
start_date = datetime("2004-01-01");
end_date   = datetime("2004-12-31");
time_1 = start_date:end_date;

% Timeline CABOLAT reanalysis
year = 1961:2010;
years = [];
for i = 1:length(year)
    years = [years, repmat(year(i), 1, 12)];
end 
months = repmat(1:12, 1, length(year));
days = ones(1, length(months));
time_2 = datenum([years', months', days']); 
time_2_datetime = datetime([years', months', days']);
time_2_str = datestr(time_2);

%% plot the two metrics
figure(6)
axes_formating()
hold on 
plot(time_1, Pop_btm_tmean)
plot(time_2_datetime, det_btm_BATS)
hold off
legend('COBALT-1D forcing files', 'COBALT reanalysis')
xlabel('Time (days)')
ylabel('Detritus flux to seafloor (gC WW m-2 d-1)')
title([exp 'Comparison detritus flux'], 'Interpreter', "none")
set(gca, 'Xlim', [start_date, end_date])
save_graph(gcf, 'png', [save_dir exp ...
            'Comparison detritus fluxflux forcing vs reanalysis'] , 14, 11)





