function [status]=rebalance_topology(deployment_id,wait_time,number_of_workers,parallelism)
% Rebalances a topology. this is a low level method.

% example: rebalance_topology('RollingSort-57-1463841798',60,3,struct('spout',1,'sort',2))
% 'RollingSort-57-1463841798' is the topology id, 60 is the Wait time
% before rebalance happens, 3 is the number of workers,
% struct('spout',1,'sort',2) provides the paralelism level of all
% components including all spouts and bolts, use the id of the components
% in the struct

% Authors: Pooyan Jamshidi (pooyan.jamshidi@gmail.com)
% The code is released under the FreeBSD License.
% Copyright (C) 2016 Pooyan Jamshidi, Imperial College London

global storm
if isdeployed
    ip = getmcruserdata('storm');
else ip=storm;
end

api='/api/v1/topology/';
url=[ip api deployment_id '/rebalance/' num2str(wait_time)];
options = weboptions('RequestMethod','auto','MediaType','application/json');
data = struct('rebalanceOptions',struct('numWorkers',number_of_workers,'executors',parallelism));

response = webwrite(url,data,options);
if strcmp(response.status,'success')
    status=1;   
else
    status=0;  
end


end