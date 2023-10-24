% Visualize output of FEISTY
% CESM FOSI
% Time series plots and maps
close all

%% Fish data

%! get directory containing output
dir = '../output/Matlab_Average/'; 
 
% new saving paths: -------------------------------------------------------
fpath='../Fig/'; % path with the data
if (~isfolder(fpath))
    mkdir(fpath)
end

% Load Data: -------------------------------------------------------------- 
load([dir 'Time_Means_FOSI.mat']);
load([dir 'Space_Means_FOSI.mat']);
load([dir 'Annual_Means_FOSI.mat'], 'mz_mtf'); % 

% Map data
load([param.rootdir 'Feisty/GCM_Data/CESM/FOSI/gridspec_POP_gx1v6_noSeas.mat']);
load([param.rootdir 'Feisty/GCM_Data/CESM/FOSI/Data_grid_POP_gx1v6_noSeas.mat']);

% Set these bounds for your data ------------------------------------------
[ni, nj]=size(TLONG);

plotminlat=-90; 
plotmaxlat=90;
plotminlon=-280;
plotmaxlon=80;
latlim=[plotminlat plotmaxlat];
lonlim=[plotminlon plotmaxlon];

load coastlines;

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

set(groot,'defaultAxesColorOrder',cm10);

%cmBP50=cbrewer('seq','BuPu',50,'PCHIP'); %  ? Two-phase obstacle problem in 2D and its aposteriori error estimate Copyright (c) 2016, Jan Valdman
                                         % Copyright (c) 2015, Charles Robert
                                         % Copyright (c) 2015, Rich Pawlowicz
                                         % Copyright (c) 2015, Jan Valdman
% save('cmBP50.mat', 'cmBP50')
load('../../TunningFEISTY/Tunning_FEISTY_Code/Colors/cmBP50')
%% Plots in time
t = 1:length(sp_tmean); %time;
y = t/12;

% All size classes of all
figure(1)
plot(y,log10(sf_tmean),'Linewidth',1); hold on;
plot(y,log10(mf_tmean),'Linewidth',1); hold on;
plot(y,log10(sp_tmean),'Linewidth',1); hold on;
plot(y,log10(mp_tmean),'Linewidth',1); hold on;
plot(y,log10(lp_tmean),'Linewidth',1); hold on;
plot(y,log10(sd_tmean),'Linewidth',1); hold on;
plot(y,log10(md_tmean),'Linewidth',1); hold on;
plot(y,log10(ld_tmean),'Linewidth',1); hold on;
plot(y,log10(b_tmean),'Linewidth',1); hold on;
legend('SF','MF','SP','MP','LP','SD','MD','LD','B')
legend('location','eastoutside')
xlim([y(1) y(end)])
ylim([-3 1])
xlabel('Time (y)')
ylabel('log_1_0 Biomass (g m^-^2)')
title('FOSI')
% stamp(mod)
print('-dpng',[fpath, 'all_sizes.png'])

%% Types together
F = sf_tmean + mf_tmean;
P = sp_tmean + mp_tmean+lp_tmean;
D = sd_tmean + md_tmean+ld_tmean;
B = b_tmean;

figure(2)
plot(y,log10(B),'color',[0.5 0.5 0.5],'Linewidth',2); hold on;
plot(y,log10(F),'r','Linewidth',2); hold on;
plot(y,log10(P),'b','Linewidth',2); hold on;
plot(y,log10(D),'k','Linewidth',2); hold on;
legend('B','F','P','D')
legend('location','west')
xlim([y(1) y(end)])
%ylim([0.05 0.5])
xlabel('Time (y)')
ylabel('log_1_0 Biomass (g m^-^2)')
title('FOSI')
% stamp(param.save_name)
print('-dpng', [fpath, 'all_types.png'])

%% Plots in space

Zsf=NaN*ones(ni,nj);
Zsp=NaN*ones(ni,nj);
Zsd=NaN*ones(ni,nj);
Zmf=NaN*ones(ni,nj);
Zmp=NaN*ones(ni,nj);
Zmd=NaN*ones(ni,nj);
Zlp=NaN*ones(ni,nj);
Zld=NaN*ones(ni,nj);
Zb= NaN*ones(ni,nj);

Zsf(GRD.ID)=sf_sbio;
Zsp(GRD.ID)=sp_sbio;
Zsd(GRD.ID)=sd_sbio;
Zmf(GRD.ID)=mf_sbio;
Zmp(GRD.ID)=mp_sbio;
Zmd(GRD.ID)=md_sbio;
Zlp(GRD.ID)=lp_sbio;
Zld(GRD.ID)=ld_sbio;
 Zb(GRD.ID)=b_sbio;

