function out=bed_calc_public(C,bed)
% Calculate Bed Properties

n=size(bed); n=n(1); % takes only the number of rows (i.e., the number of beds)

cut=0.070; % sand shale cutoff (use slightly larger than 0.0625, as sometimes the digitizer is on the edge)

%% Mean Grain Size (mm)
X1=cellfun(@(x,y)trapz(x,y),bed(:,1),bed(:,2)); % find area of each bed
if C.tops(1)>C.tops(end)
    X1=-1*X1;
end
X2=cellfun(@(x)range(x),bed(:,1)); % finding the thickness of the bed
out.meangs=X1./X2; % 'area-weighted' average grain size
out.meangs=abs(out.meangs); % put this in to fix cores with only one bed (e.g., Congo kzr-19)

%% Max Grain Size (mm)
maxgs=cellfun(@(x)max(x),bed(:,2)); % find max grain size
maxgs(isnan(out.meangs))=NaN; % assign NaN to maxgs
out.maxgs=maxgs; % write to structure

%% Thickness
out.th=C.th;

%% Bed N:G
id=~isnan(out.meangs); % NaNs here are covered intervals
snd=out.meangs>cut;
shl=out.meangs<=cut;

gross=sum(out.th(id));
net=sum(out.th(id & snd));
out.ng=net/gross;

%% Bed sand Shale
snd_shl=nan(n,1);
snd_shl(snd)=1; snd_shl(shl)=0;
out.snd_shl=snd_shl;

%% Amalgamation Ratio
% first, flip if its a core to maintain stratigrpahic order
if strcmp(C.type,'core')==1
    ssar=flipud(snd_shl);
else
    ssar=snd_shl; % do not flip if its a 'strat'
end
% make sure that no mud-on-mud contacts are counted
ssar(ssar==0)=NaN;
% then, find sand on sand contacts
arcount=sum(~isnan(diff(ssar)));
% now divide by the total number of contacts (i.e., beds)
ar=arcount/n; % n is the total number of beds
out.ar=ar;

%% Event to Lithologic Thickness ratio stats (Written by Ali Downard)
%%% determine indeces of amalgamated beds
amalgBeds_=diff(ssar);
amalgBeds = amalgBeds_;
for i=1:length(amalgBeds_)-1   % insert extra zero for cutoff beds
    if amalgBeds_(i)==0
        amalgBeds(i+1) = 0; 
    end
end
indx=find(~isnan(amalgBeds)); % index of beds that are amalgamated
indx2=find(diff(indx)~=1);    % index of last bed in amalgamated section
if isempty(indx2)
    E2L=0;
else
    %%% compare mean event th to lithologic th for amalgamated sections
    j=1;
    E2L=zeros(length(indx2)+1,1);
    for i=1:length(indx2)+1
        if i>length(indx2)
            th=C.th(indx(j):indx(end)); % grab th for last amalg unit
        else
            th=C.th(indx(j):indx(indx2(i))); % grab th for amalg unit
            j=indx2(i)+1; % update index so it starts at next amalg unit
        end
        E2L(i)=mean(th)/sum(th);  % avg event th/lithologic th; 
    end
end
%%% return stats of these ratios 
out.E2L_avg=mean(E2L); 
out.E2L_max=max(E2L);  
out.E2L_std=std(E2L); 
out.E2L_p10=prctile(E2L,10);
out.E2l_p90=prctile(E2L,90); 

%% Sand-Bodies (Block)

%Case 1 : Interrupted Shale or No Recovery
[x1,x2]=SplitVec(out.snd_shl,[],'firstval','loc');

ind=find(x1==1); 
x3=x2(ind);

tmp=cellfun(@(x)C.th(x),x3,'UniformOutput',false);
out.SB=cellfun(@(x)sum(x),tmp);

%Case 2: No Recovery < Threshold Assigned Sand Shale
% id1=INPAINT_NANS(x1,2); 
% id2=id1==1;
% 
% % Redefine Sands 
% x3=x2(id2);
% x
% 
% tmp=cellfun(@(x)C.th(x),x3,'UniformOutput',false);
 
% 
% 
% th=C.th;
% th(x1==0.5)=th(x1==0.5)/2;
% 
% 
% x1(x1==0.5)=1;



%ind=find(x1==1); x3=x2(ind);
%tmp=cellfun(@(x)th(x),x3,'UniformOutput',false);
%out.SB2=cellfun(@(x)sum(x),tmp);


%Case 3: 
