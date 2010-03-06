function [status,result] = sickle( login , root , to , pattern )

[d,filename] = unix(sprintf('ssh %s ''cd %s/%s ; ls %s | grep -o %s''',...
                             login,root,to,pattern,pattern)) ;

if ~(length(filename)>3 && strcmp('ls:',filename(1:3)))
    filename = regexp(filename,'[0-9a-z._]*','match') ;
    filename = filename{1} ;
    status = xinu(sprintf('scp %s:%s/%s/%s %s',login,root,to,filename,to)) ;
    if ~status
        if strcmp(filename(end-3:end),'.mat')
            load(sprintf('%s/%s',to,filename)) ;
        else
            fid = fopen(sprintf('%s/%s',to,filename)) ;
            result = fscanf(fid,'%c') ;
        end
%     else
%         [status,result] = unix(sprintf('ssh %s ''cd %s/%s ; cat %s''',login,root,to,filename)) ;
    end
end

end