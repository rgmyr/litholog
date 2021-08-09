function f=StratCoreProcessor
% Core Digitizer from analog core description or outcxrop measured section
% by John M Martin, after dmcore_v11_dual by Nick C Howes, 2012
% Zane Jobe and Luke Pettinga fixed grain size mm calculation - June 2018

%% generate figure and mapping window

sz=get( 0, 'ScreenSize');
f.fh = figure('Position',[100 60 sz(3) 0.8*sz(4)]);
set(f.fh,'toolbar','figure')
set(f.fh,'numberTitle','off','name','StratCoreProcessor')

f.ax(1) = axes();
set(f.ax(1),'unit','normalized','position',[.1 .1 .3 .85]);


%% Grain size

gs1={'lower g.s.','clay','silt','vfs','fs','ms','cs','vcs','gr','pb'};
gs1_2={'nonlinear','clay','silt','vfs','fs','ms','cs','vcs','gr','pb'};
gs2={'upper g.s.','clay','silt','vfs','fs','ms','cs','vcs','gr','pb'};

%% Lithology 

%..........................................................................
%word list

GenLith={'Sed. Structures Clear','No Recovery','Cross stratification','Planar stratification',...
    'Massive Sand','Graded bedding','Inverse bedding','Contorted',...
    'Discontinuous','Ripple lamination','Current ripple lamination',...
    'Wave ripple lamination','Lenticular','Flaser','Couplet',...
    'Bi-directional','Herringbone','Hummocky stratification',...
    'Swaley stratification','Wavy','Discontinuous wavy',...
    'Climbing ripple lamination','Combined-flow ripple','Double mud drapes'...
    'Conglomerate','Muddy Sand','Mud-clast Conglomerate','Massive mud'};

BA={'Sed. Structures Clear','No Recovery','Mud-clast conglomerate', 'Massive sandstone','Clast-bearing massive sandstone',...
    'Laminated sandstone','Planar-bedded sandstone','Banded sandstone','Rippled sandstone',...
    'Climbing ripple sandstone','Cross-bedded sandstone','Dewatered sandstone',...
    'Disrupted sandstone','Burrowed sandstone','Injected sandstone',...
    'Carbonaceous-rich sandstone','Sand-prone heterolithics','Mud-prone heterolithics',...
    'Burrowed hterolithics','Laminated mudrock','Massive mudrock',...
    'Disrupted mudrock','Burrowed mudrock','Sand-injected mudrock',...
    'Mudclast-charged muddy sandstone','Carbonaceous-charged muddy sandstone',...
    'Muddy sandstone','Mudclast-charged mudrock','Carbonaceous-bearing mudrock',...
    'Mudclast-charged clean sandstone'};

Robertson={'Sed. Structures Clear','No Recovery','Conglomerate','Matrix-suppported cong',...
    'Pseudocong (injected Ss into Ms)','Aeol avalanche strata','Aeol avalanche with low-anlge ripple lam',...
    'Aeol low-angle wind-ripple lam','Aeol low-angle wind ripple lam and salt-ridge deform',...
    'Massive sandstone','High-angle stratified sandstone','Low-angle stratified sandstone',...
    'Rippled sandstone','Mud-prone massive sandstone','High-angle stratified sandstone with pres caps',...
    'Low-angle stratified sandstone with pres caps','Rippled sandstone beds with pres caps',...
    'Bioturbated or disrupted sandstone','Bioturbated or disrupted mud-prone sandstone',...
    'Bioturbaded or disrupted mud-rich sandstone','Massive and highly argillaceous sandstone',...
    'Heterolithic sandstone (stratified)','Mud-prone heterolithic (stratified)',...
    'Irregulary bedded/disrupted mud-prone heterolithic','Stratified mudrock',...
    'Macrobioturbated or irrecularly bedded /disrupted mudrock','Masssive mudrock',...
    'Carbonaceous mudrock and coal'};

%..........................................................................
%storage notation (in database)
GenLith_sed={'SedS','GLNo_Recovery','Xstrat','Pstrat','Massive_Sand','Norm_Graded','Inv_Graded',...
    'Contort','Discont','RLam','CRLam','WRLam','Lenticular','Flaser',...
    'Coup','Bidir','Herr','HCS','SCS','Wav','DisWav','CLRLam','CFRLam',...
    'DMD','Conglomerate','Muddy_Sand','Mud_Clast_Cong','Massive_Mud'};

BA_sed={'SedS','BANo_Recovery','Cgm','Sm','Smp','Sl_Slm','Sp','Sba','Sr_Srm','Sr_cl','Sx','Sdw',...
    'Sds','Sb_Sbl','Si','Sc','Hs','Hm','Hb_Hbl','Ml','Mm','Mds',...
    'Mb_Mbl_Mb3','SiM','mcMSS','ccMS','MS','mcMM','ccMM','mcS'};

Robertson_sed={'SedS','RNo_Recovery','CG','CGAM','PCG','ASt1','ASt2','ASt3','ASt4','S1M',...
    'S1St1','S1St2','S1St3','S2M','S2St1','S2St2','S2St3','S1B_S1D',...
    'S2B_S2D','S3B_S3D','SAM','SHSt','MHSt','MHD','MSt','MB_MD',...
    'MM','MC'};


%% Trace Fossils

tf={'Clear_Trace_Fossils','Burrow','Arenicolites','Asterosoma','Chondrites','Cylindrichnus',...
    'Diplocraterion','Fugichnia','Equilibrichnia','Ophiomorpha',...
    'Palacophycus','Phycosiphon','Planolites','Rhizocorallium',...
    'Rosselia','Skolithos','Teichichnus','Thalassinoides',...
    'Glossifungites','Psilonichnus'};


%% Organics

%..........................................................................
%words
organics={'Clear Organics','Roots','Plant material','Peat','Bedded coal','Carb material',...
    'Total organic content meas','Und organic material'};

%..........................................................................
%storage notation (in database)

org={'clr_org','Root','Plant','Peat','Coal','CConc','Shell','TOC','Und_Org'};

%% Surfaces

%..........................................................................
%words
surfaces={'Clear Surfaces/Clasts','Mud clast','Gravel clast','Erosional truncation',...
    'Mud drape','Granule','dip'};

%..........................................................................
%storage notation (in database)
srfclst={'clr_srfclst','MClast','Gravel_clast','Erosional_Truncation','Drape','Gutter',...
    'Scour','Gran','dip'};

%% Bioturbation Index
bti={'Clear_Bioturbation_Index','Index_1','Index_2','Index_3','Index_4','Index_5'};

%% Core ID and Location

%..........................................................................
%Text 
f.txt(1)=uicontrol('units','normalized','style','text',...
    'position',[0.525 0.975 0.1 0.015],...
    'string','Core ID','fontunits','normalized','fontsize',0.8);

f.txt(2)=uicontrol('units','normalized','style','text',...
    'position',[0.775 0.975 0.1 0.015],...
    'string','Core Loc','fontunits','normalized','fontsize',0.8);
%..........................................................................
%Edit Panel
id_cstr={'Name (no spaces):','EOD:','Modern or Ancient:',...
    'Type (core or strat):','Formation:','Vertical units (m, ft, km):'}';
idstr=cellfun(@(x)[x ''], id_cstr, 'UniformOutput', false);
f.ed(1)=uicontrol('units','normalized','style','edit',...
    'position',[0.45 0.92 0.25 0.05],...
    'string',idstr,...
    'tag','core_id','Max',6, 'HorizontalAlignment','left','FontWeight','normal');

pos_cstr={'Latitude:','Longitude:','Xutm:','Yutm:','GeoCordSystem:','Projection:'}';
posstr=cellfun(@(x)[x ''], pos_cstr, 'UniformOutput', false);
f.ed(2)=uicontrol('units','normalized','style','edit',...
    'position',[0.70 0.92 0.25 0.05],...
    'string',posstr,....
    'tag','core_pos','Max',6,'HorizontalAlignment','left','FontWeight','normal');

%% Digitizer Panel

DigPan=uipanel('Title','Digitizer','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.45 0.45 0.53 0.45]);

%% Digitizer: Set Vertical and Grain Size Limits

%..........................................................................
%Text
f.txt(3)=uicontrol('units','normalized','style','text',...
    'position',[0.66 0.86 0.08 0.017],...
    'string','Axes','fontunits','normalized','fontsize',0.8);

%..........................................................................
%Radio Button
f.rb(1)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.843 0.16 0.015],...
    'string','Set Vertical Scale',...
    'tag','VertScale',...
    'callback',@vs_callback,'fontunits','normalized','fontsize',0.8);
    
f.rb(2)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.75 0.843 0.16 0.015],...
    'string','Grain Size','callback',@gs_callback,...
    'fontunits','normalized','fontsize',0.8,'tag','gs');
    

%..........................................................................
%Edit Panel
f.ed(3)=uicontrol('units','normalized','style','edit',...
    'position',[0.465 0.8105 0.1 0.015],...
    'string','Bottom',....
    'tag','Cbase','fontunits','normalized','fontsize',0.7);

f.ed(4)=uicontrol('units','normalized','style','edit',...
    'position',[0.585 0.8105 0.1 0.015],...
    'string','Top','tag','Ctop','fontunits','normalized','fontsize',0.7);

%..........................................................................
%Popup
f.pp(1)=uicontrol('units','normalized','style','popup',...
        'position',[0.7 0.817 0.07 0.014],...
        'string',gs1,....
        'tag','min_gs','fontunits','normalized','fontsize',0.7);
    
f.pp(2)=uicontrol('units','normalized','style','pop',...
        'position',[0.78 0.817 0.07 0.014],...
        'string',gs2,'tag','max_gs','fontunits','normalized','fontsize',0.7);

