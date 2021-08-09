function G=StratCoreProcessor_OLD_KleineReitFontein
%Command Line Help: Digitize Core Images 
%Instructions:
%(1) Load image 
%(2) Load Points if desired
%(3) Set the vertical core scale: Click two points to define the vertical
% bounds and provide the real world values.
%(4) Set the grain size: Click two points to define the grain size bounds and
% select the corresponding grain size class in the dropdown menu. 
%(5) Digitize the beds: Click the upper right (left) corner of the beds. 
%NOTE: It is also required to digitize the base of the last bed !!. 
%(6) Digitize the bed profiles (optional) 
%(6) Digitize sedimentary structures (optional)
%(7) Digitize ichnofacies (optional)
%(8) Name the core  
%(9) Add the Geographic Coordinates
%
%Note: The above items do not need to digitized in sequential order. Also, the
%points in each step can be digitized any order (from the botton up, top
%down, etc)
%
%Issue 1: Only one radio button should be active at a time.
%Fix 1: Set radio buttons under a uibuttongroup parent. 
%
%Improvements (version 10):
%Can handle Strat Sections as well as core.
%Can handle Non-linear Grain Size Axis (Need to test further).
%Load existing point data. 
%Added coordinate data field.
%Ability to blank bed if scree covered or no recovery.
%
%Pending Improvements: 
%Add checks to ensure that necessary fields are complete on export  
%(NCH 2012)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System Configuration & Laptop Screen Adjustment 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=filesep;

if f=='/'
    madj=200; %Screen Adjustment for 15" Macbook (will normalize....
else
    madj=0;
end

%Figure Dimensions
bh=1000;
bw=1300;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dropdown Vectors 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Grain Size - NonLinear (Clay-Silt)
gs1={'lower g.s.','clay','silt','vfs','fs','ms','cs','vcs','gr','pb','cbl','bldr'};
gs1_2={'nonlinear','clay','silt','vfs','fs','ms','cs','vcs','gr','pb','cbl','bldr'};
gs2={'upper g.s.','clay','silt','vfs','fs','ms','cs','vcs','gr','pb','cbl','bldr'};

%MSand

sed={'Sed. Structures Clear','Cross-stratification','Planar-stratification',...
    'Discontinuous','Contorted','Massive','Graded bedding','Muddy Sand','Planar XStrat',...
    'Trough XStrat','Toeset XStrat','Ripple Lam','Current ripple X-Lam','Wave ripple X-Lam',...
    'Lenticular','Wavy','Discontinuous Wavy','Flaser','Climbing ripples','Double mud drapes',...
    'Reactivation surface','Bi-directional','Herringbone','Couplet','HCS/SCS','Combined-flow ripple',...
    'Lag','Mudclasts','Mud Drapes','Erosional Truncation','Scour','Granules','Gutter Cast','Water Escape',...
    'Shells','Peat','Plant-Wood','Rootlet','Organics','Calc Conc','Laterites',...
    'Radiocarbon','No Recovery','Stratigraphic Picks'};


sstore={'SedS','XStrat','PStrat','Discont','Contort','Mass','GBed','MSand','XStratP','XStratT','XStratB','RLam',...
    'CRLam','WRLam','Lent','Wav','DisWav','Flas','CLRLam','DMD','RS','Bidir',...
    'Herr','Coup','HCS','CFRLam','Lag','MClast','Drape','EroT','Scour',...
    'Gran','Gutter','WE','Shell','Peat','Plant','Root','Organics','CConc','Lat',...
    'radio','Norecov','StratTops'};


ichno={'Ichnology_Clear','Bioturbation','Burrow','Arenicolites','Asterosoma','Chondrites','Cylindrichnus',...
        'Diplocraterion','Fugichnia','Equilibrichnia',...
        'Ophiomorpha','Palaeophycus','Phycosiphon',...
        'Planolites','Rhizocorallium','Rosselia','Skolithos',...
        'Teichichnus','Thalassinoides','Glossifungites','Psilonichnus'};
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialize GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------Main---------------------------------------

