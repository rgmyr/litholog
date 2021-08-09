function [bed]=assign_bed_gs_convert_mm_public(C,varargin)
% Assign profile data or attributes to beds. 
%bed is a 2-column array.  The length of the array is the number of beds.
%each cell entry in column 1 is the elevation of the bed points (may be
%greater than 2 if a bed profile is present).  
%each cell entry in column 2 is the grain size in millimeters for each elevation. 

%Variables
tops=C.tops;
th=C.th;
if tops(1)<tops(end) % core
    base=tops+th;
else
    base=tops-th; % strat
end

%% Grain size
gs=C.gs_tops; % USES the arbitrary gs from the digitizer (1 top clay, 2 top silt, etc.)

% mm values
gsr_cly=[0.001 0.004]; 
gsr_slt=[0.004 0.0625];
gsr_snd=[0.0625 2]; 
gsr_gr=[2 4]; 
gsr_pb=[4 64];
gsr_cob=[64 256];
gsr_bldr=[256 10000]; % max of 10 meters for now - if I use "inf", interp1 doesnt work

% and psi values
psi_cly=log2(gsr_cly); 
psi_slt=log2(gsr_slt);
psi_snd=log2(gsr_snd); 
psi_gr=log2(gsr_gr); 
psi_pb=log2(gsr_pb);
psi_cob=log2(gsr_cob);
psi_bldr=log2(gsr_bldr);

% now, bin arbitrary grain size (1-9) ind clay, silt, sand, gravel, and pb indices
indcly=find(gs>=0 & gs<=1); % 1 is the top of clay
indslt=find(gs>1 & gs<=2); % 2 is the top of silt
indsnd=find(gs>2 & gs<=7);
indgr=find(gs>7 & gs<=8); % includes granule only (2-4 mm)
indpb=find(gs>8 & gs<=9); % pebble, includes 4 phi/psi units
indcob=find(gs>9 & gs<=10); % cobble
indbldr=find(gs>10); % boulder

%transpose bed tops to psi
gs_psi=zeros(numel(gs,1));
gs_psi(indcly)=interp1([0 1],psi_cly,gs(indcly)); % only evaluate from 0 to 1
gs_psi(indslt)=interp1([1 2],psi_slt,gs(indslt)); % only evaluate from 1 to 2
gs_psi(indsnd)=interp1([2 7],psi_snd,gs(indsnd)); % only evaluate from 2 to 7
gs_psi(indgr)=interp1([7 8],psi_gr,gs(indgr)); % only evaluate from 7 to 8
gs_psi(indpb)=interp1([8 9],psi_pb,gs(indpb)); % you get the idea
gs_psi(indcob)=interp1([9 10],psi_cob,gs(indcob)); 
gs_psi(indbldr)=interp1([10 12],psi_bldr,gs(indbldr)); % using 12 as a max for now
gs_psi=gs_psi';

gs_psi(gs_psi < -3.6 & gs_psi > -5) = -5; % for beds near the boundary, make aure they are muds

% covered intervals have NaN for gs, so need to get them back after interp1
gs_psi(isnan(gs)) = NaN;

gs_mm= 2.^gs_psi;

%%%%%%%%%%%%%
% and do the same for the bed profiles (using arbitrary grain size)
Y=C.bed_profiles(:,1); %elevation or depth
Y2=C.bed_profiles(:,2); %grain size also in mm

indcly=find(Y2>=0 & Y2<1);
indslt=find(Y2>=1 & Y2<2);
indsnd=find(Y2>=2 & Y2<7);
indgr=find(Y2>=7 & Y2<8); % includes granule only (4 mm)
indpb=find(Y2>=8 & Y2<9); % pebble, inlcues 4 phu/psi units
indcob=find(Y2>=9 & Y2<10); % cobble
indbldr=find(Y2>10); % boulder

if ~isempty(Y2) % some beds dont have bed profiles (e.g., most mudstones)
    gsbp_psi=zeros(numel(Y2,1));
    gsbp_psi(indcly)=interp1([0 1],psi_cly,Y2(indcly)); % same as gs above - only evaluate from 0 to 1
    gsbp_psi(indslt)=interp1([1 2],psi_slt,Y2(indslt)); % etc
    gsbp_psi(indsnd)=interp1([2 7],psi_snd,Y2(indsnd));
    gsbp_psi(indgr)=interp1([7 8],psi_gr,Y2(indgr));
    gsbp_psi(indpb)=interp1([8 9],psi_pb,Y2(indpb)); 
    gsbp_psi(indcob)=interp1([9 10],psi_cob,Y2(indcob)); 
    gsbp_psi(indbldr)=interp1([10 20],psi_bldr,Y2(indbldr)); 
    gsbp_psi=gsbp_psi';
    bed_profiles_mm=2.^gsbp_psi;
else
    bed_profiles_mm=[];
end

Y2_mm = bed_profiles_mm;

%Allocate
pro=cell(length(tops),2);
bed=cell(length(tops),2);

% Core vs Strat 
if tops(1)<tops(end)
    ind = ( bsxfun(@ge, Y, tops') & bsxfun(@lt, Y, base') );
else
    ind=( bsxfun(@lt, Y, tops') & bsxfun(@ge, Y, base') );
end

[~,c]=size(ind);

for i=1:c
    %(1) Assign Profiles
    pro{i,1}=Y(ind(:,i));
    pro{i,2}=Y2_mm(ind(:,i));
    
    %(2) Create Beds
    bed{i,1}=[tops(i);pro{i,1};base(i)];
    
    if ~isempty(pro{i,1})
        bed{i,2}=[gs_mm(i);pro{i,2};pro{i,2}(end)];
    else
        bed{i,2}=[gs_mm(i);gs_mm(i)];
    end   
end

