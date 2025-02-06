% Visualize output of FEISTY
% CESM FOSI
% Time series plots and maps

function [] = vis_FEISTY_Offline_BATS(loc, exp, rockfish, loc_test)
arguments
    loc       char {mustBeMember(loc, {'BATS', 'CCE', 'GOF', 'NS'})} = 'BATS'
    exp       char                                      = '2D'
    rockfish  logical                                   = true
    loc_test  logical                                   = false
end

addpath('../../Programing-Tutorials/Matlab/Matlab_functions/') 

% dbclear all 
% dbstop in vis_FEISTY_Offline_BATS.m at 206

%% Root directory: 
param.Rockfish = rockfish; % true; %  
param = param_setup(param);
param.loc_test = loc_test;

coupling = 'offline'; 
Spinup = {'_Spinup_Time_Serie', ''};

var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE', 'dZm', 'dZl'}; 


%! get directory containing output
dir_input =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', ...
                            'FEISTY_' coupling '_' loc '_' exp '_'];
dir_input_forcing =['../output/Matlab_Average/', coupling, '/' loc, '/', ];

dir_output =['../Fig/', coupling, '/' loc, '/', exp, '/']; 
if ~exist(dir_output) 
    mkdir(dir_output)
end 
dir_output =['../Fig/', coupling, '/' loc, '/', exp, '/', ...
                loc '_' exp '_' ];

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

load([dir_input 'Time_Means' Spinup{1} '.mat']);

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

title(t, {[loc '_'  coupling '_' exp], ['Time_Means' Spinup{1} ]}, Interpreter = 'none')
ylabel(t, 'Integrated biomass over water column (g WW m-2)')
xlabel(t, 'Spinup time (days)')

save_graph(gcf, "png", [dir_output 'Time_Means' Spinup{1}], 22, 12)
%% plot time series: 
%! Time series: 
figure(2);
axes_formating(gcf, "defaultAxesColorOrder", cm10)

load([dir_input 'Time_Means' Spinup{2} '.mat']);

% Sum per functional group: 
F_tmean = Sf_tmean + Mf_tmean;
P_tmean = Sp_tmean + Mp_tmean + Lp_tmean;
D_tmean = Sd_tmean + Md_tmean + Ld_tmean;

% Set up time 
start_date = datetime("2004-01-01");
end_date   = datetime("2004-12-31");
time = start_date:end_date;

% plots 
t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding","compact");

% ! all size: 
nexttile
hold on 
for i = 1:(length(var)-3)
    plot(time, eval([var{i} '_tmean']), '-')
end 
hold off 
legend(var{1:(end-3)})
set(gca, "YScale", "log", 'Ylim', [10^(-5) 5])
title("All size")

%! Functional group: 
nexttile
hold on 
plot(time, F_tmean, time, P_tmean, time, D_tmean, time, BE_tmean)
hold off 
set(gca, "YScale", "log", 'Ylim', [10^(-5) 10^(2)])
legend('Forage', 'Pelagics', 'Demersals', 'Benthos')
title("Functional group")

% Fig axes labels :
title(t, {[loc '_'  coupling '_' exp], ['Time_Means' Spinup{2}]}, ...
        Interpreter = 'none')
ylabel(t, 'Integrated biomass over water column (g WW m-2)')
xlabel(t, 'Time (days)')


save_graph(gcf, "png", [dir_output 'Time_Means' Spinup{2} ], 22, 12)

%% plot diagnostic Time Seire 

var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld'};
var_diag = {'f', 'cmax', 'cons', 'met', 'mu_p', 'mu_f', 'mu_a', 'mu',...
            'E_A', 'Fout', 'Repro', 'f_Zm', 'f_Zl', 'f_Sf', 'f_Sp', 'f_Sd',... 
            'f_Mf', 'f_Mp', 'f_Md', 'f_Lp', 'f_Ld', 'f_BE'};
FuncGrp = {'F_', 'P_', 'D_'};
dimension_average = {'_tmean'};
dimensions = {'time'};
load([dir_input 'Time_Means_Diag' Spinup{2} '.mat'])

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
grp(3).name = 'Physiological_rates' ; grp(3).idx = [1:4, 9:11];         grp(3).panel_grid = [3, 3];
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
    legend(FuncGrp, 'Location', grp(i).leg_loc, Interpreter='none');
    title(t, {[loc '_'  coupling '_' exp], ...
        ['Diagnostic_' grp(i).name '_' dimension_average{1}(2:end) '_Functional_grp']}, ...
        Interpreter='none')
    save_graph(gcf, "png", [dir_output , 'Diagnostic_' grp(i).name '_' dimension_average{1}(2:end) '_Fct_grp'], 16, 12)
end

%% Check Initial condition for Online simulations: 
load([dir_input 'COBALT_IC' '.mat'])

