function cluster = sow( variable_name , call_me , args )

if nargin<3
    args = {{}} ;
end

% call 'setup' to load username, server and remote working folder
SET_ME_UP

here = which('sow') ;
here = here(1:end-6) ;

cluster.variable_name  = variable_name ;
cluster.call_me        = call_me ;

% create structure containing job descriptions
for i=1:length(args)
    cluster.jobs{i}.args           = args{i} ;
end

cluster.id = sprintf('cluster___%s___%s',datestr(now,'ddd-dd-mmm-yyyy__HH-MM-SS'),variable_name) ;

% make job folder, containing cluster.mat
mkdir(cluster.id)
save( sprintf('%s/cluster.mat', cluster.id) , 'cluster' )

% shorthands
ssh = sprintf('ssh %s@%s',user,server) ;

% copy agricola.sub onto agricola.submit as base submit file
xinu( sprintf('cp %s/agricola.sub %s/agricola.submit', here, here )) ;

% append length(args) queue statements to agricola.submit
for i=1:length(args)
    xinu( sprintf(...
        'echo ''\njob_number = %d\nqueue\n'' >> %s/agricola.submit',i,here)) ;
end

% scp cluster folder, .m .sh and .submit files to remote directory
xinu( sprintf(...
    'scp -r %s %s@%s:%s ; scp %s/agricola.submit */*.m %s/agricola.sh %s/agricola.m *.m %s@%s:%s/%s',...
     cluster.id,user,server,root,here,here,here,user,server,root,cluster.id)) ;

% delete job folder from current directory: cleaning up
xinu(sprintf('rm -rf %s',cluster.id)) ;

[submit_status , submit_out] = ...
xinu( sprintf(...
     '%s ''PATH=$PATH:/opt/condor/bin ; cd %s/%s ; condor_submit agricola.submit''',...
      ssh , root , cluster.id ) , '-echo') ;

cluster.submit.status = submit_status ;
cluster.submit.stdout = submit_out ;

end