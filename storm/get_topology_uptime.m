function [uptime]=get_topology_uptime(deployment_id)

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

uptime_string=topology_stats.uptime;

switch length(strfind(uptime_string,' '))
    case 0
        expression = '(?<seconds>\d+)s';
        uptime_struct=regexp(uptime_string,expression,'names');
        uptime=str2num(uptime_struct.seconds);
    case 1
        expression = '(?<minutes>\d+)m (?<seconds>\d+)s';
        uptime_struct=regexp(uptime_string,expression,'names');
        uptime=str2num(uptime_struct.minutes)*60+str2num(uptime_struct.seconds);
    case 2
        expression = '(?<hour>\d+)h (?<minutes>\d+)m (?<seconds>\d+)s';
        uptime_struct=regexp(uptime_string,expression,'names');
        uptime=str2num(uptime_struct.minutes)*60*60+str2num(uptime_struct.minutes)*60+str2num(uptime_struct.seconds);
    case 3
        expression = '(?<day>\d+)d (?<hour>\d+)h (?<minutes>\d+)m (?<seconds>\d+)s';
        uptime_struct=regexp(uptime_string,expression,'names');
        uptime=str2num(uptime_struct.minutes)*24*60*60+str2num(uptime_struct.minutes)*60*60+str2num(uptime_struct.minutes)*60+str2num(uptime_struct.seconds);
end


end