% Per functional group: 
F_IC = Sf_IC + Mf_IC;
P_IC = Sp_IC + Mp_IC + Lp_IC;
D_IC = Sd_IC + Md_IC + Ld_IC;

figure(4)
axes_formating(gcf, "defaultAxesColorOrder", cm10)
t = tiledlayout(1,2,"TileSpacing","compact","Padding","compact");

% plot all sizes: 
nexttile
hold on 
for i = 1:(length(var)-2)
    bar(i, eval([var{i} '_IC']))
end
hold off
set(gca, "YScale", "log", ...
         "Ylim", [10^(-5) 80])
xticks([1:(length(var)-2)])
xticklabels({var{1:(end-2)}})
xtickangle(25)
title("All Sizes")

% plot Functional group:
nexttile
bar([1:4], [F_IC, P_IC, D_IC, BE_IC])
set(gca, "YScale", "log", ...
         "Ylim", [10^(-5) 80])
xticks([1:4])
xticklabels({'Forage', 'Pelagic', 'Demersal', 'Benthos'})
xtickangle(25)
title("Functional group")

ylabel(t, "Biomass (g WW m-3)")
xlabel(t, "Functional groups")
title(t, {[loc '_'  coupling '_' exp], 'Initial Conditions for COBALT Online'}, ...
    Interpreter = 'none')


save_graph(gcf, "png", [dir_output,  'IC_COBALT_Online'], 16, 12)

%% Plot forcing data: 

%! Load data: 
load([dir_input_forcing 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'])
load([dir_input_forcing 'COBALT_offline_' loc '_Time_Means_forcing' '.mat'])
load([dir_input_forcing 'COBALT_offline_100m_' loc '_Time_Means_forcing' '.mat'])
load([dir_input_forcing 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'])

%! forcing variable names: 
var = {'nmdz', 'jhploss_n_Mdz', 'nlgz', 'jhploss_n_Lgz', 'Pop_btm'};

%! Time periode: 
start_date = datetime("2004-01-01");
end_date   = datetime("2004-12-31");
% time = start_date:end_date;

%! Plot forcing data: ------------------------------------------------
fig = figure(5);
axes_formating()

t = tiledlayout(1, 1, "TileSpacing","compact", "Padding","compact");

% Panel 1: time average: 
t1 = nexttile(t); 
hold(t1, 'all')
for i = 1:length(var)
    plot(t1, time, eval([var{i} '_offline_tmean']), '-')
end 
hold(t1, 'off')
set(t1, 'YScale', 'log', 'Ylim',[1.74969307072006e-05 1749.69307072006]);
title(t1, 'Time average')
legend(t1, var{:}, Interpreter = 'none', EdgeColor = 'none', Color = 'none', ...
    Position = [0.179283105674276 0.269803790877946 0.223263506063947 0.271164021164021]);

ylabel(t, 'Unit to check!')
xlabel(t, 'Time (days)')
title(t, {[loc '_'  coupling '_' exp], 'forcing_files'}, Interpreter = 'none')

save_graph(gcf, "png", [dir_output 'forcing_files' Spinup{2}], 16, 12)

%% plot for growth and biomass integrated over the water column: 
%! forcing variable names: 
figure
axes_formating(gcf, "defaultAxesColorOrder", cm10)
var = {'nmdz', 'jprod_nmdz', 'nlgz', 'jprod_nlgz'};
% time average: 
hold on 
for i = 1:length(var)
    plot(time, eval([var{i} '_offline_tmean']), '-')
end 
hold off
% set(gca, 'YScale', 'log', 'Ylim', [1.74969307072006e-05 1749.69307072006]);
title('Growth and biomass Mesozooplankton integrated over water column')
legend(var{:}, Interpreter = 'none', EdgeColor = 'none', Color = 'none');
xlabel("Day of year")
ylabel("gC WW m-2 (d-1 for prod)")

save_graph(gcf, "png", [dir_output 'Growth_and_biomass_Zoop_int' Spinup{2}], 12, 12)

%% plot for growth and biomass integrated over 100m: 
%! forcing variable names: 
figure
axes_formating(gcf, "defaultAxesColorOrder", cm10)
var = {'nmdz', 'jprod_nmdz', 'nlgz', 'jprod_nlgz'};
% time average: 
hold on 
for i = 1:length(var)
    plot(time, eval([var{i} '_offline_tmean_100m']), '-')
end 
hold off
% set(gca, 'YScale', 'log', 'Ylim', [1.74969307072006e-05 1749.69307072006]);
title('Growth and biomass Mesozooplankton integrated over 100m')
legend(var{:}, Interpreter = 'none', EdgeColor = 'none', Color = 'none');
xlabel("Day of year")
ylabel("gC WW m-2 (d-1 for prod)")

save_graph(gcf, "png", [dir_output 'Growth_and_biomass_Zoop_int' Spinup{2}], 12, 12)


