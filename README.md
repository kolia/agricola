agricola README
---------------

   Use case:
   You have access to a condor cluster and want to run matlab jobs on it.

   agricola sends jobs to the cluster for you from within matlab, and
   retrieves information about job progess and results as well, all with just two commands: `sow` and `reap`.


install
-------

   0.  Set up public ssh keys so you can log into the condor submit node
       without being asked for your password  =>  [google for 'ssh-keygen'](http://www.google.com/search?rls=en&q=ssh-keygen)

   1.  Make sure `agricola/agricola.sh` has execution permissions, if not  
       ` cd agricola ; chmod a+x agricola.sh `

   2.  Make sure the ` agricola/ ` folder is in your matlab path.

   3.  Modify  ` SET_ME_UP.m `   (in the `agricola/` folder) appropriately.


usage
------

`>> sow( 'my_result' , @()my_function(some_parameters) ) ;`

>   launches single job   `my_function(some_parameters)`   on the remote
>   cluster. The string  'my_result'  indicates the name of the variable
>   that will be used when retrieving results.

>   The rationale is that once results have been retrieved, this will have
>   been equivalent to typing:  
>   ` my_result = my_function(some_parameters) ; `
   


`>> reap ; `

>   retrieves all results present in the remote working folder. Information
>   about the status of jobs are printed out, as well as more complete
>   information for the last submitted job (standard out or standard error
>   depending on job status). The results of successful jobs are placed in
>   the matlab workspace (as variable 'my_result' in the example above).

>   a = reap ;   returns a structure
>   ` a.cluster{i}.job{j} ` which contains fields '`err`', '`logfile`' and '`out`',
>   with the contents of these three files on the remote server.



`>> sow( 'my_result' , @(param1,param2) my_func( param1 , other_params , param2 ) ,
  { { 1  'second' }  { 2  'third' } } ) ;`

>   launches multiple jobs (in this example 2) with different
>   parameters. This would be equivalent to the local commands:
   
`>> my_result{2} = my_func( 1 ,other_params, 'second' ) ;`
`>> my_result{3} = my_func( 2 ,other_params, 'third'  ) ;`



### notes ###

   agricola modifies the random seed so that they are different across
   jobs. This is implemented in `agricola.m`, so that program behaviour is
   similar to what one would expect on a local matlab instance (since
   condor clusters of jobs often give the same seed for every job).

   agricola only copies `.m` files in the current folder and local subfolders to the remote
   directory. If your calculation depends on code in other folders, either
   copy those folders into your current directory, or into your remote
   directory, making sure to add them to the path in the functions you
   call. This could be improved in future versions by giving `sow.m` a list of
   paths to copy from. Also, no support for mex files: compilation of mex
   files can easily be added to your own functions. Check out `sow.m` line 74 
   to add more files to be transferred.
