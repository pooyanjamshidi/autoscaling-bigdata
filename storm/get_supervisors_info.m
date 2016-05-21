function [supervisors]=get_supervisors_info()
% get supervisor information, name and the number of free slots in each
% the free slots are used to get the knwoledge about how evenly  
% the workers are distributed among all the hosts 

% Authors: Pooyan Jamshidi (pooyan.jamshidi@gmail.com)
% The code is released under the FreeBSD License.
% Copyright (C) 2016 Pooyan Jamshidi, Imperial College London

global storm
if isdeployed
    ip = getmcruserdata('storm');
else ip=storm;
end

api='/api/v1/supervisor/summary';
url=[ip api];
options = weboptions('RequestMethod','get');
supervisors_stats = webread(url,options);

for i=1:size(supervisors_stats.supervisors,1)
    supervisors(i).name=supervisors_stats.supervisors(i).host;
    supervisors(i).freeSlots=supervisors_stats.supervisors(i).slotsTotal-supervisors_stats.supervisors(i).slotsUsed;    
end

end