G.fh=figure('units','normalized',...
              'position',[0 0.0375 1 0.9163]);

set(G.fh,'numberTitle','off','name','Core Digitizer')
set(G.fh,'menubar','none')

%-------------------------------Radio-------------------------------------

% Option for Exclusively Manage Radio Buttons (not sure if I want to use) 
% G.rbg=uibuttongroup('visible','off',...
%         'position',[780,380,205,540]);
        
G.rb(1)=uicontrol('style','radiobutton',...
        'position',[bw,bh-madj,175,40],...
        'string','Set Vertical Scale',...
        'tag','vs',...
        'callback',@vs_callback);
    
G.rb(2)=uicontrol('style','radiobutton',...
        'position',[bw,bh*0.9-madj,175,40],...
        'string','Set Grain Size Axis',...
        'tag','gsaxis',...
        'callback',@gs_callback);
    
G.rb(3)=uicontrol('style','radiobutton',...
        'position',[bw,bh*0.8-madj,175,40],...
        'string','Digitize Beds',...
        'tag','bed',...
        'callback',@bed_callback);
    
G.rb(4)=uicontrol('style','radiobutton',...
        'position',[bw,bh*0.7-madj,175,40],...
        'string','Digitize Bed Profiles',...
        'tag','bedprofile',...
        'callback',@bed_profile_callback);    
   
%--------------------------------Edit--------------------------------------
       
G.ed(1)=uicontrol('style','edit',...
        'position',[bw,bh*0.97-madj,75,25],...
        'string','top core',....
        'tag','toc');
    
G.ed(2)=uicontrol('style','edit',...
        'position',[bw*1.07,bh*0.97-madj,75,25],...
        'string','base core',...
        'tag','boc');
    
G.ed(3)=uicontrol('style','edit',...
         'position',[bw,bh*0.35-madj,100,25],...
         'string','Core ID',...
         'tag','fname');    
     
G.ed(4)=uicontrol('style','edit',...
         'position',[bw,bh*0.3-madj,80,25],...
         'string','long/xutm',...
         'tag','fname'); 
     
G.ed(5)=uicontrol('style','edit',...
         'position',[bw*1.07,bh*0.3-madj,80,25],...
         'string','lat/yutm ',...
         'tag','fname');      
 
%--------------------------------Pop---------------------------------------

G.pp(1)=uicontrol('style','pop',...
        'position',[bw,bh*0.87-madj,75,25],...
        'string',gs1,....
        'tag','gs1');

G.pp(2)=uicontrol('style','pop',...
        'position',[bw*1.07,bh*0.87-madj,75,25],...
        'string',gs2,....
        'tag','gs2');

G.pp(3)=uicontrol('style','pop',...
        'position',[bw,bh*0.55-madj,105,25],...
        'string',sed,....
        'tag','sedstruct',...
        'callback',{@sed_drop_callback,sstore});

G.pp(4)=uicontrol('style','pop',...
        'position',[bw,bh*0.45-madj,85,25],...
        'string',ichno,....
        'tag','tichno',...
        'callback',{@ich_drop_callback,ichno});

G.pp(5)=uicontrol('style','pop',...
        'position',[bw*1.03,bh*0.84-madj,75,25],...
        'string',gs1_2,....
        'tag','gs1_2');
    
%----------------------------Buttons---------------------------------------      
     
G.pb(1)=uicontrol('style','pushbutton',...
        'position',[bw,bh*0.2-madj,120,40],...
        'string','Export to Workspace');

G.pb(2)=uicontrol('style','pushbutton',...
          'position',[bw,bh*0.1-madj,120,40],...
          'string','Export to Matfile');    

