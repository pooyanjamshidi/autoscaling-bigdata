function [latency,throughput]=get_component_metrics(deployment_id,component_id,window)
% gets the latency and throughout of component with component_id used in
% topology deployment_id over the course of window(s)

% Authors: Pooyan Jamshidi (pooyan.jamshidi@gmail.com)
% The code is released under the FreeBSD License.
% Copyright (C) 2016 Pooyan Jamshidi, Imperial College London

global storm
if isdeployed
    ip = getmcruserdata('storm');
else ip=storm;
end

switch window
    case '10m'
        window_index=1;
    case '3h'
        window_index=2;
    case 'all'
        window_index=4;        
end

api='/api/v1/topology/';
url=[ip api deployment_id '/component/' component_id];
options = weboptions('RequestMethod','get');
component_stats = webread(url,options);


if strcmp(component_stats.componentType,'spout')
    if window_index==4 % differentiating 'all' to get the window time based on the uptime of topology
        % because 'all' basically means the window over topology lifetime
        latency=component_stats.spoutSummary(window_index).completeLatency;
        throughput=component_stats.spoutSummary(window_index).transferred/get_topology_uptime(deployment_id);
    else
        latency=component_stats.spoutSummary(window_index).completeLatency;
        throughput=component_stats.spoutSummary(window_index).transferred/str2num(component_stats.spoutSummary(window_index).window);
    end
elseif strcmp(component_stats.componentType,'bolt')
    if window_index==4
        latency=component_stats.boltStats(window_index).executeLatency;
        throughput=component_stats.boltStats(window_index).executed/get_topology_uptime(deployment_id);
    else
        latency=component_stats.boltStats(window_index).executeLatency;
        throughput=component_stats.boltStats(window_index).executed/str2num(component_stats.boltStats(window_index).window);
    end
end


end