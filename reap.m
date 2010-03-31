%%  USEAGE
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

clear agricola

[agricola.result,agricola.cluster] = reaper() ;

agricola.var_names = struct ;
agricola.conflict = 0 ;
for i=1:length(agricola.cluster)
    if isfield(agricola.cluster{i}.job{1},'result')
        if isfield(agricola.cluster{i}.job{1}.result,'variable_name')
            agricola.temp.variable_name = agricola.cluster{i}.job{1}.result.variable_name ;
            if isfield(agricola.var_names,agricola.cluster{i}.job{1}.result.variable_name)
                agricola.conflict = 1 ;
                agricola.cluster{i}.tag_to_keep = 0 ;
            else
                agricola.cluster{i}.tag_to_keep = 1 ;
                agricola.var_names.(agricola.temp.variable_name) = [] ;
                if length(agricola.cluster{i}.job)>1
                    for j=1:length(agricola.cluster{i}.job)
                        if isfield( agricola.result,agricola.temp.variable_name)      ...
                                && length( agricola.result.(agricola.temp.variable_name))>=j  ...
                                && ~isempty( agricola.result.(agricola.temp.variable_name){j} )
                            if exist(agricola.temp.variable_name,'var') ...
                                && ~eval(sprintf( 'iscell(%s)' , agricola.temp.variable_name ))
                               agricola.overwritten.(agricola.temp.variable_name) = ...
                                   eval(agricola.temp.variable_name) ;
                               eval(sprintf('clear %s',agricola.temp.variable_name))
                            end
                            me = sprintf('%s{%d} = agricola.result.(agricola.temp.variable_name){j} ;',...
                                agricola.temp.variable_name,j) ;
                            eval(me)
                        end
                    end
                else
                    if isfield( agricola.result,agricola.temp.variable_name)
                        eval(sprintf('%s = agricola.result.(agricola.temp.variable_name){1} ;',agricola.temp.variable_name))
                    end
                end
            end
            agricola = rmfield(agricola,'temp') ;
        else
            agricola.cluster{i}.tag_to_keep = 0 ;
        end
    else
        agricola.cluster{i}.tag_to_keep = 1 ;
    end
end
    
clear i j

if agricola.conflict
    weed(agricola.cluster) ;
end

agricola.blurb   = sprintf('of  cluster 1  job 1 :  ') ;
agricola.message = '' ;
if strcmp( agricola.cluster{1}.job{1}.status , 'error')
        fprintf('ERROR FILE %s\n%s',agricola.cluster{1}.job{1}.err,agricola.blurb)
else
    fprintf('\n\n***************\n| OUTPUT FILE |  %s\n***************\n\n%s',agricola.blurb,agricola.cluster{1}.job{1}.out)
    if strcmp( agricola.cluster{1}.job{1}.status , 'success')
        agricola.message = sprintf('  --  result stored in %s',agricola.cluster{1}.job{1}.result.variable_name) ;
    end
end
fprintf('\n\n')

% fprintf('\n\n**********\n| STATUS | %s %s%s\n**********\n\n\n',...
%     agricola.blurb,agricola.cluster{1}.job{1}.status,agricola.message)