f.pp(3)=uicontrol('units','normalized','style','pop',...
        'position',[0.86 0.817 0.07 0.014],...
        'string',gs1_2,'tag','nl_gs','fontunits','normalized','fontsize',0.7);


%% Digitizer: Profile

%..........................................................................
%Radio Button
f.rb(3)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.77 0.12 0.017],...
    'callback',@prof_callback,'string','Log Profile',...
    'fontunits','normalized','fontsize',0.8,'tag','log_prof');

%..........................................................................

%% Digitizer: Lithotype Scheme

%..........................................................................
%Text
f.txt(4)=uicontrol('units','normalized','style','text',...
    'position',[0.485 0.74 0.20 0.019],...
    'string','Lithotype Scheme','fontunits','normalized','fontsize',0.7);

%..........................................................................
%Radio Button
f.rb(4)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.52 0.715 0.12 0.015],...
    'callback',{@Shell_callback,f,GenLith_sed,GenLith},'string','Shell',...
    'fontunits','normalized','fontsize',0.8);

f.rb(5)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.52 0.69 0.20 0.015],...
    'callback',{@BA_callback,f,BA_sed,BA},'string','Badley Ashton',...
    'fontunits','normalized','fontsize',0.8);

f.rb(6)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.52 0.665 0.12 0.015],...
    'callback',{@Robertson_callback,f,Robertson_sed,Robertson},'string','Robertson',...
    'fontunits','normalized','fontsize',0.8);

%% Digitizer: Other Observations

%..........................................................................
%Radio Button
f.rb(7)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.63 0.20 0.015],...
    'callback',{@tf_callback,f,tf},'string','Trace Fossils',...
    'fontunits','normalized','fontsize',0.7);

f.rb(8)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.605 0.20 0.015],...
    'callback',{@org_callback,f,organics,org},'string','Organics',...
    'fontunits','normalized','fontsize',0.7);

f.rb(9)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.58 0.20 0.015],...
    'callback',{@surf_callback,f,surfaces,srfclst},'string','Surfaces/Clasts',...
    'fontunits','normalized','fontsize',0.7);

f.rb(10)=uicontrol('units','normalized','style','radiobutton',...
    'position',[0.5 0.555 0.20 0.015],...
    'callback',{@bio_callback,f,bti},'string','Bioturbation Index',...
    'fontunits','normalized','fontsize',0.7);

%% Save and Export 

f.pb(1)=uicontrol('units','normalized','style','pushbutton',...
        'position',[0.48 0.525 0.2 0.015],'string','Export to Workspace',...
        'fontunits','normalized','fontsize',0.6);

f.pb(2)=uicontrol('units','normalized','style','pushbutton',...
          'position',[0.48 0.50 0.2 0.015],'string','Export to Matfile',...
          'fontunits','normalized','fontsize',0.6);   
      
 f.pb(3)=uicontrol('units','normalized','style','pushbutton',...
     'position',[0.48 0.475 0.2 0.015],'string','Update active interp',...
          'fontunits','normalized','fontsize',0.6);   
      
      
%% Source Information

