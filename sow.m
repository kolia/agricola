function cluster = sow( variable_name , call_me , args , PBS_options )
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
if nargin<3 , args        = {{}}   ; end
if nargin<4 , PBS_options = struct ; end

% call 'setup' to load username, server, remote working folder
% and default PBS directives
SET_ME_UP

% name of this job's folder
cluster.id = sprintf('cluster___%s___%s',...
    variable_name,datestr(now,'ddd-dd-mmm-yyyy__HH-MM-SS')) ;

% apply additional PBS_options sown as argument
options = fieldnames(PBS_options) ;
for i=1:length(options)
    PBS.(options{i}) = PBS_options.(options{i}) ;
end

PBS.t = sprintf('1-%d',length(args)) ;
PBS.o = sprintf('localhost:%s/%s/',root,cluster.id) ;
PBS.e = sprintf('localhost:%s/%s/',root,cluster.id) ;
PBS.N = variable_name ;

here = which('sow') ;
here = here(1:end-6) ;

cluster.variable_name  = variable_name ;
cluster.call_me        = call_me ;

% create structure containing job descriptions
for i=1:length(args)
    cluster.jobs{i}.args = args{i} ;
end

% make job folder, containing cluster.mat and agricola.m
mkdir(cluster.id)
save( sprintf('%s/cluster.mat', cluster.id) , 'cluster' )
xinu( sprintf('cp %s/agricola.m %s/.' , here, cluster.id)) ;

% generate and add agricola.sh script to job folder
fid = fopen(sprintf('%s/agricola.sh', cluster.id),'w') ;
fwrite(fid,PBS2script(PBS)) ; fclose(fid) ;

% scp cluster folder to remote directory
xinu( sprintf('scp -r %s %s@%s:%s' , cluster.id,user,server,root)) ;


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
     'ssh %s@%s ''cd %s/%s ; qsub agricola.sh''',...
      user,server , root , cluster.id ) , '-echo') ;

cluster.submit.status = submit_status ;
cluster.submit.stdout = submit_out ;

end