%==========================================================================
%
%                  Checking2D input data for fortran code 
%
%==========================================================================

%% Initialisation 
close all
Rockfish = false; 

% Data directory from rockfish or local computer
if Rockfish
    param.rootdir = '/project/';
else 
    param.rootdir = 'Z:/';
end
directory_save = [param.rootdir 'rdenechere/TunningFEISTY/TL319_g17.4p2z/2D_data/'];
addpath([param.rootdir 'rdenechere/Programing/Matlab/matalb_functions/'])

VAR_NAMES2 = {'TEMP_BOTTOM_2_var', 'TEMP_mean_150m_var', 'mesozooC_zint_150m_var',...
    'pocToFloor_2_var', 'mesozoo_loss_zint_150m_var'};

%! get directory containing output
dir = '../output/Matlab_Average/'; 

%! Map data
load([param.rootdir 'Feisty/GCM_Data/CESM/FOSI/gridspec_POP_gx1v6_noSeas.mat']);
load([param.rootdir 'Feisty/GCM_Data/CESM/FOSI/Data_grid_POP_gx1v6_noSeas.mat']);

% Set these bounds for your data ------------------------------------------
[ni,nj]=size(TLONG);

plotminlat=-90; 
plotmaxlat=90;
plotminlon=-280;
plotmaxlon=80;
latlim=[plotminlat plotmaxlat];
lonlim=[plotminlon plotmaxlon];

load coastlines;

%! colors: ----------------------------------------------------------------
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

set(groot,'defaultAxesColorOrder',cm10);

load('../../TunningFEISTY/Tunning_FEISTY_Code/Colors/cmBP50')


%% Define file name 

file_Tb = [directory_save, 'TEMP_BOTTOM_2_2D.nc'];
file_Tp = [directory_save, 'TEMP_mean_150m_2D.nc'];
file_Zm = [directory_save, 'mesozooC_zint_150m_2D.nc'];
file_dZm = [directory_save, 'mesozoo_loss_zint_150m_2D.nc'];
file_det = [directory_save, 'pocToFloor_2_2D.nc'];

%! Get data from netcdf: ---------------------------------------
dataTb = ncread(file_Tb, VAR_NAMES2{1}); 
dataTp = ncread(file_Tp, VAR_NAMES2{2});
dataZm = ncread(file_Zm, VAR_NAMES2{3});
datadet = ncread(file_det, VAR_NAMES2{4});
datadZm = ncread(file_dZm, VAR_NAMES2{5});


%% Plot Sapace 1st year  

Tb_1 = NaN*ones(ni, nj);
Tp_1 = NaN*ones(ni, nj);
Zm_1 = NaN*ones(ni, nj);
dZm_1 = NaN*ones(ni, nj);
det_1 = NaN*ones(ni, nj);

Tb_1(GRD.ID) = mean(dataTb(:, 1:365), 2);
Tp_1(GRD.ID) = mean(dataTp(:, 1:365), 2);
Zm_1(GRD.ID) = mean(dataZm(:, 1:365), 2);
dZm_1(GRD.ID) = mean(datadZm(:, 1:365), 2);
det_1(GRD.ID) = mean(datadet(:, 1:365), 2);

%% Plot Global data
figure(1)
t = tiledlayout(2, 3, "TileSpacing", "compact", "Padding", "compact" );
t.TileIndexing = "columnmajor";
title(t, 'Average of Year 1958')

% Data V17 ---------------------------------------------------------------
nexttile % Tb
axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, Tb_1)
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');
% caxis([-3 30])
title('Tb')

nexttile % Tp
axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, Tp_1)
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');
% caxis([-3 30])
title('Tp')

nexttile % Zm
axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, log10(Zm_1))
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');
% caxis([-2 5])
title('Zm')

nexttile % det
axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, log10(det_1))
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');
% caxis([-5 1])
title('det')

nexttile % dZm
axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, log10(dZm_1))
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');
% caxis([-5 1])
title('dZm')

save_graph(gcf, 'pdf', '../Fig/Visualise_2D_Input_data_FEISTY_fortran', 16, 10)

%% 

Sp_file = "../output/Sp_bio_Spinup.nc"; 
Sp = ncread(Sp_file, 'Sp');

axesm('Robinson','MapLatLimit', latlim,'MapLonLimit', lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, log10(Sp))
colormap("copper")
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
hcb = colorbar('v');

title('dZm')




