G.pb(3)=uicontrol('style','pushbutton',...
        'position',[bw,bh*0.6-madj,175,40],...
        'string','Digitize Sed Structures',...
        'tag','sedstr');  
    
G.pb(4)=uicontrol('style','pushbutton',...
        'position',[bw,bh*0.5-madj,175,40],...
        'string','Digitize Ichnology',...
        'tag','ichno');
    
%-------------------------------Menu---------------------------------------

G.mh=uimenu(G.fh,'Label','Load');
uimenu(G.mh,'Label','Image','callback',@callback_loadImage)
uimenu(G.mh,'Label','Points','callback',{@callback_loadPoints,sstore,ichno,G,gs1,gs1_2})

%----------------------Initialize App Data---------------------------------
   
setappdata(gcf,'axlim',[])
setappdata(gcf,'H',[])
setappdata(gcf,'pinPoints',0)
setappdata(gcf,'pos',1);
setappdata(gcf,'pos2',1);

markerSpecs = struct('statColor',[0 0 1],'dragColor',[1 0 0],'size',6,'style','o');
setappdata(gcf,'markerSpecs',markerSpecs)

setappdata(gcf,'vs',[])
setappdata(gcf,'gs',[]);
setappdata(gcf,'bed',[]);
setappdata(gcf,'bedprofile',[]);

%Sedimentary Structures 
for i=1:length(sed)
    setappdata(gcf,sstore{i},[])
end

%Ichnology
for i=1:length(ichno)
    setappdata(gcf,ichno{i},[])
end

%----------------------------SetCallbacks----------------------------------

 set(G.pb(3),'callback',{@seds_callback,G,sstore});
 set(G.pb(4),'callback',{@ich_callback,G,ichno});
 set(G.pb(1),'callback',{@base_callback,G,gs1,gs2,sstore,ichno,gs1_2});
 set(G.pb(2),'callback',{@write_file_callback,G,gs1,gs2,sstore,ichno,gs1_2});

%---------------------------Core Log Image---------------------------------

%G.ax(1)= axes('unit','pix','position',[80 70 600 875-madj]);
G.ax(1)= axes('unit','pix','position',[80 70 bw*0.9 bh-madj]);

%----------------------------Toggle Icons----------------------------------

G.ht=uitoolbar;
[x,map] = imread([matlabroot,strcat(f,'toolbox',f,'matlab',f,'icons',f,'pin_icon.gif')]);
cdata = ind2rgb(x,map);
cdata(cdata==1)=NaN;

% G.tg(1)=uitoggletool(G.ht,'cdata',cdata,...
%     'TooltipString','Pin Points',...
%     'onCallback', 'setappdata(gcf,''pinPoints'',1)',...
%     'offCallback','setappdata(gcf,''pinPoints'',0)');

fname = [matlabroot,strcat(f,'toolbox',f,'matlab',f,'icons',f,'pan.mat')];
load(fname)     
     
 G.tg(1)=uitoggletool(G.ht,'cdata',cdata,...
        'TooltipString','Pan',...
        'clickedCallback','pan');   

fname = [matlabroot,strcat(f,'toolbox',f,'matlab',f,'icons',f,'zoomplus.mat')];
load(fname) 

  G.tg(2)=uitoggletool(G.ht,'cdata',cdata,...
          'TooltipString','Zoom',...
          'clickedCallback','zoom');


   

%-----------------------Display Core Log-----------------------------------

function initializeAxes(fname)
displayImage(fname)

function displayImage(fname)
X=imread(fname);
ih = imagesc(X);
set(ih,'buttonDownFcn',@createPoint)
axis equal %tight
hold on
axlim = [get(gca,'xlim') get(gca,'ylim')];
setappdata(gcf,'axlim',axlim)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Digitizing Functions  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createPoint(varargin)
xy = get(gca,'CurrentPoint');
xy = xy(1,1:2);
h = plotPoint(xy);
setappdata(gcf,'H',[getappdata(gcf,'H'); h]);
%Enable dragging until button is relased
set(gcf,'WindowButtonMotionFcn',{@dragPoint,h},'WindowButtonUpFcn',{@buttonUp,h})

