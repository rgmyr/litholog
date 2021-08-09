%% Script for extracting data from Matlab structure that is exported from the Digitizer

% Notes
    % IMPORTANT NOTE: NaNs in the grain size and sand-shale fields are covered intervals (sometimes called "no recovery")
        % for example, see log named "krf1"

T=table(); % preallocate

%load('/Users/zanejobe/Google_Drive/1_GraphicLogPapers/GraphicLogML/data/CORE_2021Jan.mat')
%DEMO = CORE([146:150,225:226,282:285,288,291]);

load('/Users/zanejobe/Google_Drive/1_GraphicLogPapers/DigitalGraphicLog/code/matlab/data/demo_data.mat')
cd('/Users/zanejobe/Google_Drive/1_GraphicLogPapers/DigitalGraphicLog/code/matlab')

[T]=flatten_core_struct_beds_public(DEMO,T); % flatten data

% if you need to make sure there are no zero values of thickness
ind1=find(T.th==0); T(ind1,:) = [];

%{
Modify the field for pairs of grain size and depth points that describe the 
grain size trend of each bed - this puts all the data into one cell instead 
of it being variable length when you export it as a csv
%}
depth_m=string(); % create variable
for i=1:height(T) %loop
    tempd=sprintf('%.4f,',T.depth_m{i});
    depth_m=[depth_m;tempd];
end
depth_m(1)=[]; % get rid of empty cell
T.depth_m=depth_m; % assign to table

grain_size_mm=string();
for i=1:height(T)
    tempd=sprintf('%.4f,',T.grain_size_mm{i});
    grain_size_mm=[grain_size_mm;tempd];
end
grain_size_mm(1)=[]; % get rid of empty cell
T.grain_size_mm=grain_size_mm; % assign to table

cd('/Users/zanejobe/Google_Drive/1_GraphicLogPapers/DigitalGraphicLog/code/matlab/data')
writetable(T,'demo_data.csv')

%% plot bed thickness
figure; hold on

% SAND
% basin plain
[f,x]=ecdf(T.th(T.eod=='basin plain' & T.snd_shl==1),'function','cdf'); 
plot(x,f,'-r','LineWidth',2);
% fan
[f,x]=ecdf(T.th(T.eod=='fan' & T.snd_shl==1),'function','cdf'); 
plot(x,f,'-g','LineWidth',2);
% levee
[f,x]=ecdf(T.th(T.eod=='levee' & T.snd_shl==1),'function','cdf'); 
plot(x,f,'-b','LineWidth',2);
% channel
[f,x]=ecdf(T.th(T.eod=='slopechannel' & T.snd_shl==1),'function','cdf'); 
plot(x,f,'-k','LineWidth',2);

% MUD
% basin plain
[f,x]=ecdf(T.th(T.eod=='basin plain' & T.snd_shl==0),'function','cdf'); 
plot(x,f,'-.r','LineWidth',2);
% fan
[f,x]=ecdf(T.th(T.eod=='fan' & T.snd_shl==0),'function','cdf'); 
plot(x,f,'-.g','LineWidth',2);
% levee
[f,x]=ecdf(T.th(T.eod=='levee' & T.snd_shl==0),'function','cdf'); 
plot(x,f,'-.b','LineWidth',2);
% channel
[f,x]=ecdf(T.th(T.eod=='slopechannel' & T.snd_shl==0),'function','cdf'); 
plot(x,f,'-.k','LineWidth',2);

set(gca,'xscale','log')

names_sand={'basin plain sand','fan sand','levee sand','channel sand'};
names_mud={'basin plain mud','fan mud','levee mud','channel mud'};
legend(names_sand{:},names_mud{:})
title('Bed thickness')
xlabel('bed thickness (m)')

%% th vs gs

%%%%%%%%%%
% ALSO SEE /Users/zanejobe/Dropbox/GitHub/KDE-2D/CoreDescBeds.py
%%%%%%%%%%

figure; hold on
% sand
plot(T.mean_gs_mm(T.eod=='fan' & T.snd_shl==1),T.th(T.eod=='fan' & T.snd_shl==1),'or')
plot(T.mean_gs_mm(T.eod=='levee' & T.snd_shl==1),T.th(T.eod=='levee' & T.snd_shl==1),'ob')
% mud
plot(T.mean_gs_mm(T.eod=='fan' & T.snd_shl==0),T.th(T.eod=='fan' & T.snd_shl==0),'.r')
plot(T.mean_gs_mm(T.eod=='levee' & T.snd_shl==0),T.th(T.eod=='levee' & T.snd_shl==0),'.b')

names_sand={'fan sand','levee sand'};
names_mud={'fan mud','levee mud'};
legend(names_sand{:},names_mud{:})

set(gca,'xscale','log')
set(gca,'yscale','log')
xlabel('mean grain size (mm)')
ylabel('bed thickness (m)')
title('demonstrates issues with digitized grain size in muds...')


