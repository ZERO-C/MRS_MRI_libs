function [data water]= mrs_readDATA( fileName )
% MRS_READDATA reads Philips MRS data file (.data) produced by delayed reconstruction. 
% If water suppression is enabled, .data file contains water-unsuppressed spectra (water)  
% and water-suppressed spectra (data). 
% 
% [data water] = mrs_readDATA(fileName)
%
% ARGS :
% fileName = name of data file 
%
% RETURNS:
% data = all water-suppressed FIDs without averaging, if water supression is not enabled;
%        otherwise, contains all target FIDs collected without averaging 
% water = [], if water supression is not enabled;
%         otherwise, contains all FIDs without water suppression  
%
% EXAMPLE: 
% >> [data water] = mrs_readDATA('sub1.data');
% >> size(data)
%
% AUTHOR : Chen Chen
% PLACE  : Sir Peter Mansfield Magnetic Resonance Centre (SPMMRC)
%
% Copyright (c) 2013, University of Nottingham. All rights reserved.
    
    [~,file_name,ext]=fileparts(fileName);  
    
    info=mrs_readLIST([file_name,'.list']);
    
    if isempty(ext)==1
        fileName=[fileName,'.data'];
    end
    
	% read in data
	fid=fopen(fileName,'r');
	data_in=fread(fid,'float32');
	fclose(fid);
    
	% reconstruct data to two rows (Real & Imag)
	data_in=reshape(data_in,2,[]);
      
    % remove noise FIDs
    start_point=info.noise_avgs*info.samples(1)+1;    
    data_all=squeeze(data_in(1,start_point:end)+1i*data_in(2,start_point:end));
    data_all=reshape(data_all,info.samples(1), sum(info.averages), info.dynamics(1));
   
    % get data and water FIDs    
    if length(info.averages)==2 
        water=data_all(:,1:info.averages(2),:); 
        data=data_all(:,(info.averages(2)+1):sum(info.averages),:);       
    else
        % if there is no water FIDs
        data=data_all;
        water=[]; 
    end
end

