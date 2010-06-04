function lscp(from,to,ls_options,scp_options)
% first ls to check existence of file(s), then scp them if they do.

if nargin<4      , scp_options  = ''     ; end
if nargin<3      ,  ls_options  = ''     ; end

from = regexp(from,' ','split') ;

for i=1:length(from)
    [status,stdout] = unix( sprintf('ls %s %s',ls_options,from{i}) ) ;
    
    if ~status
        if ~strcmp(stdout,'ls: ')  % file exists
            these = regexp(stdout,'\s','split') ;
            
            for j=1:length(these)
                if ~isempty(these{j})
                    command = sprintf('scp %s %30s \t %s',scp_options,these{j},to) ;
                    fprintf(sprintf('%s\n',command))
                    xinu( command ) ;
                end
            end
        end
    end    
end

end