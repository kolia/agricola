function [result , cluster] = reaper( patterns , var_name )

if nargin<1 , patterns = {} ; end
patterns = [patterns {'result'}] ;
pattern  = '' ;
grepper  = '' ;
for i=1:length(patterns)
    pattern = [pattern sprintf('|%s*',patterns{i})] ;
    grepper = [grepper sprintf('\\|%s*',patterns{i})] ;
end
pattern = pattern(2:end) ;
grepper = grepper(3:end) ;

SET_ME_UP

% shorthands
ssh = sprintf('ssh %s@%s',user,server) ;

% ls remote root folder for list of job folders, in order of creation time
[status,stdout] = xinu(sprintf(...
    '%s ''cd %s ; ls --sort=time --time=ctime | grep cluster_''',...
    ssh,root)) ;

cluster_ids = regexp(stdout,...
    'cluster___\S*___[MTWFS][ouehra][neduitn]-[0-9]*-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9]__[0-9][0-9]-[0-9][0-9]-[0-9][0-9]','match') ;

login = sprintf('%s@%s',user,server) ;

cluster = cell(length(cluster_ids),1) ;
result  = struct ;

for i=length(cluster_ids):-1:1
    
    % should we look for 'var_name' on server?
    if nargin<2 || strcmp(cluster_ids{i}(11:10+length(var_name)),var_name)
        warning off ; mkdir(cluster_ids{i}) ; warning on ;
        cluster{i}.id = cluster_ids{i} ;
        
        % get files that match patterns
        [status,stdout] = unix(sprintf(...
            '%s "cd %s/%s ; ls -r | grep ''%s''"',...
            ssh,root,cluster_ids{i},grepper)) ;
        %             status = xinu(sprintf('scp %s:%s/%s/[0-9][0-9][0-9]*.* %s',...
        %                 login,root,cluster_ids{i},cluster_ids{i})) ;
        status = 0 ;
        for ii=1:length(patterns)
            s = xinu(sprintf('scp %s:%s/%s/%s* %s',...
                login,root,cluster_ids{i},patterns{ii},cluster_ids{i})) ;
            status = status || s ;
        end
        
        if ~status && nargout>1
            filenames = regexp(stdout,'\S+','match') ;
            for j=1:length(filenames)
                
                if strcmp(filenames{j}(end-3:end),'.mat')
                    x = load(sprintf('%s/%s',cluster_ids{i},filenames{j})) ;
                    if isfield(x,'result')
                        x = x.result ;
                    end
                else
                    fid = fopen(sprintf('%s/%s',cluster_ids{i},filenames{j})) ;
                    x = fscanf(fid,'%c') ;
                    fclose(fid) ;
                end
                
                match = regexp(filenames{j} , sprintf('^(%s)\\D*\\d+\\D*$',pattern) , 'match') ;
                if ~isempty(match)
                    match = match{1} ;
                    job_number_string = regexp(match,'\d+' , 'match') ;
                    job_number  = str2double(job_number_string{1}) ;
                    file_type   = regexp(match,'[a-zA-Z]+' , 'match') ;
                    this_pattern= regexp(file_type{1},pattern,'match') ;
                    this_pattern=this_pattern{1} ;
                    file_type   = file_type{end} ;
                    if strcmp(file_type,'mat') && ~isempty(this_pattern)
                        if strcmp(this_pattern,'result')
                            if isfield(x,'result')
                                if j==1 && isfield(result,x.variable_name)
                                    result.(x.variable_name) = {} ;
                                end
                                result.(x.variable_name){job_number} = x.result ;
                                cluster{i}.job{job_number}.result = rmfield(x,'result') ;
                            else
                                cluster{i}.job{job_number}.result = x ;
                            end
                        else
                            cluster{i}.job{job_number}.(this_pattern) = x ;
                        end
                    elseif isfield(x,'result')
                        cluster{i}.job{job_number}.(file_type) = x ;
                    end
                end
            end
            unix(sprintf('rm -rf %s',cluster_ids{i})) ;
        end
    end
end

inds = [] ;
for i=1:length(cluster_ids)
    if ~isempty(cluster_ids{i}) , inds = [inds i] ; end
    jobinds = [] ;
    for j=1:length(cluster{i}.job)
        if ~isempty(cluster{i}.job{j}) , jobinds = [jobinds j] ; end
    end
    cluster{i}.job = cluster{i}.job(jobinds) ;
end
cluster = cluster(inds) ;
cluster = add_status(cluster) ;
fprintf('\n')
display_status(cluster)

if nargin>1
   result = result.(var_name) ; 
end
end


function cluster = add_status(cluster)

for i=1:length(cluster)
    for j=1:length(cluster{i}.job)
        if isfield(cluster{i}.job{j},'err') && ~isempty(cluster{i}.job{j}.err)
            cluster{i}.job{j}.status = 'error' ;
        elseif isfield(cluster{i}.job{j},'result')
            if isfield(cluster{i}.job{j}.result,'UNFINISHED')
                cluster{i}.job{j}.status = 'pending' ;
            else
                cluster{i}.job{j}.status = 'done' ;
            end
        else
            cluster{i}.job{j}.status = 'pending' ;
        end
    end
end
end


function display_status(cluster)
for i=1:length(cluster)
try
    for j=1:length(cluster{i}.job)
        fprintf('cluster %d  job %3d   %15s',i,j,cluster{i}.job{j}.status) ;
        try
            fprintf('     %s',cluster{i}.job{j}.result.variable_name) ;
        end
        fprintf('\n')
    end
    fprintf('\n')
end
end
end