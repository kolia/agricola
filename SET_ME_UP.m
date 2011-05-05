user    = 'kss2137' ;                % your login to a condor submit server
server  = 'hpcsubmit.cc.columbia.edu' ;  % condor submit server
root    = '~/agricola' ;             % working folder on server
PBS.M   = 'kss2137@columbia.edu' ;   % notification email
PBS.W   = 'group_list=hpcstats' ;    % user group

% IF THE remote root directory doesn't already exist, RUN THIS:
% unix(sprintf('ssh %s@%s ''mkdir -p %s''',user,server,root)) ;


% Torque directives : default values
% http://wiki.hpc.ufl.edu/index.php/PBS_Directives
PBS.l = 'nodes=1,walltime=01:00:00,mem=1000mb' ;
PBS.m = 'abe' ;
% PBS.V='';  % uncomment to export environment variables to agricola jobs


