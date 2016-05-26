function [latency,throughput]=get_topology_metrics(deployment_id,window)
% gets the end-to-end latency and throughout of topology deployment_id over
% the course of window(s)

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
url=[ip api deployment_id];
options = weboptions('RequestMethod','get');
topology_stats = webread(url,options);


if window_index==4
    latency=topology_stats.topologyStats(window_index).completeLatency;
    throughput=topology_stats.topologyStats(window_index).transferred/get_topology_uptime(deployment_id);
else
    latency=topology_stats.topologyStats(window_index).completeLatency;
    throughput=topology_stats.topologyStats(window_index).transferred/str2num(topology_stats.topologyStats(window_index).window);
end


end