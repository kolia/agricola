%% agricola README
%
%   Use case:
%   You have access to a condor cluster and want to run matlab jobs on it.
%
%   agricola sends jobs to the cluster for you from within matlab, and
%   retrieves information about job progess and results as well.
%
%
%% INSTALL
%
%   0)  Set up public ssh keys so you can log into the condor submit node
%       without being asked for your password  =>  google for ssh-keygen
%   1)  Make sure the agricola/ folder is in your path.
%   2)  Modify  SET_ME_UP.m   (in this folder) appropriately.
%
%
%% USEAGE
%
%>> sow( 'my_result' , @()my_function(some_parameters) ) ;
%
%   LAUNCHES SINGLE JOB   my_function(some_parameters)   on the remote
%   cluster. The string  'my_result'  indicates the name of the variable
%   that will be used when retrieving results.
%
%   The rationale is that once results have been retrieved, this will have
%   been equivalent to typing:  my_result = my_function(some_parameters) ;
%   
%
%>> reap ;
%
%   RETRIEVES ALL RESULTS present in the remote working folder. Information
%   about the status of jobs are printed out, as well as more complete
%   information for the last submitted job (standard out or standard error
%   depending on job status). The results of successful jobs are placed in
%   the matlab workspace (as variable 'my_result' in the example above).
%
%   reap also places variable 'agricola' in the matlab workspace.
%   agricola.cluster{i}.job{j} contains fields 'err', 'logfile' and 'out',
%   with the contents of these three files on the remote server.
%
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
%
%% NOTES
%
%   agricola only copies .m files in the current folder to the remote
%   directory. If your calculation depends on code in other folders, either
%   copy those folders into your current directory, or into your remote
%   directory, making sure to add them to the path in the functions you
%   call. This could be improved in future versions by giving sow.m a list of
%   paths to copy from. Also, no support for mex files: compilation of mex
%   files can easily be added to your own functions. Check out sow.m 
%   line 42 to add patterns to what is copied over.
%
%   This is monkey-code. Expect bugs.