All  = Zsp+Zsf+Zsd+Zmp+Zmf+Zmd+Zlp+Zld; 
AllF = Zsf+Zmf;
AllP = Zsp+Zmp+Zlp;
AllD = Zsd+Zmd+Zld;
AllS = Zsp+Zsf+Zsd;
AllM = Zmp+Zmf+Zmd;
AllL = Zlp+Zld;
FracPD = AllP ./ (AllP+AllD);
FracPF = AllP ./ (AllP+AllF);
FracLM = AllL ./ (AllL+AllM);

%% save outputs for comparison
save([dir 'Plot_Means_FOSI.mat'],'F','P','D','B',...
    'AllF','AllP','AllD','AllS','AllM','AllL');

%% Calculation on specific long
idxlat = find(TLAT < -32 | TLAT > 32); % Index for subtropical areas
idxlat2 = find(TLAT > -32 & TLAT <32); % Index for subtropical areas

Zsf_subtrop=Zsf;
Zsp_subtrop=Zsp;
Zsd_subtrop=Zsd;
Zmf_subtrop=Zmf;
Zmp_subtrop=Zmp;
Zmd_subtrop=Zmd;
Zlp_subtrop=Zlp;
Zld_subtrop=Zld;
Zb_subtrop=Zb;

Zsf_subtrop(idxlat)=NaN;
Zsp_subtrop(idxlat)=NaN;
Zsd_subtrop(idxlat)=NaN;
Zmf_subtrop(idxlat)=NaN;
Zmp_subtrop(idxlat)=NaN;
Zmd_subtrop(idxlat)=NaN;
Zlp_subtrop(idxlat)=NaN;
Zld_subtrop(idxlat)=NaN;
Zb_subtrop(idxlat)=NaN;

Zsf_nonsubtrop=Zsf;
Zsp_nonsubtrop=Zsp;
Zsd_nonsubtrop=Zsd;
Zmf_nonsubtrop=Zmf;
Zmp_nonsubtrop=Zmp;
Zmd_nonsubtrop=Zmd;
Zlp_nonsubtrop=Zlp;
Zld_nonsubtrop=Zld;
Zb_nonsubtrop=Zb;

Zsf_nonsubtrop(idxlat2)=NaN;
Zsp_nonsubtrop(idxlat2)=NaN;
Zsd_nonsubtrop(idxlat2)=NaN;
Zmf_nonsubtrop(idxlat2)=NaN;
Zmp_nonsubtrop(idxlat2)=NaN;
Zmd_nonsubtrop(idxlat2)=NaN;
Zlp_nonsubtrop(idxlat2)=NaN;
Zld_nonsubtrop(idxlat2)=NaN;
Zb_nonsubtrop(idxlat2)=NaN;

Zsf_subtrop_mean = nanmean(nanmean(Zsf_subtrop));
Zsp_subtrop_mean = nanmean(nanmean(Zsp_subtrop));
Zsd_subtrop_mean = nanmean(nanmean(Zsd_subtrop));
Zmf_subtrop_mean = nanmean(nanmean(Zmf_subtrop));
Zmp_subtrop_mean = nanmean(nanmean(Zmp_subtrop));
Zmd_subtrop_mean = nanmean(nanmean(Zmd_subtrop));
Zlp_subtrop_mean = nanmean(nanmean(Zlp_subtrop));
Zld_subtrop_mean = nanmean(nanmean(Zld_subtrop));
Zb_subtrop_mean  = nanmean(nanmean(Zb_subtrop));

Zsf_nonsubtrop_mean = nanmean(nanmean(Zsf_nonsubtrop));
Zsp_nonsubtrop_mean = nanmean(nanmean(Zsp_nonsubtrop));
Zsd_nonsubtrop_mean = nanmean(nanmean(Zsd_nonsubtrop));
Zmf_nonsubtrop_mean = nanmean(nanmean(Zmf_nonsubtrop));
Zmp_nonsubtrop_mean = nanmean(nanmean(Zmp_nonsubtrop));
Zmd_nonsubtrop_mean = nanmean(nanmean(Zmd_nonsubtrop));
Zlp_nonsubtrop_mean = nanmean(nanmean(Zlp_nonsubtrop));
Zld_nonsubtrop_mean = nanmean(nanmean(Zld_nonsubtrop));
Zb_nonsubtrop_mean  = nanmean(nanmean(Zb_nonsubtrop));


figure(9)
t = tiledlayout(2, 2, "TileSpacing", "compact", "Padding","compact");

nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG, log10(Zb_subtrop))
colormap(cmBP50)                % decent looking coastlines
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([-1 2]);
hcb = colorbar('h');
set(gcf,'renderer','painters')
%title('Subtropical')

nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(Zb_nonsubtrop))
colormap(cmBP50)                % decent looking coastlines
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([-1 2]);
hcb = colorbar('h');
set(gcf,'renderer','painters')
% title('Non Subtropical')

nexttile
bar([Zsf_subtrop_mean, Zsp_subtrop_mean, Zsd_subtrop_mean, Zmf_subtrop_mean, ...
    Zmp_subtrop_mean, Zmd_subtrop_mean, Zlp_subtrop_mean, Zld_subtrop_mean])
xticklabels({'Zsf', 'Zsp', 'Zsd', 'Zmf', 'Zmp', 'Zmd', 'Zlp', 'Zld'})
title('Subtropical average biomass')

nexttile
bar([Zsf_nonsubtrop_mean, Zsp_nonsubtrop_mean, Zsd_nonsubtrop_mean, Zmf_nonsubtrop_mean, ...
    Zmp_nonsubtrop_mean, Zmd_nonsubtrop_mean, Zlp_nonsubtrop_mean, Zld_nonsubtrop_mean])
xticklabels({'Zsf', 'Zsp', 'Zsd', 'Zmf', 'Zmp', 'Zmd', 'Zlp', 'Zld'})
title('Non Subtropical average biomass')
title(t, 'FOSI log10 mean benthic biomass (g m^-^2)')

print('-dpng',[fpath, 'subtrop_biomass.png'])

%% bent
figure(3)
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT, TLONG, log10(Zb))
colormap(cmBP50)                %decent looking coastlines
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([-1 2]);
hcb = colorbar('h');
set(gcf,'renderer','painters')
title('FOSI log10 mean benthic biomass (g m^-^2)')
% stamp('')
print('-dpng',[fpath, 'global_BENT.png'])

%% All 4 on subplots
figure(4)
% all F
subplot('Position',[0 0.51 0.5 0.5])
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(AllF))
colormap(cmBP50)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
colorbar('Position',[0.25 0.5 0.5 0.05],'orientation','horizontal')
set(gcf,'renderer','painters')
title('log10 mean All F (g m^-^2)')

% all D
subplot('Position',[0 0 0.5 0.5])
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(AllD))
colormap(cmBP50)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('log10 mean All D (g m^-^2)')

% All P
subplot('Position',[0.5 0.51 0.5 0.5])
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(AllP))
colormap(cmBP50)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('log10 mean All P (g m^-^2)')

% All
subplot('Position',[0.5 0 0.5 0.5])
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(All))
colormap(cmBP50)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('log10 mean All fishes (g m^-^2)')

% paper size options: -----------------------------------------------------
width = 12;
height = 12;
set(gcf, 'Units', 'centimeters', 'position',[2.5,2.5,width+2.5,height+2.5])
screenposition = get(gcf,'Position'); % get the figure size
set(gcf, 'PaperUnits','centimeters',...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize', [screenposition(3:4)]); % make the print paper size fits the figure size

print('-dpng',[fpath, 'global_All_subplot.png'])


%% Small forage and small to large pelagics: 
figure(5)
t = tiledlayout(3, 2, "TileSpacing", "compact", "Padding", "compact", ...
    "TileIndexing", "columnmajor");

%!! Small Pelgaic fish MAP: 
nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(Zsp))
colormap(cmBP50)
patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('Small Pelagic')


%!! Medium Pelgaic fish MAP: 
nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(Zmp))
colormap(cmBP50)
patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('Medium Pelagic')

%!! Large Pelgaic fish MAP: 
nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT, TLONG, log10(Zlp))
colormap(cmBP50)
patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('Large Pelagic')

%!! Small forgarage fish MAP: 
t1 = nexttile;
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(Zsf))
colormap(cmBP50)
patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('Small Forage')

%!! Medium forgarage fish MAP: 
t2 = nexttile;
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,log10(Zmf))
colormap(cmBP50)
patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([param.col_inf param.col_sup]);
set(gcf,'renderer','painters')
title('Medium Forage)')

C = colorbar('Location', 'southoutside' ,'orientation','horizontal');
hpos = (t1.Position(2)- t2.Position(2))/2;
C.Position(2) = C.Position(2) -hpos;
title(C, 'log10 mean biomass (g m^-^2)')