SRCPan=uipanel('Title','Source Information','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.45 0.34 0.53 0.09]);

%set up author/citation information 
src_cstr={'Author:','Citation:','Depositional Setting:','Comments:'};
srcstr=cellfun(@(x)[x ''], src_cstr, 'UniformOutput', false);
f.ed(5)=uicontrol('units','normalized','style','edit',...
    'position',[0.47 0.345 0.5 0.063],...
    'string',srcstr,....
    'tag','srcinfo','Max',6,'fontunits','normalized','fontsize',0.15,...
    'HorizontalAlignment','left','FontWeight','normal');

%% Notes Panel 2: Dates

AgePan=uipanel('Title','Age Dates','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.45 0.22 0.53 0.10]);

%set up author/citation information 
age_cstr={'Dates (numeric only, space separated):','Dates ID (space separated):',...
    'Depth (numeric only, space separated):','Units (m, ft, km):','Time units (yr, kyr, myr):'}';
agestr=cellfun(@(x)[x ''], age_cstr, 'UniformOutput', false);
f.ed(6)=uicontrol('units','normalized','style','edit',...
    'position',[0.47 0.225 0.5 0.073],...
    'string',agestr,....
    'tag','srcinfo','Max',6,'fontunits','normalized','fontsize',0.13,...
    'HorizontalAlignment','left','FontWeight','normal');

%% Well Tops Panel

WTPan=uipanel('Title','Well Tops','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.45 0.11 0.53 0.09]);

%set up author/citation information 
wt_cstr={'Horizon name (space separated):','Horizon depth (numeric only, space separated):','Units (m, ft, km):'};
wtstr=cellfun(@(x)[x ''], wt_cstr, 'UniformOutput', false);
f.ed(7)=uicontrol('units','normalized','style','edit',...
    'position',[0.47 0.115 0.5 0.065],...
    'string',wtstr,....
    'tag','srcinfo','Max',6,'fontunits','normalized','fontsize',0.15,...
    'HorizontalAlignment','left','FontWeight','normal');

%% Additional Measurements
MEASPan=uipanel('Title','Channel Dimensions','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.45 0.01 0.24 0.08]);
meas_cstr={'Channel depth:','Channel width:','Units (m, ft, km):'}';
measstr=cellfun(@(x)[x ''], meas_cstr, 'UniformOutput', false);

%set up additional measurement information
f.ed(8)=uicontrol('units','normalized','style','edit',...
    'position',[0.47 0.015 0.21 0.05],...
    'string',measstr,....
    'tag','srcinfo','Max',6,'fontunits','normalized','fontsize',0.18,...
    'HorizontalAlignment','left','FontWeight','normal');

%% Load Sediment Sample
%note: this is inactive for now.
SedSampPan=uipanel('Title','Load Sed Samples','Fontsize',12,'BackgroundColor',[0.94 0.94 0.94],...
    'position',[0.735 0.01 0.24 0.08]);



%% Digitizer Table Setup
% cnames={'Visible','Digitize'};
% columnformat = {'logical', 'char'};
% columneditable =  [true false]; 
% 
% f.t(1)=uitable('units','normalized','position',...
%      [0.7 0.47 0.20 0.31],'ColumnName',cnames,'RowName',[],...
%      'ColumnFormat',columnformat,'ColumnEditable',columneditable,...
%      'ColumnWidth','auto','fontunits','normalized','fontsize',1);


%% Menu 
f.mh=uimenu(f.fh,'Label','Load');
uimenu(f.mh,'Label','Image','callback',@callback_loadImage);
uimenu(f.mh,'Label','Points','callback',{@callback_loadPoints,f,gs1,gs2,gs1_2,...
    GenLith_sed,BA_sed,Robertson_sed,tf,org,srfclst,bti});


%% Initialize App Data

%.........................................................................
%figure aspects
setappdata(gcf,'axlim',[]); 
setappdata(gcf,'H',[]);
setappdata(gcf,'pinPoints',0);
setappdata(gcf,'pos',1);
setappdata(gcf,'pos2',1);

%..........................................................................
%marker specs
markerSpecs = struct('statColor',[0 0 1],'dragColor',[1 0 0],'size',6,...
    'style','o');
setappdata(gcf,'markerSpecs',markerSpecs);

%..........................................................................
% Core limits - vertical
setappdata(gcf,'VertScale',[]) %radio button f.rb(1)

%..........................................................................
%Grain size (core limits - horizontal)
setappdata(gcf,'gs',[]);    %radio button f.rb(2)

%..........................................................................
%Log Profile (temp values)
setappdata(gcf,'log_prof',[]);
%setappdata(gcf,'bed',[200 300; 100 500; 70 400 ;20 90]); 
%setappdata(gcf,'bedprofile',[2 20; 30 30; 40 40; 50 50]);
setappdata(gcf,'bed',[]); 
setappdata(gcf,'bedprofile',[]);
%..........................................................................
%Sedimentary Structures 
for i=1:numel(GenLith)
    setappdata(gcf,GenLith_sed{i},[]);
end


for i=1:numel(BA)
    setappdata(gcf,BA_sed{i},[]);
end

for i=1:numel(Robertson)
    setappdata(gcf,Robertson_sed{i},[]);
end

%..........................................................................
%Ichnology
for i=1:numel(tf)
    setappdata(gcf,tf{i},[])
end

%..........................................................................
%Organics
for i=1:numel(organics)
    setappdata(gcf,org{i},[]);
end

%..........................................................................
%Surfaces and clasts
for i=1:numel(surfaces)
    setappdata(gcf,srfclst{i},[]);
end

%..........................................................................
%Bioturbation index
for i=1:numel(bti)
    setappdata(gcf,bti{i},[]);
end

%% Set Callbacks for Export and Save

set(f.pb(1),'callback',{@base_callback,f,gs1,gs2,gs1_2,GenLith_sed,BA_sed,...
    Robertson_sed,tf,org,srfclst,bti});
set(f.pb(2),'callback',{@write_file_callback,f,gs1,gs2,gs1_2,GenLith_sed,...
    BA_sed,Robertson_sed,tf,org,srfclst,bti});
set(f.pb(3),'callback',{@update_interp_callback,f,GenLith_sed,...
    BA_sed,Robertson_sed,tf,org,srfclst,bti});



%% Callback Functions: Load Image and Points

%load image................................................................
function callback_loadImage(varargin)
[fname,pathName] = uigetfile('*.*');
if isequal(fname,0)
    return
end
initializeAxes([pathName,fname]);

%% 

%load points...............................................................
function callback_loadPoints(varargin)

    f=varargin{3};
    gs1=varargin{4};
    gs2=varargin{5};
    gs1_2=varargin{6};
    GenLith_sed=varargin{7};
    BA_sed=varargin{8};
    Robertson_sed=varargin{9};
    tf=varargin{10};
    org=varargin{11};
    srfclst=varargin{12};
    bti=varargin{13};


% Check if an image has been loaded
xlim=get(f.ax,'Xlim');
ylim=get(f.ax,'Ylim');
if xlim(1)==0 && ylim(1)==0 && xlim(2)==1 && ylim(2)==1
    errordlg('Please load an image before loading points.','Error')
    return
end

% Get a points file
[fname,pathName] = uigetfile('*.mat','MAT files (*.mat)');
if isequal(fname,0)
    return
end

w = whos('-file',[pathName fname]);
ch=arrayfun(@(x)findstr(lower(x.name),'pix'),w,'UniformOutput',false);
pfile=w(cellfun(@(x)~isempty(x),ch)==1).name;

load([pathName,fname]);
pdat=eval(pfile); %pdat = loaded pix structure file


pgen=pdat.General_Lithotypes;
pBA=pdat.Badley_Ashton;
pRB=pdat.Robertson;
ptf=pdat.Trace_Fossils;
porg=pdat.Organics;
psrfclst=pdat.Surfaces_and_Clasts;
pbti=pdat.Bioturbation_Index;


%Delete Existing Data
delete(getappdata(gca,'H'));

%Set Point AppData
setappdata(gcf,'VertScale',pdat.pvs);
setappdata(gcf,'gs',pdat.pgs);
setappdata(gcf,'bed',pdat.bed);
setappdata(gcf,'bedprofile',pdat.bedprofile);

%Set Sedimentary Structures AppData
for i=2:length(GenLith_sed)

     if isfield(pgen,GenLith_sed{i})==1
         setappdata(gcf,GenLith_sed{i},pgen.(GenLith_sed{i}))
     end
    
end

for i=2:length(BA_sed)

     if isfield(pBA,BA_sed{i})==1
         setappdata(gcf,BA_sed{i},pBA.(BA_sed{i}))
     end
    
end

for i=2:length(Robertson_sed)

     if isfield(pRB,Robertson_sed{i})==1
         setappdata(gcf,Robertson_sed{i},pRB.(Robertson_sed{i}))
     end
    
end

%Trace Fossils
for i=1:length(tf)
    
    if isfield(ptf,tf{i})==1
        setappdata(gcf,tf{i},ptf.(tf{i}))
    end
    
end

%Organics
for i=1:length(org)
    
    if isfield(porg,org{i})==1
        setappdata(gcf,org{i},porg.(org{i}))
    end
    
end

%Surfaces and Clasts
for i=1:length(srfclst)
    
    if isfield(psrfclst,srfclst{i})==1
        setappdata(gcf,srfclst{i},psrfclst.(srfclst{i}))
    end
    
end

%Bioturbation Index
for i=2:length(bti)
    
    if isfield(pbti,bti{i})==1
        setappdata(gcf,bti{i},pbti.(bti{i}))
    end
    
end

%Set Dropdown & Edit Box AppData 

% Core ID
set(f.ed(1),'string',pdat.header1);

%Core Pos
set(f.ed(2),'string',pdat.header2);

%Vertical Scales
set(f.ed(3),'string',pdat.uvs(1));
set(f.ed(4),'string',pdat.uvs(2));


%Grain Size
if length(pdat.pgs)==2
    
    pind1=find(ismember(gs1,pdat.ugs{1})==1);
    pind2=find(ismember(gs1,pdat.ugs{2})==1);

    set(f.pp(1),'val',pind1);
    set(f.pp(2),'val',pind2);

else

    pind1=find(ismember(gs1,pdat.ugs{1})==1);
    pind2=find(ismember(gs1,pdat.ugs{2})==1);
    pind3=find(ismember(gs1_2,pdat.ugs{3})==1);
    
    set(f.pp(1),'val',pind1);
    set(f.pp(2),'val',pind2);
    set(f.pp(3),'val',pind3);
    

end

%Source
Source=pdat.Source;
set(f.ed(5),'string',Source);

%Age Dates
Age_Dates=pdat.Age_Dates;
set(f.ed(6),'string',Age_Dates);

Well_Tops=pdat.Well_Tops;
set(f.ed(7),'string',Well_Tops);

%Channel Dimensions
Channel_Dimensions=pdat.Channel_Dimensions;
set(f.ed(8),'string',Channel_Dimensions);




%% Display Log Image Functions

function initializeAxes(fname)
    displayImage(fname)
%%
    
function displayImage(fname)
    X=imread(fname);
    ih = imagesc(X);
    set(ih,'buttonDownFcn',@createPoint)
    axis equal %tight
    hold on
    axlim = [get(gca,'xlim') get(gca,'ylim')];
    setappdata(gcf,'axlim',axlim)

%% Set Vertical Axis Functions

%(1) Vertical Axis 
function vs_callback(varargin)  
    %sme_callback
    if get(gcbo,'Value')==1; %On Call 
        if ~isempty(getappdata(gcf,'VertScale')); 
        XY=getappdata(gcf,'VertScale');
        H = plotPoint(XY);   
        setappdata(gcf,'H',H);
        end
    else %Off Call 
        [VertScale] = getXY;
        setappdata(gcf,'VertScale',VertScale);
        assignin('base','VertScale',VertScale);
        delete(getappdata(gcf,'H'))
        setappdata(gcf,'H',[])   
    end 


%% Set Grain Size Functions

function gs_callback(varargin) 

if get(gcbo,'Value')==1; %On Call
    if ~isempty(getappdata(gcf,'gs'));
        XY=getappdata(gcf,'gs');
        H = plotPoint(XY);
        setappdata(gcf,'H',H);
    end
else %Off Call 
    [gs] = getXY;
    setappdata(gcf,'gs',gs)
    assignin('base','gs',gs);
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

%% Digitizing Functions

function createPoint(varargin)
    xy = get(gca,'CurrentPoint');
    xy = xy(1,1:2);
    h = plotPoint(xy);
    setappdata(gcf,'H',[getappdata(gcf,'H'); h]);
    %Enable dragging until button is relased
    set(gcf,'WindowButtonMotionFcn',{@dragPoint,h},'WindowButtonUpFcn',{@buttonUp,h})
%%

function [H] = plotPoint(XY)
    H = zeros(size(XY,1),1);
    markerSpecs = getappdata(gcf,'markerSpecs');
    for k=1:size(XY,1)
        H(k) = plot(XY(k,1),XY(k,2),'.');
        %Menu options to delete points (with callbacks)
        cmenu = uicontextmenu;
        uimenu(cmenu, 'Label', 'Delete this point','Callback', {@deletePoint,H(k)});
        uimenu(cmenu, 'Label', 'Delete all points...','Callback', @deleteAllPoints,'separator','on');
        set(H(k),'UIContextMenu', cmenu)
     
    
        set(H(k),'Color',markerSpecs.statColor,...
            'MarkerSize',markerSpecs.size,...
            'Marker',markerSpecs.style,...
            'ButtonDownFcn',@clickPoint);
    end
    setappdata(gcf,'CurrentDynamicPlot',H); %sets handle for current dynamic plot
    
%%

function clickPoint(h,varargin)
    if ~getappdata(gcf,'pinPoints')
        markerSpecs = getappdata(gcf,'markerSpecs');
        set(h,'color',markerSpecs.dragColor);
        set(gcf,'WindowButtonMotionFcn',{@dragPoint,h},'WindowButtonUpFcn',{@buttonUp,h});
    end
%%

function dragPoint(varargin)
    h = varargin{3};
    markerSpecs = getappdata(gcf,'markerSpecs');
    set(h,'color',markerSpecs.dragColor);
    % Ensure that the dragged point lies within the axis bounds:
    axlim = getappdata(gcf,'axlim');
    X = get(gca,'currentpoint');
    [x,y] = deal(X(1,1),X(1,2));
    if x<axlim(1)
        x=axlim(1);
    elseif x>axlim(2)
        x=axlim(2);
    end
    if y<axlim(3)
        y=axlim(3);
    elseif y>axlim(4)
        y=axlim(4);
    end
    % Update marker position
    set(h,'xdata',x,'ydata',y);
%%

function buttonUp(varargin)
    h=varargin{3};
    markerSpecs = getappdata(gcf,'markerSpecs');
    set(h,'color',markerSpecs.statColor);
    set(gcf,'WindowButtonMotionFcn',[],'WindowButtonUpFcn',[]);
%% 

function deletePoint(varargin)
    h = varargin{3};
    H = getappdata(gcf,'H');
    H(H==h)=[];
    setappdata(gcf,'H',H);
    delete(h);
%%

function deleteAllPoints(varargin)
    button = questdlg('OK to delete all points?','Warning!!','OK','Cancel','OK');
    if isequal(button,'Cancel')
        return
    end
    delete(getappdata(gcf,'H'))
    setappdata(gcf,'H',[])
    
%%   

function [XY] = getXY     %Call XY
H = getappdata(gcf,'H');
XY = [get(H,'xdata') get(H,'ydata')];
if length(H)>1
    XY = cell2mat(XY);
end

%% Save Active Interpretation
function update_interp_callback(varargin)
    f=varargin{3};
    GenLith_sed=varargin{4};
    BA_sed=varargin{5};
    Robertson_sed=varargin{6};
    tf=varargin{7};
    org=varargin{8};
    srfclst=varargin{9};
    bti=varargin{10};
    
    [tmp]=getXY;
     status=get(f.rb,'Value');
    
    %bed and bed profile   
    if status{3}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        if prevCell.Indices(1)==1
            setappdata(gcf,'bed',tmp); 
            assignin('base','bed',tmp);
            
        elseif prevCell.Indices(1)==2
            setappdata(gcf,'bedprofile',tmp);
            assignin('base','bedprofile',tmp);
        end
        
    end
    
    %shell lithofacies
    if status{4}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,GenLith_sed{rcurr},tmp);
    end
    
    %Badley Ashton Lithofacies
    if status{5}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,BA_sed{rcurr},tmp);
    end
    
    %Robertson Lithofacies
    if status{6}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,Robertson_sed{rcurr},tmp);
    end
    
    %Trace Fossils
    if status{7}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,tf{rcurr},tmp);
    end
    
    %Organics
    if status{8}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,org{rcurr},tmp);
    end
    
    %Surfaces/Clasts
    if status{9}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,srfclst{rcurr},tmp);
    end
    
    %Bioturbation
    if status{10}==1
        prevCell=getappdata(gcf,'PreviousCellConfig');
        rcurr=prevCell.Indices(1);
        setappdata(gcf,bti{rcurr},tmp);
    end


