function cluster = sow( variable_name , call_me , args )
%>> sow( 'my_result' , @()my_function(some_parameters) ) ;
%
%   LAUNCHES SINGLE JOB   my_function(some_parameters)   on the remote
%   cluster. The string  'my_result'  indicates the name of the variable
%   that will be used when retrieving results.
%
%   The rationale is that once results have been retrieved, this will have
%   been equivalent to typing:  my_result = my_function(some_parameters) ;
%
%>> sow( 'my_result' , ...
%        @(param1,param2) my_func( param1 , other_params , param2 ) , ...
%        { { 3  'first' }  { 1  'second' }  { 2  'third' } } ) ;
%
%   LAUNCHES MULTIPLE JOBS (in this example 3) with different
%   parameters. This would be equivalent to the local commands:
%   my_result{1} = my_func( 3 ,other_params, 'first'  ) ;
%   my_result{2} = my_func( 1 ,other_params, 'second' ) ;
%   my_result{3} = my_func( 2 ,other_params, 'third'  ) ;
%
%
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

cluster.id = sprintf('cluster___%s___%s',variable_name,datestr(now,'ddd-dd-mmm-yyyy__HH-MM-SS')) ;

% make job folder, containing cluster.mat
mkdir(cluster.id)
save( sprintf('%s/cluster.mat', cluster.id) , 'cluster' )

% shorthands
ssh = sprintf('ssh %s@%s',user,server) ;

% copy agricola.sub onto agricola.submit as base submit file
xinu( sprintf('cp %s/agricola.sub %s/agricola.submit ; echo ''notify_user = %s'' >> %s/agricola.submit ; echo ''executable = %s.sh'' >> %s/agricola.submit ;',...
               here, cluster.id , email , cluster.id , variable_name , cluster.id )) ;

% copy agricola.sh onto <VARIABLE_NAME>.sh
xinu( sprintf('mv %s/agricola.sh %s/%s.sh', here, cluster.id , variable_name )) ;

% append length(args) queue statements to agricola.submit
for i=1:length(args)
    xinu( sprintf(...
        'echo ''\njob_number = %d\nqueue\n'' >> %s/agricola.submit',i,cluster.id)) ;
end

% scp cluster folder, .sh and .submit files to remote directory
xinu( sprintf('scp -r %s %s@%s:%s' , cluster.id,user,server,root)) ;
lscp(sprintf('%s/%s.sh %s/agricola.m',...
              here,variable_name,here),...
     sprintf('%s@%s:%s/%s',user,server,root,cluster.id)) ;
 
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  MODIFY THIS IF YOU NEED MORE FILES TRANSFERED!!!  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

lscp('*.mex *.m */*.m */*.mex',...
     sprintf('%s@%s:%s/%s',user,server,root,cluster.id)) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


 
% delete job folder from current directory: cleaning up
xinu(sprintf('rm -rf %s',cluster.id)) ;

[submit_status , submit_out] = ...
xinu( sprintf(...
     '%s ''PATH=$PATH:/opt/condor/bin ; cd %s/%s ; condor_submit agricola.submit''',...
      ssh , root , cluster.id ) , '-echo') ;

cluster.submit.status = submit_status ;
cluster.submit.stdout = submit_out ;

end