function [H] = plotPoint(XY)
H = zeros(size(XY,1),1);
for k=1:size(XY,1)
    H(k) = plot(XY(k,1),XY(k,2),'.');
    %Menu options to delete points (with callbacks)
    cmenu = uicontextmenu;
    uimenu(cmenu, 'Label', 'Delete this point','Callback', {@deletePoint,H(k)});
    uimenu(cmenu, 'Label', 'Delete all points...','Callback', @deleteAllPoints,'separator','on');
    set(H(k),'UIContextMenu', cmenu)
end 
markerSpecs = getappdata(gcf,'markerSpecs');
set(H,'Color',markerSpecs.statColor,...
    'MarkerSize',markerSpecs.size,...
    'Marker',markerSpecs.style,...
    'ButtonDownFcn',@clickPoint);

function clickPoint(h,varargin)
if ~getappdata(gcf,'pinPoints')
    markerSpecs = getappdata(gcf,'markerSpecs');
    set(h,'color',markerSpecs.dragColor)
    set(gcf,'WindowButtonMotionFcn',{@dragPoint,h},'WindowButtonUpFcn',{@buttonUp,h})
end

function dragPoint(varargin)
h = varargin{3};
markerSpecs = getappdata(gcf,'markerSpecs');
set(h,'color',markerSpecs.dragColor)
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
set(h,'xdata',x,'ydata',y)

