% load cluster of jobs
load('cluster.mat')

% select current job among cluster
job = cluster.jobs{job_number} ;

% initialize result.mat
result.called        = func2str(cluster.call_me) ;
result.variable_name = cluster.variable_name ;
result.id            = cluster.id ;
result.job_number    = job_number ;

result.UNFINISHED = 1 ;

% save intermediate result.mat
save(sprintf('result_%d',job_number-1),'result')

% carry out calculation, store result in result.result
if length(job.args)>0
    arg_string = sprintf( 'job.args{%d},' , 1:length(job.args)) ;
    arg_string = arg_string(1:end-1) ;
    eval_string = sprintf('result.result = cluster.call_me( %s ) ;',arg_string) ;
else
    eval_string = sprintf('result.result = cluster.call_me() ;') ;
end

result = rmfield(result,'UNFINISHED') ;

fprintf('evaluating %s\n',eval_string)
eval(eval_string)

% save result.mat
save(sprintf('result_%d',job_number-1),'result')