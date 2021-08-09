function T=flatten_core_struct_beds_public(S,T) 
% creates a table of bed statistics from a digitized section
% 2018 Zane Jobe and Ali Downard
% Inputs:
    % S - Matlab structure containing data from the Digitizer
    % T - Matlab table to store all the flattened data
% Outputs:
    % T - Matlab table with the flattened data
% Syntax:
    % T=table(); % preallocate
    % [T]=flatten_core_struct_beds(S,T);
 % Notes:
    % this is specific to turbidite settings, where an eod (environment of
    % deposition) is provided. Would need to be modified for other eods or
    % with Matlab structure data that differs from the example data.
    
%% main function
% first deal with numeric name (need to count up within the loop to generate a unique ID for each core)
if numel(T)>0
    len_inherited=T.count(end)+1;
else
    len_inherited=1;
end
len=len_inherited:1:length(S)+len_inherited;
    
for i=1:length(S)
    d=S(i); 
    
    % Use functions to find max,min,and mean gs
    clear bed out 
    bed = assign_bed_gs_convert_mm_public(d); % this pulls out all the x (gs) and y (depth) values 
    out = bed_calc_public(d, bed); % this finds n:g, amalg_ratio, mean_gs, etc.
    
    depth_m=bed(:,1); 
    grain_size_mm=bed(:,2); 
    
    % pull out variables for table
    th=d.th; % thickness
    tops=d.tops; % depth location for bed top
    max_gs_mm=out.maxgs; 
    mean_gs_mm=out.meangs;
    snd_shl=out.snd_shl; % 0 is shale, 1 is sand
    
    nbeds=d.n_beds; % find number of beds so we know how many times to repeat single variables for each entry
    
    % get gs_tops_mm from 'bed', not from original struct (it's wrong there)
    gs_tops_mm = zeros(length(nbeds));
    for j=1:nbeds
        gs_tops_mm(j) = bed{j,2}(1); % grabs the uppermost grain size value
    end
    gs_tops_mm = gs_tops_mm'; % transpose
    
    % repmat the strings and other bulk stats
    name=repmat(string(d.name),nbeds,1);
    count=repmat(len(i),nbeds,1); % numeric name
    collection=repmat(string(d.formation),nbeds,1);
    eod=repmat(string(d.eod),nbeds,1);
    ng=repmat(out.ng,nbeds,1); 
    ar=repmat(out.ar,nbeds,1); 
    % change eod to a numeric code
        % basin plain = 0
        % lobe/fan = 1
        % channel = 2
        % levee = 3
        if strcmp(d.eod,'basin plain')==1
            eodnum=0;
        elseif strcmp(d.eod,'fan')==1
            eodnum=1;
        elseif strcmp(d.eod,'slopechannel')==1
            eodnum=2;
        elseif strcmp(d.eod,'levee')==1
            eodnum=3;
        end
        
        if sum(strcmp(d.eod,['basin plain','fan','slopechannel',"levee"])) < 1
        error('ZANE SAYS: no eod found');
        else
        end
        
        eodnum=repmat(eodnum,nbeds,1);

    % % Other bulk stats:
    % th_std_=std(th,'omitnan');
    % mean_gsmm_std_=std(mean_gs_mm,'omitnan'); 
    
    [nbeds i] % error testing

    % make a table with function calculated and original table values 
    T_temp=table(name,count,collection,eod,eodnum,tops,th,gs_tops_mm,snd_shl,mean_gs_mm,max_gs_mm,ng,ar,depth_m,grain_size_mm);
    T=[T;T_temp];
    
end
end