function buttonUp(varargin)
h=varargin{3};
markerSpecs = getappdata(gcf,'markerSpecs');
set(h,'color',markerSpecs.statColor)
set(gcf,'WindowButtonMotionFcn',[],'WindowButtonUpFcn',[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----------------------------Import Data-----------------------------------


function callback_loadImage(varargin)
[fname,pathName] = uigetfile('*.*');
if isequal(fname,0)
    return
end
initializeAxes([pathName,fname])


function callback_loadPoints (varargin)

sstore=varargin{3};
ichno=varargin{4};
G=varargin{5};
gs1=varargin{6};
gs1_2=varargin{7};


% Check if an image has been loaded
if ~isempty(findobj(gca,'type','text'))
    errordlg('Please load an image before loading points.','Error')
    return
end

% Get a points file
[fname,pathName] = uigetfile('*.mat','MAT files (*.mat)');
if isequal(fname,0)
    return
end

w = whos('-file',[pathName fname]);
ch=arrayfun(@(x)strfind(lower(x.name),'pix'),w,'UniformOutput',false);
pfile=w(cellfun(@(x)~isempty(x),ch)==1).name;

load([pathName,fname]);
pdat=eval(pfile);

%Delete Existing Data
delete(getappdata(gca,'H'));

%Set Point AppData
setappdata(gcf,'vs',pdat.pvs)
setappdata(gcf,'gs',pdat.pgs);
setappdata(gcf,'bed',pdat.bed);
setappdata(gcf,'bedprofile',pdat.bedprofile);

%Sedimentary Structures 
for i=2:length(sstore)

     if isfield(pdat,sstore{i})==1
         setappdata(gcf,sstore{i},pdat.(sstore{i}))
     end
    
end

%Ichnology
for i=2:length(ichno)
    
    if isfield(pdat,ichno{i})==1
        setappdata(gcf,ichno{i},pdat.(ichno{i}))
    end
    
end

%Set Dropdown & Edit Box AppData 

% Core ID
set(G.ed(3),'string',pdat.name);

% Vertical Scale 
set(G.ed(1),'string',pdat.uvs(1));
set(G.ed(2),'string',pdat.uvs(2));

% Grain Size 


if length(pdat.pgs)==2
    
    pind1=find(ismember(gs1,pdat.ugs{1})==1);
    pind2=find(ismember(gs1,pdat.ugs{2})==1);

    set(G.pp(1),'val',pind1);
    set(G.pp(2),'val',pind2);

else

    pind1=find(ismember(gs1,pdat.ugs{1})==1);
    pind2=find(ismember(gs1,pdat.ugs{2})==1);
    pind3=find(ismember(gs1_2,pdat.ugs{3})==1);
    
    set(G.pp(1),'val',pind1);
    set(G.pp(2),'val',pind2);
    set(G.pp(5),'val',pind3);
    

end

% Geographic Coordinates

if isfield(pdat,'geo')
        
    set(G.ed(4),'string',pdat.geo(1))
    set(G.ed(5),'string',pdat.geo(2))
    
else
    
    pdat.geo(1)=NaN; pdat.geo(2)=NaN;
    
    set(G.ed(4),'string',pdat.geo(1))
    set(G.ed(5),'string',pdat.geo(2))
        
end

%-----------------------Edit Selected Points-------------------------------

function deletePoint(varargin)
h = varargin{3};
H = getappdata(gcf,'H');
H(H==h)=[];
setappdata(gcf,'H',H)
delete(h)

function deleteAllPoints(varargin)
button = questdlg('OK to delete all points?','Warning!!','OK','Cancel','OK');
if isequal(button,'Cancel')
    return
end
delete(getappdata(gcf,'H'))
setappdata(gcf,'H',[])


%-----------------------Radio Button Callbacks-----------------------------

%(1) Vertical Axis 
function vs_callback(varargin)    

if get(gcbo,'Value')==1; %On Call 
    if ~isempty(getappdata(gcf,'vs')); 
        XY=getappdata(gcf,'vs');
        H = plotPoint(XY);   
        setappdata(gcf,'H',H);
    end
else %Off Call 
    [vs] = getXY;
    setappdata(gcf,'vs',vs)
    assignin('base','vs',vs);
    delete(getappdata(gcf,'H'))
    setappdata(gcf,'H',[])   
end 

%(2) Grain Size 
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

%(3) Bedding
function bed_callback(varargin)

if get(gcbo,'Value')==1; %On Call 
    if ~isempty(getappdata(gcf,'bed'));
        XY=getappdata(gcf,'bed');
        H = plotPoint(XY);
        setappdata(gcf,'H',H);
    end
else %Off Call 
    [bed] = getXY;
    setappdata(gcf,'bed',bed);
    assignin('base','bed',bed);
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

%(4) Bed profiles
function bed_profile_callback(varargin)

if get(gcbo,'Value')==1; %On Call 
    if ~isempty(getappdata(gcf,'bedprofile'));
        XY=getappdata(gcf,'bedprofile');
        H = plotPoint(XY);
        setappdata(gcf,'H',H);
    end
else %Off Call 
    [bedprofile] = getXY;
    setappdata(gcf,'bedprofile',bedprofile);
    assignin('base','bedprofile',bedprofile);
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

%(5) Sedimentary Structures
function seds_callback(varargin)

G=varargin{3};
sstore=varargin{4};
pos=getappdata(gcf,'pos');

if pos~=1;
    [tmp] = getXY;   
    setappdata(gcf,sstore{pos},tmp);    
    set(G.pp(3),'Value',1)
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
    setappdata(gcf,'pos',1)
else
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

function sed_drop_callback(varargin)

pos=get(gcbo,'Value');
sstore=varargin{3};

if pos==1; %temporary fix 
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

XY=getappdata(gcf,sstore{pos});
h = plotPoint(XY);
setappdata(gcf,'H',[getappdata(gcf,'H'); h]); 
setappdata(gcf,'pos',pos)   
        
%(5) Ichnology
function ich_callback(varargin)

G=varargin{3};
ichno=varargin{4};
pos2=getappdata(gcf,'pos2');

if pos2~=1;
    [tmp] = getXY;
    setappdata(gcf,ichno{pos2},tmp);
    set(G.pp(4),'Value',1);
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
    setappdata(gcf,'pos2',1);
else
    delete(getappdata(gcf,'H'));
    setappdata(gcf,'H',[]);
end

function ich_drop_callback(varargin)

pos2=get(gcbo,'Value');
ichno=varargin{3};

if pos2==1; %temporary fix 
    delete(getappdata(gcf,'H'))
    setappdata(gcf,'H',[])
end

XY=getappdata(gcf,ichno{pos2});
h = plotPoint(XY);
setappdata(gcf,'H',[getappdata(gcf,'H'); h]);
setappdata(gcf,'pos2',pos2);


%----------------------------Export----------------------------------------


function base_callback(varargin)

G=varargin{3};
gs1=varargin{4};
gs2=varargin{5};
sstore=varargin{6};
ichno=varargin{7};
gs1_2=varargin{8};

[Pix,C]=Cformat(G,gs1,gs2,sstore,ichno,gs1_2);

%Assignin to Workspace
assignin('base','Pix',Pix);
assignin('base','C',C);


function write_file_callback(varargin)

G=varargin{3};
gs1=varargin{4};
gs2=varargin{5};
sstore=varargin{6};
ichno=varargin{7};
gs1_2=varargin{8};

[Pix,C]=Cformat(G,gs1,gs2,sstore,ichno,gs1_2);


[outfile,outdir]=uiputfile();


if strcmp(C.name,'Core ID')==1
    
    C.name='Unknown';
    
end
    
Coredata=C.name;
Pixdata=strcat(C.name,'Pix');

eval([Coredata,'=C']);
eval([Pixdata,'=Pix']);

eval(['save ', strcat(outdir,outfile) ,' ', Coredata,' ', Pixdata]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------ Call XY -----------------------------------

function [XY] = getXY
H = getappdata(gcf,'H');
XY = [get(H,'xdata') get(H,'ydata')];
if length(H)>1
    XY = cell2mat(XY);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format Core Data to Common Standard 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Pix,C]=Cformat(G,gs1,gs2,sstore,ichno,gs1_2) 

%-------------Map Pixel/Ref Data into Structure (xy format)----------------
% All the data that will need to be reloaded at a later date

Pix.name=get(G.ed(3),'string');

Pix.pvs=getappdata(gcf,'vs');
Pix.uvs(1)=str2double(get(G.ed(1),'string')); 
Pix.uvs(2)=str2double(get(G.ed(2),'string'));

Pix.pgs=getappdata(gcf,'gs');
lgs=get(G.pp(1),'val'); ugs=get(G.pp(2),'val');
ngs=get(G.pp(5),'val');

Pix.ugs{1}=gs1{lgs};
Pix.ugs{2}=gs2{ugs}; 
Pix.ugs{3}=gs1_2{ngs};


Pix.bed=getappdata(gcf,'bed');
Pix.bedprofile=getappdata(gcf,'bedprofile');

Pix.geo(1)=str2double(get(G.ed(4),'string')); 
Pix.geo(2)=str2double(get(G.ed(5),'string'));

%------------------------Dynamic Field Names------------------------------- 
%For Sedimentary Structures and Ichnofacies 

for i=2:length(sstore)
    Pix.(sstore{i})=getappdata(gcf,sstore{i});
end

for i=2:length(ichno)
    Pix.(ichno{i})=getappdata(gcf,ichno{i});
end

%--------------------------------------------------------------------------
%-----------------------Convert to Group Format---------------------------- 
%--------------------------------------------------------------------------

%preallocate
zb=[];
gsb=[];

%-----------------------Vertical Scale: Depth------------------------------

sclzp=sortrows(Pix.pvs,2); sclzp=sclzp(:,2); %sort and grab ypixel
scl=Pix.uvs;

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
    gs=interp1(sclgp,gsc,gsp); %grain size code (not integer)

    if ~isempty(Pix.bedprofile)
        gsbp=zp3(:,1);
        gsbp(gsbp<sclgp(1))=sclgp(1); %snap to scale limits
        gsbp(gsbp>sclgp(2))=sclgp(2);
        gsb=interp1(sclgp,gsc,gsbp); %grain size for bed profiles
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

%--------------------------Derived Data------------------------------------

%Thickness 
if Pix.uvs(1)<Pix.uvs(2)
    
    logtype='core';
    
    th=diff(z);
    
    %Remove the last point
    z=z(1:end-1); gs=gs(1:end-1);

    %Midpoint
    zcpt=z+th/2;

else
    
    logtype='strat';
    
    th=abs(diff(z));
    
    %Remove the last point
    z=z(1:end-1); gs=gs(1:end-1);
    
    %Midpoint
    zcpt=z-th/2;
    
end


%---------------Determine if Geogrpahic or UTM Coordinates-----------------

islatgeo=(abs(Pix.geo(1))>0 & abs(Pix.geo(1))<90);
islonggeo=(abs(Pix.geo(1))>0 & abs(Pix.geo(1))<180);

if (islatgeo & islonggeo)==1;

    geo=Pix.geo;
    utm=[];
    
else
    
    geo=[];
    utm=Pix.geo;
    
end


%--------------------------Group Format------------------------------------ 

%Explicit
C.name=Pix.name; %Core ID
C.units='m'; %Metric Units 
C.tops=z; %Bed tops 
C.gs=gs; %Grain Size 
C.gslabels=gscodes{1}; %Grain Size Categories 
C.n_beds=length(z); %Number of Beds per Section
C.n_facies=[]; %length(unique(gs)); %Number of Facies 
C.facies=[]; %Facies 
C.th=th; %Bed thicknesses 
C.bed_midpoints=zcpt; %Bed midpoints 
C.facies_log=[]; %Unused 
C.grain_size_log=[]; %Unused 
C.bed_profiles=[zb gsb]; %Bed profiles (including grain size info)
C.type=logtype;
C.geo=geo;
C.utm=utm;

%New Fields.... Manual Edit
C.StratTopsID=[];
C.notes=[];
C.intervaldata=[];

%List Generated - Dynamic Field Names  
for i=2:length(sstore)
    tmp=getappdata(gcf,sstore{i});
    
    if ~isempty(tmp)
    tmp=sortrows(tmp,2); tmp=tmp(:,2);
    tmp(tmp<sclzp(1))=sclzp(1); %snap to scale limits
    tmp(tmp>sclzp(2))=sclzp(2);
    wsed=interp1(sclzp,scl,tmp); %top of beds (metric units) 
    else
    wsed=[];
    end
    
    C.(sstore{i})=wsed;
end

for i=2:length(ichno)
    tmp2=getappdata(gcf,ichno{i});
    
    if ~isempty(tmp2)
    tmp2=sortrows(tmp2,2); tmp2=tmp2(:,2);
    tmp2(tmp2<sclzp(1))=sclzp(1); %snap to scale limits
    tmp2(tmp2>sclzp(2))=sclzp(2);
    wichno=interp1(sclzp,scl,tmp2);
    else
    wichno=[];
    end
    
    C.(ichno{i})=wichno;

end

%---------------------------Post Processing--------------------------------

%-----------------------Set No Recovery to NaN-----------------------------

  blnk=C.Norecov;
  z=C.tops;

for n=1:length(blnk)
  
    tmp=z-blnk(n); 
  
    %Case Core
    if Pix.uvs(1)<Pix.uvs(2) 
 
    
        tmpid=find(tmp<0==1); tmpid=tmpid(end);
        C.gs(tmpid)=NaN;
        
    %Case Strat
    else 
   
        tmpid=find(tmp>0==1); tmpid=tmpid(end);
        C.gs(tmpid)=NaN;
        
    end
        
end


