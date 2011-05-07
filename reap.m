function agricola = reap()
%%  USEAGE
%
%>> reap ;
%
%   RETRIEVES ALL RESULTS present in the remote working folder. Information
%   about the status of jobs are printed out, as well as more complete
%   information for the last submitted job (standard out or standard error
%   depending on job status). The results of successful jobs are placed in
%   the matlab workspace (as variable 'my_result' in the README example).
%
%>> agricola = reap
%
%   Returned variable 'agricola' contains all the information retrieved
%   from the server  --  in particular:
%   agricola.cluster{i}.job{j} contains fields 'err', 'logfile' and 'out',
%   with the contents of these three files on the remote server.
%

%% get results from remote server
[agricola.result,agricola.cluster] = reaper() ;

%% place results in current workspace
agricola.var_names = struct ;
agricola.conflict = 0 ;

% for all clusters of jobs
for i=1:length(agricola.cluster)
    if isfield(agricola.cluster{i}.job{1},'result')
        if isfield(agricola.cluster{i}.job{1}.result,'variable_name')

            % get name of result for cluster i
            variable_name = agricola.cluster{i}.job{1}.result.variable_name ;
            
            % has a result by that name already been retrieved?
            if isfield(agricola.var_names,agricola.cluster{i}.job{1}.result.variable_name)
                agricola.conflict = 1 ;
                agricola.cluster{i}.tag_to_keep = 0 ;
            else
                % if not, add name to var_names
                agricola.cluster{i}.tag_to_keep = 1 ;
                agricola.var_names.(variable_name) = [] ;
                
                % if result by that name already in workspace
                if evalin('base',sprintf( 'exist(''%s'',''var'') && ~iscell(''%s'')' , ...
                                           variable_name , variable_name ))
                    
                    % archive workspace value in 'overwritten'
                    agricola.overwritten.(variable_name) = ...
                        evalin('base',variable_name) ;
                    
                    % clear archived value 
                end
                
                % if more than 1 job, result is a cell struct
                if length(agricola.cluster{i}.job)>1
                    
                    result = cell(length(agricola.cluster{i}.job),1) ;

                    % loop over jobs in this cluster
                    for j=1:length(agricola.cluster{i}.job)
                        
                        % if result was retrieved from server for job j
                        if isfield( agricola.result,variable_name)      ...
                                &&  length(  agricola.result.(variable_name))>=j  ...
                                && ~isempty( agricola.result.(variable_name){j} )
                                                        
                            % save result of job j in main workspace
                            result{j} = agricola.result.(variable_name){j} ;
                            agricola.result.(variable_name){j} = [] ;
                        end
                    end
                else
                    
                    % if only 1 job
                    if isfield( agricola.result,variable_name)
                        result = agricola.result.(variable_name){1} ;
                        agricola.result.(variable_name){1} = [] ;
                    end
                end
                
                % if result exists, save it to variable_name in workspace
                if exist('result','var')
                    assignin('base',variable_name,result)
                    clear result
                end
            end
        else
            agricola.cluster{i}.tag_to_keep = 0 ;
        end
    else
        agricola.cluster{i}.tag_to_keep = 1 ;
    end
end

if agricola.conflict
    weed(agricola.cluster) ;
end

agricola.blurb   = sprintf('for  cluster 1  job 1 :  ') ;
agricola.message = '' ;
if strcmp( agricola.cluster{1}.job{1}.status , 'error')
        fprintf('ERROR FILE %s:\n\n%s',...
            agricola.blurb,agricola.cluster{1}.job{1}.err)
elseif isfield(agricola.cluster{1}.job{1},'out')
    fprintf('\n\n***************\n| OUTPUT FILE |  %s\n***************\n\n%s',...
             agricola.blurb,agricola.cluster{1}.job{1}.out)
    if strcmp( agricola.cluster{1}.job{1}.status , 'done')
        agricola.message = sprintf('  --  result stored in %s',...
                       agricola.cluster{1}.job{1}.result.variable_name) ;
    end
end
fprintf('\n\n')

% fprintf('\n\n**********\n| STATUS | %s %s%s\n**********\n\n\n',...
%     agricola.blurb,agricola.cluster{1}.job{1}.status,agricola.message)