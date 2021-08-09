function Zlogplot(C)
% Plot Core or Outcrop Data 
% Syntax : Zlogplot(Core Struct) 
% Nick C. Howes 7/3/2012
% modified by John Martin, 2015ish
% modified by Zane Jobe, 2020

cut = 2.5; % sand mud cutoff value (using arbitrary grain size values)

% check for renamed field
if isfield(C,'gs_tops')==0
    C.gs_tops = C.gs;
end


%Determine if Strat or Log Data
z=C.tops;

if z(1)>z(end)
    dtype='strat';
else
    dtype='core';
end

%Plot Log Data (Core or Strat)

switch dtype
    
    case 'strat'        
        Zstratplot(C,cut);
    case 'core'
        Zcoreplot(C,cut);       
end

function Zcoreplot(C,cut)
%Plot Core Data from new global structure
%Syntax coreplot_xstrat(Core,xstrat)
%After NCH 4/2012

sz=get( 0, 'ScreenSize');
fig_handle=figure; %subplot(1,2,1); 
set(fig_handle,'Position',[100 100 400 800]);

hold on;

%% Preallocate

gspi=[];
gsp=[];

XX=[];
YY=[];

%% Structure file for cross-set data
P=repmat(struct('name',[],'h_cs',[],'sm',[],'smed',[],'cv',[],'Hest',[],...
    'h_cs_rng',[],'sm_rng',[],'smed_rng',[],'cv_rng',[],'Hest_rng',[],'gs_psi',[],...
    'gs_psi_filt',[]),1);   

P.name=C.name;
%% Color Schemes


% colors
mud=[173 129 80]./256;
sand=[255 254 122]./256;

z=C.tops;
th=C.th;
gs=C.gs_tops;
nc=C.n_beds;
bedpro=C.bed_profiles;

if ~isempty(bedpro)
    zp=bedpro(:,1);
    gsp=bedpro(:,2);
end

%% Plot Core Beds
for i=1:nc;
    % find bed profile points that belong to current bed:
    
    if ~isempty(bedpro)
    
        if i<nc
            zpi=zp(zp>z(i) & zp<z(i+1));
            gspi=gsp(zp>z(i) & zp<z(i+1));  
        else % deal with last bed:
            zpi=zp(zp>z(i));
            gspi=gsp(zp>z(i));   
        end

    
    end
    
    
    % define polygons clockwise - beds
    if ~isempty(gspi)
        
        Y=[z(i) z(i) zpi' z(i)+th(i) z(i)+th(i)];
        X=[0 gs(i) gspi' gspi(end) 0];   

        if max(gs(i))>=cut | max(gspi)>=cut;
            fill(X,Y,sand)
        else
            fill(X,Y,mud)
        end
    
    else
        
        Y=[z(i) z(i) z(i)+th(i) z(i)+th(i)];
        X=[0 gs(i) gs(i) 0];
        
         if gs(i)>=cut;
            fill(X,Y,sand);
         elseif gs(i)<cut;
            fill(X,Y,mud)
         end
    

    end
      
         XX{i}=X(2:end-1);
         YY{i}=Y(2:end-1); YY{i}(end)=YY{i}(end)-1e-6;
    
end


%% Plot Configuration
glabels=C.gslabels(1,:);
set(gca,'ydir','reverse')
mingst=floor(min(gs));
mingsp=floor(min(gsp));
maxgst=ceil(max(gs));
maxgsp=ceil(max(gsp));

mings=min([mingst mingsp]);
maxgs=max([maxgst maxgsp]);

if ~isempty(gsp)
    set(gca,'xtick',1:maxgs)
else
    set(gca,'xtick',1:maxgs)   
end

ind=get(gca,'xtick');
set(gca,'xticklabel',glabels(ind));
ylabel(strcat('Core Depth',' (',C.units(1),')')); title(C.name(1,:));
xlabel('Grain Size');
set(gca,'XGrid','on')

paxis=axis; yaxis(1)=paxis(3); yaxis(2)=paxis(4); axis([paxis]);
rotateXLabels(gca,45);

function Zstratplot(C,cut)
%%Plot Stratigraphic Section Data from new global structure
%Syntax : stratplot_xstrat(Core,xstrat)
%After NCH 4/2012

sz=get( 0, 'ScreenSize');
fig_handle=figure; %subplot(1,2,1); 
set(fig_handle,'Position',[100 100 400 800]);

hold on;

%--------------------------Preallocate-------------------------------------
gspi=[];
gsp=[];

%--------------------------Color Schemes-----------------------------------

% colors
mud=[173 129 80]./256;
sand=[255 254 122]./256;

subplot(1,2,1); hold on;

z=C.tops;
th=C.th;
gs=C.gs_tops;


if ~isempty(C.bed_profiles)
    zp=C.bed_profiles(:,1);
    gsp=C.bed_profiles(:,2);
end


%-------------------------Plot Core Beds-----------------------------------

for i=1:C.n_beds;
    % find bed profile points that belong to current bed:
    
    if ~isempty(C.bed_profiles)
    
    
    if i<C.n_beds
        zpi=zp(zp<z(i) & zp>z(i+1));
        gspi=gsp(zp<z(i) & zp>z(i+1));     
    else % deal with last bed:
        zpi=zp(zp<z(i));
        gspi=gsp(zp<z(i));   
    end
    
    
    end
    
    
    % define polygons clockwise - beds
    if ~isempty(gspi)
        Y=[z(i) z(i) zpi' z(i)-th(i) z(i)-th(i)];
        X=[0 gs(i) gspi' gspi(end) 0];   
    
        if max(gs(i))>cut | max(gspi)>cut;
            fill(X,Y,sand)
        else
            fill(X,Y,mud)
        end
    
    else
        Y=[z(i) z(i) z(i)-th(i) z(i)-th(i)];
        X=[0 gs(i) gs(i) 0];
        
         if gs(i)>cut;
            fill(X,Y,sand);
         elseif gs(i)<=cut;
            fill(X,Y,mud)
         end
    end
end

%Plot Configuration
glabels=C.gslabels(1,:);
%set(gca,'ydir','reverse')

if ~isempty(gsp)
    set(gca,'xtick',(1:ceil(max(cat(1,gs,gsp)))));
else
    set(gca,'xtick',(1:ceil(max(gs))));  
end

ind=get(gca,'xtick');
set(gca,'xticklabel',glabels(ind));
ylabel(strcat('Strat',' (',C.units(1),')')); title(C.name(1,:));
xlabel('Grain Size');
set(gca,'XGrid','on')
h1=get(gca,'ylim');

paxis=axis; yaxis(1)=paxis(3); yaxis(2)=paxis(4); axis([paxis]);
rotateXLabels(gca,45);
