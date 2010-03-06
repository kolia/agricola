function weed(cluster)

fprintf('\nThe following remote folders have been marked for deletion:')
for i=1:length(cluster)
    if isfield(cluster{i},'tag_to_keep') && ~cluster{i}.tag_to_keep
        try
            fprintf('\n%10s in  %s',cluster{i}.job{1}.result.variable_name,cluster{i}.id)
        catch
            fprintf('\n%10s in  %s','',cluster{i}.id)
        end
    end
end

fprintf('\n\nThe following folders will be kept:')
for i=1:length(cluster)
    if isfield(cluster{i},'tag_to_keep') &&  cluster{i}.tag_to_keep
        try
            fprintf('\n%10s in  %s',cluster{i}.job{1}.result.variable_name,cluster{i}.id)
        catch
            fprintf('\n%10s in  %s','',cluster{i}.id)
        end
    end
end

while 1
    user_input = input('\n\nProceed? (y/n):','s') ;
    switch user_input
        case 'y'
            weeder(cluster) ;
            break
        case 'n'
            fprintf('leaving remote folder as is...\n\n') ;
            break
        otherwise
            user_input = input('\nanswer: ''y'' or ''n''','s') ;
    end
end

end


function weeder(c)
SET_ME_UP
for i=1:length(c)
    if isfield(c{i},'tag_to_keep') && ~c{i}.tag_to_keep
        xinu(sprintf( ...
            'ssh %s@%s ''cd %s ; rm -rf %s''',...
             user,server,root,c{i}.id)) ;
    end
end
end