%%
    
%% Bed Profile and Lithology Radio Button Callbacks

function prof_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging vertical profile
 
        dat =  {false,  'Bed Top';...
        false, 'Bed Profile'};

        cnames={'Visible','Digitize'};
        columnformat = {'logical', 'char'};
        columneditable =  [true false]; 

        f.t(1)=uitable('units','normalized','position',...
            [0.7 0.47 0.25 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','ProfileTable',...
            'ColumnWidth','auto','fontunits','normalized','fontsize',0.025);

        %Set Callbacks  for table    
        set(f.t(1),'CellSelectionCallback',{@CallBack1,f,dat})
        set(f.t(1),'CellEditCallback',{@Toggle_CallBack1,f,dat}) 
    
        %set table app data    
        h=findobj(f.t(1));
        setappdata(gcf,'ProfileTable',f.t(1));
          
    else %off call
        %store all data appropriately
        hh=findobj(gcf,'Color','m','-or','Color','b');
        set(hh,'Visible','off');
        setappdata(gcf,'PreviousCellConfig',[]);
        setappdata(gcf,'PreviousToggleConfig',[]);
        clear bed bedprofile
        
        h=getappdata(gcf,'ProfileTable');
        %remove table  
        delete(h);    
    end

%% 

function Shell_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging General Lithofacies (Shell lithofacies

        f=varargin{3}; 
        GenLith_sed=varargin{4}; %variables #GenLith
        GenLith=varargin{5}; %labels #Shell

        checkbox1=num2cell(logical(zeros(length(GenLith),1)));

        dat =[checkbox1 GenLith'];

        cnames =   {'Visible', 'Facies'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(2)=uitable('units','normalized','position',...
        [0.7 0.47 0.25 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','ShellFaciesTable',...
            'ColumnWidth',{55 130},'fontunits','normalized','fontsize',0.025);
        
        %Set Callbacks  for table    
        set(f.t(2),'CellSelectionCallback',{@CallBack2,f,GenLith_sed})
        set(f.t(2),'CellEditCallback',{@Toggle_CallBack2,f,GenLith_sed}) 

        %set table app data    
        h=findobj(f.t(2));
        setappdata(gcf,'ShellFaciesTable',f.t(2));

    else %off call
        %remove all plots and reset table config
        hh=findobj(gcf,'Color','m','-or','Color','b');
        set(hh,'Visible','off');
        setappdata(gcf,'PreviousCellConfig',[]);
        setappdata(gcf,'PreviousToggleConfig',[]);
        
        h= getappdata(gcf,'ShellFaciesTable');
        %remove table  
        delete(h);    
    end

%%

function BA_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging BA Lithofacies 

        f=varargin{3}; 
        BA_sed=varargin{4};
        BA=varargin{5};

        checkbox1=num2cell(logical(zeros(length(BA_sed),1)));

        dat =[checkbox1 BA'];

        cnames =   {'Visible', 'Facies'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(3)=uitable('units','normalized','position',...
            [0.7 0.47 0.25 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{45 140},'fontunits','normalized','fontsize',0.025);

         %Set Callbacks  for table    
        set(f.t(3),'CellSelectionCallback',{@CallBack3,f,BA_sed})
        set(f.t(3),'CellEditCallback',{@Toggle_CallBack3,f,BA_sed}) 
        
        %set table app data    
        h=findobj(f.t(3));
        setappdata(gcf,'BAFaciesTable',f.t(3));

    else %off call
        %remove all plots and reset table config
        
        setappdata(gcf,'PreviousCellConfig',[]);
        setappdata(gcf,'PreviousToggleConfig',[]);
        
        h=getappdata(gcf,'BAFaciesTable');
        delete(h);
        %remove table  
        
    end

%%

function Robertson_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging BA Lithofacies 

        f=varargin{3}; 
        Robertson_sed=varargin{4};
        Robertson=varargin{5};

        checkbox1=num2cell(logical(zeros(length(Robertson),1)));

        dat =[checkbox1 Robertson'];

        cnames =   {'Visible', 'Facies'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(4)=uitable('units','normalized','position',...
            [0.7 0.47 0.28 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{45 250},'fontunits','normalized','fontsize',0.025);
        
         %Set Callbacks  for table    
        set(f.t(4),'CellSelectionCallback',{@CallBack4,f,Robertson_sed})
        set(f.t(4),'CellEditCallback',{@Toggle_CallBack4,f,Robertson_sed}) 

        %set table app data    
        h=findobj(f.t(4));
        setappdata(gcf,'RobertsonFaciesTable',f.t(4));

    else %off call
        %store all data appropriately
        h= getappdata(gcf,'RobertsonFaciesTable');
        %remove table  
        delete(h);    
    end

%%

function tf_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging trace fossils

        f=varargin{3}; 
        tf=varargin{4};
        

        checkbox1=num2cell(logical(zeros(length(tf),1)));

        dat =[checkbox1 tf'];

        cnames =   {'Visible', 'Trace Fossils'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(5)=uitable('units','normalized','position',...
            [0.7 0.47 0.28 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{55 130},'fontunits','normalized','fontsize',0.025);
        
         %Set Callbacks  for table    
        set(f.t(5),'CellSelectionCallback',{@CallBack5,f,tf})
        set(f.t(5),'CellEditCallback',{@Toggle_CallBack5,f,tf}) 

        %set table app data    
        h=findobj(f.t(5));
        setappdata(gcf,'TraceFossilsTable',f.t(5));

    else %off call
        %store all data appropriately
        h= getappdata(gcf,'TraceFossilsTable');
        %remove table  
        delete(h);    
    end

%%

function org_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
    %set up table for logging trace fossils

        f=varargin{3}; 
        organics=varargin{4};
        org=varargin{5};
        

        checkbox1=num2cell(logical(zeros(length(organics),1)));

        dat =[checkbox1 organics'];

        cnames =   {'Visible', 'Organics'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(6)=uitable('units','normalized','position',...
            [0.7 0.47 0.28 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{55 130},'fontunits','normalized','fontsize',0.025);
        
         %Set Callbacks  for table    
        set(f.t(6),'CellSelectionCallback',{@CallBack6,f,org});
        set(f.t(6),'CellEditCallback',{@Toggle_CallBack6,f,org});

        %set table app data    
        h=findobj(f.t(6));
        setappdata(gcf,'OrganicsTable',f.t(6));

    else %off call
        %store all data appropriately
        h= getappdata(gcf,'OrganicsTable');
        %remove table  
        delete(h);   
    end
        
%%

function surf_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
        %set up table for logging trace fossils

        f=varargin{3}; 
        surfaces=varargin{4};
        srfclst=varargin{5};
        

        checkbox1=num2cell(logical(zeros(length(surfaces),1)));

        dat =[checkbox1 surfaces'];

        cnames =   {'Visible', 'Surfaces/Clasts'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(7)=uitable('units','normalized','position',...
            [0.7 0.47 0.28 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{55 130},'fontunits','normalized','fontsize',0.025);
        
         %Set Callbacks  for table    
        set(f.t(7),'CellSelectionCallback',{@CallBack7,f,srfclst});
        set(f.t(7),'CellEditCallback',{@Toggle_CallBack7,f,srfclst}); 

        %set table app data    
        h=findobj(f.t(7));
        setappdata(gcf,'SurfacesTable',f.t(7));

        else %off call
            %store all data appropriately
            h= getappdata(gcf,'SurfacesTable');
            %remove table  
            delete(h);   
        end
 
%%

function bio_callback(varargin)
    if get(gcbo,'Value')==1; %On Call 
        %set up table for logging trace fossils

        f=varargin{3}; 
        bti=varargin{4};
        

        checkbox1=num2cell(logical(zeros(length(bti),1)));

        dat =[checkbox1 bti'];

        cnames =   {'Visible', 'Bioturbation Index'};
        columnformat = {'logical', 'char'};
        columneditable =  [true true]; 

        f.t(8)=uitable('units','normalized','position',...
            [0.7 0.47 0.28 0.31],'ColumnName',cnames,'RowName',[],...
            'Data',dat,'ColumnFormat',columnformat,...
            'ColumnEditable',columneditable,'tag','BAFaciesTable',...
            'ColumnWidth',{55 130},'fontunits','normalized','fontsize',0.025);
        
         %Set Callbacks  for table    
        set(f.t(8),'CellSelectionCallback',{@CallBack8,f,bti});
        set(f.t(8),'CellEditCallback',{@Toggle_CallBack8,f,bti}); 

        %set table app data    
        h=findobj(f.t(8));
        setappdata(gcf,'BioTable',f.t(8));

        else %off call
            %store all data appropriately
            h= getappdata(gcf,'BioTable');
            %remove table  
            delete(h);   
    end
        
 %%
function CallBack1(varargin)   
% table data entry for core profile: cell selection
%   function that keeps track of active cells   

    evt=varargin{2};
    f=varargin{3};  
    TBL=get(f.t(1),'Data');
    
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
   %.......................................................................
   %cases where a toggle is turned on
   
   if TBL{1}==1 && evt.Indices(2)==1 || TBL{2}==1 && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
   end
   if TBL{1}==1 && evt.Indices(2)==2 && isempty(prevCell) || TBL{2}==1 && evt.Indices(2)==2 && isempty(prevCell) 
        if evt.Indices(1)==1              
            XY=getappdata(gcf,'bed'); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end            
        elseif evt.Indices(1)==2  %             
            XY=getappdata(gcf,'bedprofile');
            if ~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                 
            end
        end
   elseif TBL{1}==1 && evt.Indices(2)==2 && ~isempty(prevCell) || TBL{2}==1 && evt.Indices(2)==2 && ~isempty(prevCell)
       if prevCell.Indices(1)==1 %previous cell was 'bed' - remove
            [bed] = getXY;
            setappdata(gcf,'bed',bed);
            assignin('base','bed',bed);
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);            
       elseif prevCell.Indices(1)==2 %previous cell was 'profile' - remove
            [bedprofile] = getXY;
            setappdata(gcf,'bedprofile',bedprofile);
            assignin('base','bedprofile',bedprofile);
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);            
       end
       if evt.Indices(1)==1              
            XY=getappdata(gcf,'bed'); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end            
        elseif evt.Indices(1)==2  %             
            XY=getappdata(gcf,'bedprofile');
            if ~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);               
            end
       end  
   end
   
   %.......................................................................
   %cases where no toggles are turned on 
   
   if evt.Indices(2)==2 && TBL{1}==0 && TBL{2}==0 %no toggles but a cell is selected
       if isempty(prevCell)
            if evt.Indices(1)==1              
                XY=getappdata(gcf,'bed'); 
                if~isempty(XY)
                    H = plotPoint(XY);   
                    setappdata(gcf,'H',H);                
                end            
            elseif evt.Indices(1)==2              
                XY=getappdata(gcf,'bedprofile');
                if ~isempty(XY)
                    H = plotPoint(XY);   
                    setappdata(gcf,'H',H);                                              
                end
            end
       end
       if ~isempty(prevCell)
           if prevCell.Indices(1)==1 %previous cell was 'bed' - remove
                [bed] = getXY;
                setappdata(gcf,'bed',bed);
                assignin('base','bed',bed);
                delete(getappdata(gcf,'H'));
                setappdata(gcf,'H',[]);            
            elseif prevCell.Indices(1)==2 %previous cell was 'profile' - remove
                [bedprofile] = getXY;
                setappdata(gcf,'bedprofile',bedprofile);
                assignin('base','bedprofile',bedprofile);
                delete(getappdata(gcf,'H'));
                setappdata(gcf,'H',[]);
           end
            if evt.Indices(1)==1              
                XY=getappdata(gcf,'bed'); 
                if~isempty(XY)
                    H = plotPoint(XY);   
                    setappdata(gcf,'H',H);                
                end            
            elseif evt.Indices(1)==2  %             
                XY=getappdata(gcf,'bedprofile');
                if ~isempty(XY)
                    H = plotPoint(XY);   
                    setappdata(gcf,'H',H);                                             
                end
            end      
       end
   end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end
   
%%

function Toggle_CallBack1(varargin)  
%   %table data entry for core profile: toggle
%   function keeps track of what's visible (non-editable) on the figure

    evt=varargin{2};
    f=varargin{3};

    TBL=get(f.t(1),'Data');    
    bed=getappdata(gcf,'bed');
    bedprofile=getappdata(gcf,'bedprofile');
    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    if isempty(prevTBL)  
        if TBL{1}==1   
            if ~isempty(bed)              
                plot(bed(:,1),bed(:,2),'m.');
                dataHbed=get(gca,'Children');
                setappdata(gcf,'plotbed',dataHbed);
            end
        elseif TBL{1}==0
            dataHbed=getappdata(gcf,'plotbed');
            if ~isempty(dataHbed)
                set( dataHbed(1), 'visible', 'off' )
            end
        end            
        if TBL{2}==1
            if ~isempty(bedprofile)
                plot(bedprofile(:,1),bedprofile(:,2),'m.');
                dataHbedprofile=get(gca,'Children');
                setappdata(gcf,'plotbedprofile',dataHbedprofile);
            end
        elseif TBL{2}==0
            dataHbedprofile=getappdata(gcf,'plotbedprofile');
            if ~isempty(dataHbedprofile)
                set( dataHbedprofile(1), 'visible', 'off' )
            end
        end
    end
        
    if ~isempty(prevTBL)
        if TBL{1}==1 && prevTBL{1}==1  %do nothing because points are already plotted
        elseif TBL{1}==1 && prevTBL{1}==0 %plot points
            if ~isempty(bed)              
                plot(bed(:,1),bed(:,2),'m.');
                dataHbed=get(gca,'Children');
                setappdata(gcf,'plotbed',dataHbed);
            end
        elseif TBL{1}==0 && prevTBL{1}==1
            dataHbed=getappdata(gcf,'plotbed');
            if ~isempty(dataHbed)
                set( dataHbed(1), 'visible', 'off' )
            end
        end        
        
        if TBL{2}==1 && prevTBL{2}==1 %do nothing because points are already plotted
        elseif TBL{2}==1 && prevTBL{2}==0 %plot points
            if ~isempty(bed)              
                plot(bedprofile(:,1),bedprofile(:,2),'m.');
                dataHbedprofile=get(gca,'Children');
                setappdata(gcf,'plotbedprofile',dataHbedprofile);
            end
        elseif TBL{2}==0 && prevTBL{2}==1
            dataHbedprofile=getappdata(gcf,'plotbedprofile');
            if ~isempty(dataHbedprofile)
                set( dataHbedprofile(1), 'visible', 'off' )
            end            
        end
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
    

%%

function CallBack2(varargin)
% table data entry for General Lithofacies (Shell): cell selection

    evt=varargin{2};
    f=varargin{3};  
    GenLith_sed=varargin{4};
    TBL=get(f.t(2),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,GenLith_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,GenLith_sed{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,GenLith_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,GenLith_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,GenLith_sed{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,GenLith_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack2 (varargin)
%table data entry for General Lithofacies (shell): toggle

    evt=varargin{2};
    f=varargin{3};
    GenLith_sed=varargin{4};
    TBL=get(f.t(2),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,GenLith_sed{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,GenLith_sed{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
    
%%

function CallBack3(varargin)
% table data entry for Badley Ashton Lithofacies: cell selection

    evt=varargin{2};
    f=varargin{3};  
    BA_sed=varargin{4};
    TBL=get(f.t(3),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,BA_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,BA_sed{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,BA_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,BA_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,BA_sed{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,BA_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack3 (varargin)
%table data entry for Badley Ashton Lithofacies: toggle

    evt=varargin{2};
    f=varargin{3};
    BA_sed=varargin{4};
    TBL=get(f.t(3),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,BA_sed{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,BA_sed{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
    
%%

function CallBack4(varargin)
% table data entry for Robertson Lithofacies: cell selection

    evt=varargin{2};
    f=varargin{3};  
    Robertson_sed=varargin{4};
    TBL=get(f.t(4),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,Robertson_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,Robertson_sed{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,Robertson_sed{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,Robertson_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,Robertson_sed{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,Robertson_sed{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack4 (varargin)
%table data entry for Robertson Lithofacies: toggle

    evt=varargin{2};
    f=varargin{3};
    Robertson_sed=varargin{4};
    TBL=get(f.t(4),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,Robertson_sed{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,Robertson_sed{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function

%%

function CallBack5(varargin)
% table data entry for trace fossils: cell selection

    evt=varargin{2};
    f=varargin{3};  
    tf=varargin{4};
    TBL=get(f.t(5),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,tf{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,tf{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,tf{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,tf{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,tf{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,tf{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack5 (varargin)
%table data entry for trace fossils: toggle

    evt=varargin{2};
    f=varargin{3};
    tf=varargin{4};
    TBL=get(f.t(5),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,tf{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,tf{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
    
 %%
 
 function CallBack6(varargin)
% table data entry for organics: cell selection

    evt=varargin{2};
    f=varargin{3};  
    org=varargin{4};
    TBL=get(f.t(6),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,org{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,org{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,org{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,org{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,org{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,org{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack6 (varargin)
%table data entry for organics: toggle

    evt=varargin{2};
    f=varargin{3};
    org=varargin{4};
    TBL=get(f.t(6),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,org{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,org{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
 
%%    

 function CallBack7(varargin)
% table data entry for surfaces and clasts: cell selection

    evt=varargin{2};
    f=varargin{3};  
    srfclst=varargin{4};
    TBL=get(f.t(7),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,srfclst{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,srfclst{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,srfclst{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,srfclst{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,srfclst{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,srfclst{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack7 (varargin)
%table data entry for surfaces and clasts: toggle

    evt=varargin{2};
    f=varargin{3};
    srfclst=varargin{4};
    TBL=get(f.t(7),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,srfclst{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,srfclst{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function
 
%%

function CallBack8(varargin)
% table data entry for surfaces and clasts: cell selection

    evt=varargin{2};
    f=varargin{3};  
    bti=varargin{4};
    TBL=get(f.t(8),'Data');
    
    
    %previous cell selection
    prevCell=getappdata(gcf,'PreviousCellConfig');
    
    %previous toggle selection
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %get current and past cell selection
    rcurr=evt.Indices(1);
    if ~isempty(prevCell)
        rpast=prevCell.Indices(1);
    else
        rpast=[];
    end
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end
    
    
   %.......................................................................
   %cases where a toggle is turned on
   
    if ~isempty(tcurr) && evt.Indices(2)==1  %a toggle clicked and no cell: do nothing
    end
    if ~isempty(tcurr) && evt.Indices(2)==2 && isempty(rpast)                   
        XY=getappdata(gcf,bti{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end          

   elseif ~isempty(tcurr) && evt.Indices(2)==2 && ~isempty(rpast)       
        [tmp] = getXY; %remove existing data
        setappdata(gcf,bti{rpast},tmp);            
        delete(getappdata(gcf,'H'));
        setappdata(gcf,'H',[]);        
             
        XY=getappdata(gcf,bti{rcurr}); 
        if~isempty(XY)
            H = plotPoint(XY);   
            setappdata(gcf,'H',H);             
        end 
    end   
   %.......................................................................
   %cases where no toggles are turned on 
   
    if evt.Indices(2)==2 && isempty(pos) %no toggles but a cell is selected
        if isempty(rpast)                     
            XY=getappdata(gcf,bti{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end 
        elseif ~isempty(rpast)           
            [tmp] = getXY;
            setappdata(gcf,bti{rpast},tmp);                
            delete(getappdata(gcf,'H'));
            setappdata(gcf,'H',[]);       
        
            XY=getappdata(gcf,bti{rcurr}); 
            if~isempty(XY)
                H = plotPoint(XY);   
                setappdata(gcf,'H',H);                
            end  
        end
    end
   
   
   if evt.Indices(2)==2 %only update if a cell is selected (not a toggle)
        setappdata(gcf,'PreviousCellConfig',evt); %get toggle status at end of function
   end

%%

function Toggle_CallBack8 (varargin)
%table data entry for surfaces and clasts: toggle

    evt=varargin{2};
    f=varargin{3};
    bti=varargin{4};
    TBL=get(f.t(8),'Data');    
    prevTBL=getappdata(gcf,'PreviousToggleConfig');
    
    %load all GenLith_sed data
    
    
    %get current toggle selection
    ctgls=cell2mat(TBL(1:length(TBL)));
    loc=ismember(ctgls,1); pos=find(loc==1);
    if ~isempty(pos)
        tcurr=pos;
    else
        tcurr=[];
    end
    
     %get past toggle selection
    ptgls=cell2mat(prevTBL(1:length(prevTBL)));
    ploc=ismember(ptgls,1); ppos=find(ploc==1);
    if ~isempty(ppos)
        tpast=ppos;
    else
        tpast=[];
    end    
    
    if isempty(tpast)               
        tmp=getappdata(gcf,bti{tcurr}); 
        if ~isempty(tmp)
            plot(tmp(:,1),tmp(:,2),'m.');
            dataH=get(gca,'Children');        
            setappdata(gcf,'tplot',dataH);
        end
    end
        
    if ~isempty(tpast)        
        if isempty(tcurr) %turn off existing display
            for i=1:numel(tpast)
                dataH=getappdata(gcf,'tplot'); %turn off existing plot
                hh=findobj(gcf,'Color','m');
                set( hh, 'visible', 'off' )                
            end
        elseif ~isempty(tcurr) %> 1 toggle is selected
            dataH=getappdata(gcf,'tplot'); %turn off existing plot
            hh=findobj(gcf,'Color','m');
            set( hh, 'visible', 'off' )           
            for i=1:numel(tcurr)
                tmp=getappdata(gcf,bti{tcurr(i)});   
                if ~isempty(tmp)
                    plot(tmp(:,1),tmp(:,2),'m.');
                    dataH=get(gca,'Children');
                    setappdata(gcf,'tplot',dataH); 
                end
            end
        else
        end
            
    end
    
    setappdata(gcf,'PreviousToggleConfig',TBL); %get toggle status at end of function


%% Export to Matlab

function base_callback(varargin)
    f=varargin{3};
    gs1=varargin{4};
    gs2=varargin{5};
    gs1_2=varargin{6};
    GenLith_sed=varargin{7};
    BA_sed=varargin{8};
    Robertson_sed=varargin{9};
    tf=varargin{10};
    org=varargin{11};
    srfclst=varargin{12};
    bti=varargin{13};
    
    [Pix,C]=Cformat(f,gs1,gs2,gs1_2,GenLith_sed,BA_sed,Robertson_sed,...
        tf,org,srfclst,bti);

    %Assignin to Workspace
    assignin('base','Pix',Pix);
    assignin('base','C',C);
%%

function write_file_callback(varargin)

    f=varargin{3};
    gs1=varargin{4};
    gs2=varargin{5};
    gs1_2=varargin{6};
    GenLith_sed=varargin{7};
    BA_sed=varargin{8};
    Robertson_sed=varargin{9};
    tf=varargin{10};
    org=varargin{11};
    srfclst=varargin{12};
    bti=varargin{13};

    [Pix,C]=Cformat(f,gs1,gs2,gs1_2,GenLith_sed,BA_sed,Robertson_sed,...
        tf,org,srfclst,bti);


    [outfile,outdir]=uiputfile();


    if strcmp(C.name,'Core ID')==1
    
        C.name='Unknown';
    
    end
    
    Coredata=C.name;
    Pixdata=strcat(C.name,'Pix');

    eval([Coredata,'=C']);
    eval([Pixdata,'=Pix']);

    eval(['save ', strcat(outdir,outfile) ,' ', Coredata,' ', Pixdata]);
    
    
 %%

function [Pix,C]=Cformat(f,gs1,gs2,gs1_2,GenLith_sed,BA_sed,Robertson_sed,tf,org,srfclst,bti)

%-------------Map Pixel/Ref Data into Structure (xy format)----------------
% All the data that will need to be reloaded at a later date

Pix.header1=get(f.ed(1),'string'); %CORE ID info (all in string format)

Pix.header2=get(f.ed(2),'string');% CORE LOC info (all in string format)

Pix.pvs=getappdata(gcf,'VertScale');
Pix.uvs(1)=str2double(get(f.ed(3),'string')); %bottom of core (units)
Pix.uvs(2)=str2double(get(f.ed(4),'string')); %top of core (units)

Pix.pgs=getappdata(gcf,'gs'); %pixel locations of grain size picks
lgs=get(f.pp(1),'val'); ugs=get(f.pp(2),'val'); %grain size (qualitative)
ngs=get(f.pp(3),'val');

Pix.ugs{1}=gs1{lgs};
Pix.ugs{2}=gs2{ugs}; 
Pix.ugs{3}=gs1_2{ngs};


Pix.bed=getappdata(gcf,'bed');
Pix.bedprofile=getappdata(gcf,'bedprofile');

%lat + lon
spc=find(Pix.header2{1}==':');
nxt=find(Pix.header2{1}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Pix.geo(1)=str2double(Pix.header2{1}(spc+nxt:end));
else
    Pix.geo(1)=nan;
end

spc=find(Pix.header2{2}==':');
nxt=find(Pix.header2{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Pix.geo(2)=str2double(Pix.header2{2}(spc+nxt:end));
else
    Pix.geo(2)=nan;
end

%UTM
spc=find(Pix.header2{3}==':');
nxt=find(Pix.header2{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Pix.utm(1)=str2double(Pix.header2{3}(spc+nxt:end));
else
    Pix.utm(1)=nan;
end

spc=find(Pix.header2{4}==':');
nxt=find(Pix.header2{4}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Pix.utm(2)=str2double(Pix.header2{4}(spc+nxt:end));
else
    Pix.utm(2)=nan;
end

%geogcs
spc=find(Pix.header2{5}==':');
nxt=find(Pix.header2{5}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    geogcs=Pix.header2{5}(spc+nxt:end);
else
    geogcs=[];
end

%projection
spc=find(Pix.header2{6}==':');
nxt=find(Pix.header2{6}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    proj=Pix.header2{6}(spc+nxt:end);
else
    proj=[];
end


%------------------------Dynamic Field Names------------------------------- 
%For Sedimentary Structures, Ichnofacies, Orgainics, Bioturbation, and
%Surfaces and Clasts

for i=2:length(GenLith_sed) %i starts with 3 bc of 'clear field'
    General_Lithotypes.(GenLith_sed{i})=getappdata(gcf,GenLith_sed{i});
end
Pix.General_Lithotypes=General_Lithotypes;

for i=2:length(BA_sed)%i starts with 3 bc of 'clear field'
    Badley_Ashton.(BA_sed{i})=getappdata(gcf,BA_sed{i});
end
Pix.Badley_Ashton=Badley_Ashton;

for i=2:length(Robertson_sed)%i starts with 3 bc of 'clear field'
    Robertson.(Robertson_sed{i})=getappdata(gcf,Robertson_sed{i});
end
Pix.Robertson=Robertson;

No_Recovery=cell(3,1); %3 row cell for the three strat lithofacies schemes
No_Recovery{1}=getappdata(gcf,GenLith_sed{2});
No_Recovery{2}=getappdata(gcf,BA_sed{2});
No_Recovery{3}=getappdata(gcf,Robertson_sed{2});

% Pix.No_Recovery=No_Recovery;

for i=2:length(tf)
    Trace_Fossils.(tf{i})=getappdata(gcf,tf{i});
end
Pix.Trace_Fossils=Trace_Fossils;

for i=2:length(org)
    Organics.(org{i})=getappdata(gcf,org{i});
end
Pix.Organics=Organics;

for i=2:length(srfclst)
    Surfaces_and_Clasts.(srfclst{i})=getappdata(gcf,srfclst{i});
end
Pix.Surfaces_and_Clasts=Surfaces_and_Clasts;

for i=2:length(bti)
    Bioturbation_Index.(bti{i})=getappdata(gcf,bti{i});
end
Pix.Bioturbation_Index=Bioturbation_Index;

% Other data
Pix.Source=get(f.ed(5),'string');
Pix.Age_Dates=get(f.ed(6),'string');
Pix.Well_Tops=get(f.ed(7),'string');
Pix.Channel_Dimensions=get(f.ed(8),'string'); 
%--------------------------------------------------------------------------
%-----------------------Convert to Group Format---------------------------- 
%--------------------------------------------------------------------------

%preallocate
zb=[];
gsb=[];

%-----------------------Vertical Scale: Depth------------------------------

sclzp=sortrows(Pix.pvs,2); sclzp=sclzp(:,2); %sort and grab ypixel
scl=fliplr(Pix.uvs);

zp2=sortrows(Pix.bed,2); zp=zp2(:,2); %sort and grab ypixel

zp(zp<sclzp(1))=sclzp(1); %snap to scale limits
zp(zp>sclzp(2))=sclzp(2);

z=interp1(sclzp,scl,zp); %top of beds (metric units) 

if ~isempty(Pix.bedprofile)
    zp3=sortrows(Pix.bedprofile,2); zbp=zp3(:,2);
    zb=interp1(sclzp,scl,zbp); %bed profiles
end

%-----------------------Horizontal Scale: GS------------------------------- 

gscodes{1}=gs1(2:end);
gscodes{2}=(1:length(gscodes{1})); %grain size codes 

if length(Pix.pgs)==2;

    ind1=ismember(gscodes{1},Pix.ugs{1}); ind2=ismember(gscodes{1},Pix.ugs{2});

    gsc(1)=gscodes{2}(ind1); gsc(2)=gscodes{2}(ind2);

    sclgp=sortrows(Pix.pgs,1); sclgp=sclgp(:,1); %sort and grab xpixel

    gsp=zp2(:,1); %Pix.bed(:,1); %xpixel
    gsp(gsp<sclgp(1))=sclgp(1); %snap to scale limits
    gsp(gsp>sclgp(2))=sclgp(2);
    gs=interp1(sclgp,gsc,gsp); %grain size code (not integer) not phi/psi

    if ~isempty(Pix.bedprofile)
        gsbp=zp3(:,1);
        gsbp(gsbp<sclgp(1))=sclgp(1); %snap to scale limits
        gsbp(gsbp>sclgp(2))=sclgp(2);
        gsb=interp1(sclgp,gsc,gsbp); %grain size for bed profiles (not integer) not phi/psi
    end

elseif length(Pix.pgs)>2;
    
    
    ind1=ismember(gscodes{1},Pix.ugs{1}); ind2=ismember(gscodes{1},Pix.ugs{2});
    ind3=ismember(gscodes{1},Pix.ugs{3});

    if length(Pix.pgs)==3; 
        
        gsc(1)=gscodes{2}(ind1); gsc(3)=gscodes{2}(ind2);
        gsc(2)=gscodes{2}(ind3);
        
        tmp=(gsc(1):gsc(2));
        gsc=[tmp gsc(3)];
    else
        
        gsc=[gscodes{2}(find(ind1==1):find(ind3==1)) gscodes{2}(ind2)];
        
    end
    
    
   sclgp=sortrows(Pix.pgs,1); sclgp=sclgp(:,1); %sort and grab xpixel
        
        
    gsp=zp2(:,1); %Pix.bed(:,1); %xpixel
    gsp(gsp<sclgp(1))=sclgp(1); %snap to scale limits
    gsp(gsp>sclgp(end))=sclgp(end);
    gs=interp1(sclgp,gsc,gsp); %grain size code (not integer)
        
        
        
    if ~isempty(Pix.bedprofile)
        gsbp=zp3(:,1);
        gsbp(gsbp<sclgp(1))=sclgp(1); %snap to scale limits
        gsbp(gsbp>sclgp(end))=sclgp(end);
        gsb=interp1(sclgp,gsc,gsbp); %grain size for bed profiles
    end
       
    
    
end

% space to convert bed-top and profile grain size to physical units (e.g.,
% mm or psi)

gs_class={'top clay','top silt','vfs','fs','ms','cs','vcs','gr','pb'};


%grains size ranges in mm
gsr_cly=[0.001 0.004]; gsr_slt=[0.004 0.0625];
gsr_snd=[0.0625 2]; gsr_gr=[2 4]; gsr_pb=[4 64];

psi_cly=log2(gsr_cly); psi_slt=log2(gsr_slt);
psi_snd=log2(gsr_snd); psi_gr=log2(gsr_gr); 
psi_pb=log2(gsr_pb);

%bin existing grain size (1-9) ind clay, silt, sand, gravel, and pb indices
indcly=find(gs>=0 & gs<1); % 1 is the top of clay
indslt=find(gs>=1 & gs<2); % 2 is the top of silt
indsnd=find(gs>=2 & gs<7);
indgr=find(gs>=7 & gs<8); % includes granule only (4 mm)
indpb=find(gs>=8 & gs<9); % pebble, inlcues 4 phu/psi units

%transpose bed tops to psi
gs_psi=zeros(numel(gs,1));
gs_psi(indcly)=interp1([0 1],psi_cly,gs(indcly)); % only evaluate from 0 to 1
gs_psi(indslt)=interp1([1 2],psi_slt,gs(indslt)); % only evaluate from 1 to 2
gs_psi(indsnd)=interp1([2 7],psi_snd,gs(indsnd)); % only evaluate from 2 to 7
gs_psi(indgr)=interp1([7 8],psi_gr,gs(indgr)); % only evaluate from 7 to 8
gs_psi(indpb)=interp1([8 9],psi_pb,gs(indpb)); % you get the idea
gs_psi=gs_psi';
gs_mm= 2.^gs_psi;

% STILL NEED TO CONVERT BED PROFILES
%transpose bed profiles to psi
clear indcly indslt indsnd ingr
indcly=find(gsb>=0 & gsb<1);
indslt=find(gsb>=1 & gsb<2);
indsnd=find(gsb>=2 & gsb<7);
indgr=find(gsb>=7 & gsb<8); % includes granule only (4 mm)
indpb=find(gsb>=8 & gsb<9); % pebble, inlcues 4 phu/psi units

if ~isempty(gsb)
    gsbp_psi=zeros(numel(gsb,1));
    gsbp_psi(indcly)=interp1([0 1],psi_cly,gsb(indcly)); % same as gs above - only evaluate from 0 to 1
    gsbp_psi(indslt)=interp1([1 2],psi_slt,gsb(indslt)); % etc
    gsbp_psi(indsnd)=interp1([2 7],psi_snd,gsb(indsnd));
    gsbp_psi(indgr)=interp1([7 8],psi_gr,gsb(indgr));
    gsbp_psi(indpb)=interp1([8 9],psi_pb,gsb(indpb)); 
    gsbp_psi=gsbp_psi';
    bed_profiles_mm=2.^gsbp_psi;
else
    bed_profiles_mm=[];
end


%--------------------------Derived Data------------------------------------

%Thickness 
if Pix.uvs(1)>Pix.uvs(2)
    
    logtype='core';
    
    th=diff(z);
    
    %Remove the last point
    z=z(1:end-1); gs=gs(1:end-1); gs_mm=gs_mm(1:end-1);

    %Midpoint
    zcpt=z-th/2;

else
    
    logtype='strat';
    
    th=abs(diff(z));
    
    %Remove the last point
    z=z(1:end-1); gs=gs(1:end-1); gs_mm=gs_mm(1:end-1);
    
    %Midpoint
    zcpt=z+th/2;
    
end


%---------------Determine if Geogrpahic or UTM Coordinates-----------------

islatgeo=(abs(Pix.geo(1))>0 & abs(Pix.geo(1))<90);
islonggeo=(abs(Pix.geo(2))>0 & abs(Pix.geo(2))<180);

if (islatgeo & islonggeo)==1
    geo=Pix.geo;      
else    
    geo=[];   
end

if ~isnan(Pix.utm(1)) && ~isnan(Pix.utm(2))
    utm=Pix.utm;
else
    utm=[];
end


%--------------------------Group Format------------------------------------ 

%Explicit
spc=find(Pix.header1{1}==':');
nxt=find(Pix.header1{1}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.name=Pix.header1{1}(spc+nxt:end); %Core ID
else
    C.name='Unknown';
end

spc=find(Pix.header1{2}==':');
nxt=find(Pix.header1{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.eod=Pix.header1{2}(spc+nxt:end); %Core ID
else
    C.eod=[];
end


spc=find(Pix.header1{3}==':');
nxt=find(Pix.header1{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.mod_anc=Pix.header1{3}(spc+nxt:end);
else
    C.mod_anc=[];
end

spc=find(Pix.header1{4}==':');
nxt=find(Pix.header1{4}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.type=Pix.header1{4}(spc+nxt:end);
else
    C.type=[];
end

spc=find(Pix.header1{5}==':');
nxt=find(Pix.header1{5}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.formation=Pix.header1{5}(spc+nxt:end);
else
    C.formation=[];
end

spc=find(Pix.header1{6}==':');
nxt=find(Pix.header1{6}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    C.units=Pix.header1{6}(spc+nxt:end);
else
    C.units=[];
end

C.geo=geo;
C.utm=utm;
C.geogcs=geogcs;
C.proj=proj;
C.tops=z; %Bed tops 
C.gs=gs; %Grain Size 
C.gs_mm=gs_mm;
C.gs_log=[];
C.bed_midpoints=zcpt; %Bed midpoints 
C.bed_midpoints_mm=[];
C.bed_profiles=[zb gsb]; %Bed profiles (including grain size info)

if ~isempty(bed_profiles_mm)
    C.bed_profiles_mm=[zb bed_profiles_mm];
else 
    C.bed_profiles_mm=[];
end
C.n_beds=length(z); %Number of Beds per Section
C.th=th; %Bed thicknesses 
C.gslabels=gscodes{1}; %Grain Size Categories 
C.n_facies=[]; %length(unique(gs)); %Number of Facies 
C.facies=[]; %Facies 
C.facies_log=[]; %Unused 

%no recovery
for i=1:length(No_Recovery)
    tmp=No_Recovery{i};   
    if ~isempty(tmp)
        tmp=sortrows(tmp,2); tmp=tmp(:,2);
        tmp(tmp<sclzp(1))=sclzp(1); %snap to scale limits
        tmp(tmp>sclzp(2))=sclzp(2);
        wsed=interp1(sclzp,scl,tmp); %top of beds (metric units) 
    else
        wsed=[];
    end
    C.No_Recovery{i}=wsed;
end    
    
clear wsed tmp

%List Generated - Dynamic Field Names......................................  
%General Lithotypes (Shell)
for i=2:length(GenLith_sed)
    tmp=getappdata(gcf,GenLith_sed{i});    
    if ~isempty(tmp)
        tmp=sortrows(tmp,2); tmp=tmp(:,2);
        tmp(tmp<sclzp(1))=sclzp(1); %snap to scale limits
        tmp(tmp>sclzp(2))=sclzp(2);
        wsed=interp1(sclzp,scl,tmp); %top of beds (metric units) 
    else
        wsed=[];
    end    
    General_Lithotypes.(GenLith_sed{i})=wsed;
end
clear wsed tmp

%Badley Ashton
for i=2:length(BA_sed)
    tmp=getappdata(gcf,BA_sed{i});    
    if ~isempty(tmp)
        tmp=sortrows(tmp,2); tmp=tmp(:,2);
        tmp(tmp<sclzp(1))=sclzp(1); %snap to scale limits
        tmp(tmp>sclzp(2))=sclzp(2);
        wsed=interp1(sclzp,scl,tmp); %top of beds (metric units) 
    else
        wsed=[];
    end    
    Badley_Ashton.(BA_sed{i})=wsed;
end
clear wsed tmp

%Robertson
for i=2:length(Robertson_sed)
    tmp=getappdata(gcf,Robertson_sed{i});    
    if ~isempty(tmp)
        tmp=sortrows(tmp,2); tmp=tmp(:,2);
        tmp(tmp<sclzp(1))=sclzp(1); %snap to scale limits
        tmp(tmp>sclzp(2))=sclzp(2);
        wsed=interp1(sclzp,scl,tmp); %top of beds (metric units) 
    else
        wsed=[];
    end    
    Robertson.(Robertson_sed{i})=wsed;
end
clear wsed tmp

%Trace Fossils
for i=2:length(tf)
    tmp2=getappdata(gcf,tf{i});    
    if ~isempty(tmp2)
        tmp2=sortrows(tmp2,2); tmp2=tmp2(:,2);
        tmp2(tmp2<sclzp(1))=sclzp(1); %snap to scale limits
        tmp2(tmp2>sclzp(2))=sclzp(2);
        wichno=interp1(sclzp,scl,tmp2);
    else
        wichno=[];
    end    
    Trace_Fossils.(tf{i})=wichno;
end
clear wichno tmp2

%Organics
for i=2:length(org)
    tmp2=getappdata(gcf,org{i});    
    if ~isempty(tmp2)
        tmp2=sortrows(tmp2,2); tmp2=tmp2(:,2);
        tmp2(tmp2<sclzp(1))=sclzp(1); %snap to scale limits
        tmp2(tmp2>sclzp(2))=sclzp(2);
        wichno=interp1(sclzp,scl,tmp2);
    else
        wichno=[];
    end
    
    Organics.(org{i})=wichno;
end
clear wichno tmp2

%Surfaces_and_Clasts
for i=2:length(srfclst)
    tmp2=getappdata(gcf,srfclst{i});    
    if ~isempty(tmp2)
        tmp2=sortrows(tmp2,2); tmp2=tmp2(:,2);
        tmp2(tmp2<sclzp(1))=sclzp(1); %snap to scale limits
        tmp2(tmp2>sclzp(2))=sclzp(2);
        wichno=interp1(sclzp,scl,tmp2);
    else
        wichno=[];
    end
    
    Surfaces_and_clasts.(srfclst{i})=wichno;
end
clear wichno tmp2

%Bioturbation_Index
for i=2:length(bti)
    tmp2=getappdata(gcf,bti{i});    
    if ~isempty(tmp2)
        tmp2=sortrows(tmp2,2); tmp2=tmp2(:,2);
        tmp2(tmp2<sclzp(1))=sclzp(1); %snap to scale limits
        tmp2(tmp2>sclzp(2))=sclzp(2);
        wichno=interp1(sclzp,scl,tmp2);
    else
        wichno=[];
    end
    
    Bioturbation_Index.(bti{i})=wichno;
end
clear wichno tmp2

%additional data -Source....................................................
Source=[];

spc=find(Pix.Source{1}==':');
nxt=find(Pix.Source{1}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Source.author=Pix.Source{1}(spc+nxt:end);
else
    Source.author=[];
end

spc=find(Pix.Source{2}==':');
nxt=find(Pix.Source{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Source.citation=Pix.Source{2}(spc+nxt:end);
else
    Source.citation=[];
end

spc=find(Pix.Source{3}==':');
nxt=find(Pix.Source{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
   Source.depo_setting=Pix.Source{3}(spc+nxt:end);
else
    Source.dep_setting=[];
end

spc=find(Pix.Source{4}==':');
nxt=find(Pix.Source{4}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Source.comments=Pix.Source{4}(spc+nxt:end);
else
    Source.comments=[];
end

% additional data - age dates..............................................
Age_Dates=[];

spc=find(Pix.Age_Dates{1}==':');
nxt=find(Pix.Age_Dates{5}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
   Age_Dates.dates=str2num(Pix.Age_Dates{1}(spc+nxt:end));
else
    Notes.dates=[];
end

spc=find(Pix.Age_Dates{2}==':');
nxt=find(Pix.Age_Dates{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    dates_idstr=Pix.Age_Dates{2}(spc+nxt:end);
    Age_Dates.dates_id=strsplit(dates_idstr);
else
   Age_Dates.dates_id=[];
end

spc=find(Pix.Age_Dates{3}==':');
nxt=find(Pix.Age_Dates{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)    
    Age_Dates.depth=str2num(Pix.Age_Dates{3}(spc+nxt:end));
else
    Age_Dates.depth=[];
end

spc=find(Pix.Age_Dates{4}==':');
nxt=find(Pix.Age_Dates{4}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Age_Dates.units=Pix.Age_Dates{4}(spc+nxt:end);
else
    Age_Dates.units=[];
end

spc=find(Pix.Age_Dates{5}==':');
nxt=find(Pix.Age_Dates{5}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Age_Dates.time_units=Pix.Age_Dates{5}(spc+nxt:end);
else
    Age_Dates.time_units=[];
end


%additional data - well tops...............................................
Well_Tops=[];

spc=find(Pix.Well_Tops{1}==':');
nxt=find(Pix.Well_Tops{1}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    name=Pix.Well_Tops{1}(spc+nxt:end);
    Well_Tops.name=strsplit(name);
else
    Well_Tops.name=[];
end

spc=find(Pix.Well_Tops{2}==':');
nxt=find(Pix.Well_Tops{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Well_Tops.depth=str2num(Pix.Well_Tops{2}(spc+nxt:end));
else
    Well_Tops.depth=[];
end

spc=find(Pix.Well_Tops{3}==':');
nxt=find(Pix.Well_Tops{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Well_Tops.units=Pix.Well_Tops{3}(spc+nxt:end);
else
    Well_Tops.units=[];
end

%additional data - Measurement.............................................
Channel_Dimensions=[];

spc=find(Pix.Channel_Dimensions{1}==':');
nxt=find(Pix.Channel_Dimensions{1}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Channel_Dimensions.channel_depth=str2num(Pix.Channel_Dimensions{1}(spc+nxt:end));
else
   Channel_Dimensions.channel_depth=[];
end

spc=find(Pix.Channel_Dimensions{2}==':');
nxt=find(Pix.Channel_Dimensions{2}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Channel_Dimensions.channel_width=str2num(Pix.Channel_Dimensions{2}(spc+nxt:end));
else
    Channel_Dimensions.channel_width=[];
end

spc=find(Pix.Channel_Dimensions{3}==':');
nxt=find(Pix.Channel_Dimensions{3}(spc+1:end)~=' ',1,'first');
if ~isempty(nxt)
    Channel_Dimensions.units=Pix.Channel_Dimensions{3}(spc+nxt:end);
else
    Channel_Dimensions.units=[];
end



%additional data - Sediment Sample (inactive for now)
Sed_Sample.grsampledepth=[];
Sed_Sample.grsampleunits=[];
Sed_Sample.grsampledist=[];
Sed_Sample.elevation=[];
Sed_Sample.thalwegz=[];
Sed_Sample.units=[];


C.General_Lithotypes=General_Lithotypes;
C.Badley_Ashton=Badley_Ashton;
C.Robertson=Robertson;
C.Well_Tops=Well_Tops;
C.Age_Dates=Age_Dates;
C.Organics=Organics;
C.Trace_Fossils=Trace_Fossils;
C.Bioturbation_Index=Bioturbation_Index;
C.Surfaces_and_Clasts=Surfaces_and_Clasts;
C.Sed_Sample=Sed_Sample;
C.Channel_Dimensions=Channel_Dimensions;
C.Source=Source;


%---------------------------Post Processing--------------------------------

%-----------------------Set No Recovery to NaN-----------------------------

loc=cellfun(@(x) ~isempty(x),C.No_Recovery,'UniformOutput',false);  
loc=cell2mat(loc);
pos=find(loc==1);
if ~isempty(pos)
    blnk=C.No_Recovery{pos};
    z=C.tops;  
    for i=1:numel(blnk)        
        tmp=z-blnk(i);   
        %Case Core
        if Pix.uvs(1)>Pix.uvs(2)     
            tmpid=find(tmp<0==1); tmpid=tmpid(end);
            C.gs(tmpid)=NaN;      
            C.gs_mm(tmpid)=NaN;
        %Case Strat
        else
            tmpid=find(tmp>0==1); tmpid=tmpid(end);
            C.gs(tmpid)=NaN;   
            C.gs_mm(tmpid)=NaN;
        end            
    end
end 
  
    

%%

