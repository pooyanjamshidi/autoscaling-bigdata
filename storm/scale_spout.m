function [status,msg]=scale_spout(deployment_id,spout_parallelism)
% scale the spout of topologies after checking invariants that may be violated
% if no invariant is violated it then scale the topology by calling
% rebalance function

% example: scale_spout('RollingSort-57-1463841798',3)
% 'RollingSort-57-1463841798' is the topology id,
% spout_parallelism provides the paralelism level of all
% spout components

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

parallelism={};

% search spouts
for j=1:size(topology_stats.spouts,1)
    parallelism=setfield(parallelism,topology_stats.spouts.spoutId,spout_parallelism);
    if spout_parallelism > topology_stats.spouts(j).tasks
        status=0; % it violates the invariant: #executors <= #numTasks
        break
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