% paper size options: -----------------------------------------------------
width = 13;
height = 16;
set(gcf, 'Units', 'centimeters', 'position',[2.5,2.5,width+2.5,height+2.5])
screenposition = get(gcf,'Position'); % get the figure size
set(gcf, 'PaperUnits','centimeters',...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize', [screenposition(3:4)]); % make the print paper size fits the figure size

print('-dpng',[fpath,  'global_Pelagics.png'])

%% Ratios on subplots red-white-blue
% 3 figure subplot P:D, P:F, M:L
figure(6)
tiledlayout(2,4,"TileSpacing","compact", "Padding", "tight")
nexttile([1 2])
%P:D
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,FracPD)
%cmocean('balance')
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([0 1]);
set(gcf,'renderer','painters')
title('Fraction Large Pelagics vs. Demersals')

%P:F
nexttile([1 2])
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,FracPF)
%cmocean('balance')
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([0 1]);
set(gcf,'renderer','painters')
title('Fraction Large Pelagics vs. Forage Fishes')

%L:M
nexttile(6, [1, 2])
axesm ('Robinson','MapLatLimit', latlim, 'MapLonLimit', lonlim, 'frame', 'on',...
    'Grid', 'off', 'FLineWidth', 1)
surfm(TLAT,TLONG,FracLM)
%cmocean('balance')
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([0 1]);
colorbar('Position',[0.2 0.485 0.6 0.05],'orientation','horizontal')
set(gcf,'renderer','painters')
title('Fraction Large vs. Medium')

% paper size options: -----------------------------------------------------
width = 12;
height = 10;
set(gcf, 'Units', 'centimeters', 'position',[2.5,2.5,width+2.5,height+2.5])
screenposition = get(gcf,'Position'); % get the figure size
set(gcf, 'PaperUnits','centimeters',...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize', [screenposition(3:4)]); % make the print paper size fits the figure size
print('-dpng',[fpath, 'global_ratios_subplot.png'])

%% MZ loss plots
[nx,nt] = size(mz_mtf);
%Mean fraction
Cmz_smfrac = mz_smfrac;
%Total times it happens over time
Cmz_ttover = mz_ttf/nx;
%Total times it happens in each year in space?
Cmz_stover5 = mz_stf/nt;

%%
%happens whole year
test2=floor(Cmz_stover5);
%histogram(test2)
sum(test2)/length(test2) % = 2.1675

%happens >=50% of year
test4=round(Cmz_stover5);
%histogram(test4)
sum(test4)/length(test4) % = 2.4561

%% Plot in time
figure(7)
plot(y, Cmz_ttover,'k','LineWidth',2); hold on;
xlabel('Years')
ylabel('Fraction of grid cells over-consumed')
print('-dpng',[ppath 'FOSI_', param.save_name '_timeseries_zoop_overcon.png'])

%% Plots in space
CFmz=NaN*ones(ni,nj);
COmz=NaN*ones(ni,nj);
COmz5=NaN*ones(ni,nj);
CFmz(GRD.ID)=Cmz_smfrac;
COmz(GRD.ID)=Cmz_stover5;

% save([bpath 'FOSI_' mod '_ts_map_zoop_overcon.mat'],...
%     'Cmz_ttover','CFmz','COmz','-append');

% cmBP2=cbrewer('seq','BuPu', 10,'PCHIP');
% cmBP3 = cmBP2;
% cmBP3(11,:) = [0 0 0];
% save('cmBP2.mat', 'cmBP2')
% save('cmBP3.mat', 'cmBP3')
load('cmBP2')
load('cmBP3')
%% 2 plots of both maps
figure(8)
%1 - m frac
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact")
nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,CFmz)
colormap(cmBP3)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([0 1.1]);
colorbar
set(gcf,'renderer','painters')
title('Mean fraction MZ hploss consumed')

%2 - m over
nexttile
axesm ('Robinson','MapLatLimit',latlim,'MapLonLimit',lonlim,'frame','on',...
    'Grid','off','FLineWidth',1)
surfm(TLAT,TLONG,COmz)
colormap(cmBP2)
h=patchm(coastlat+0.5,coastlon+0.5,'w','FaceColor',[0.75 0.75 0.75]);
caxis([0 1]);
colorbar
set(gcf,'renderer','painters')
title('Mean times MZ overconsumed')

% paper size options: -----------------------------------------------------
width = 12;
height = 10;
set(gcf, 'Units', 'centimeters', 'position',[2.5,2.5,width+2.5,height+2.5])
screenposition = get(gcf,'Position'); % get the figure size
set(gcf, 'PaperUnits','centimeters',...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize', [screenposition(3:4)]); % make the print paper size fits the figure size
print('-dpng',[ppath 'FOSI_', param.save_name '_global_zoop_overcon.png'])


