function [status,msg]=scale_spout(deployment_id,parallelism)
% scale a topology after checking invariants that may be violated
% if no invariant is violated it then scale the topology by calling
% rebalance function

% example: scale_spout('RollingSort-57-1463841798',3)
% 'RollingSort-57-1463841798' is the topology id,
% struct('spout',1,'sort',2) provides the paralelism level of all
% components including all spouts and bolts, use the id of the components
% in the struct

% regarding invariants, see: http://www.michael-noll.com/blog/2012/10/16/understanding-the-parallelism-of-a-storm-topology/

% Authors: Pooyan Jamshidi (pooyan.jamshidi@gmail.com)
% The code is released under the FreeBSD License.
% Copyright (C) 2016 Pooyan Jamshidi, Imperial College London

global storm
if isdeployed
    ip = getmcruserdata('storm');
else ip=storm;
end

api='/api/v1/topology/';
url=[ip api deployment_id];
options = weboptions('RequestMethod','get');
topology_stats = webread(url,options);

number_of_workers=topology_stats.workersTotal;
wait_time=topology_stats.msgTimeout;

status=1; % rebalance can be done by default

component_ids=fieldnames(parallelism);

for i=1:size(component_ids,1)
    
    % search spouts
    for j=1:size(topology_stats.spouts,1)
        if strcmp(component_ids(i),topology_stats.spouts(j).spoutId)
            if getfield(parallelism, char(component_ids(i))) > topology_stats.spouts(j).tasks
                status=0; % it violates the invariant: #executors <= #numTasks
                break
            end
        end
    end
    
    % search bolts
    for j=1:size(topology_stats.bolts,1)
        if strcmp(component_ids(i),topology_stats.bolts(j).boltId)
            if getfield(parallelism, char(component_ids(i))) > topology_stats.bolts(j).tasks
                status=0; % it violates the invariant: #executors <= #numTasks
                break
            end
        end
    end
end

if status==1
    if rebalance_topology(deployment_id,wait_time,number_of_workers,parallelism)
        msg='success';
    else
        msg='an error happened in the rebalancing process';
        status=0;
    end
    
else
    msg='the paralellism level violates #executors <= #numTask invariant';
end

end