function [uptimeSeconds]=executor_last_added(deployment_id,component_id)
% gets the uptime of the latest executor has been added, 
% this is an indicator of the last scaling action on this component.

% Authors: Pooyan Jamshidi (pooyan.jamshidi@gmail.com)
% The code is released under the FreeBSD License.
% Copyright (C) 2016 Pooyan Jamshidi, Imperial College London

global storm
if isdeployed
    ip = getmcruserdata('storm');
else ip=storm;
end

api='/api/v1/topology/';
url=[ip api deployment_id '/component/' component_id];
options = weboptions('RequestMethod','get');
component_stats = webread(url,options);

uptimeSeconds=component_stats.executorStats{1}.uptimeSeconds;
for i=1:size(component_stats.executorStats,1)
    if component_stats.executorStats{i}.uptimeSeconds<uptimeSeconds
        uptimeSeconds=component_stats.executorStats{i}.uptimeSeconds;
    end
end


end