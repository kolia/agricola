user    = 'kss2137' ;                 % your login to a condor submit server
server  = 'hpcsubmit.cc.columbia.edu' ;      % condor submit server
root    = sprintf( '/hpc/30days/stats/users/%s/agricola' , user ) ; % working folder on server
email   = 'kss2137@columbia.edu' ;

% IF THE remote root directory doesn't already exist, RUN THIS:
% unix(sprintf('ssh %s@%s ''mkdir -p %s''',user,server,root)) ;