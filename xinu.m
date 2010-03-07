function [status,stdout] = xinu( command , option )
% same as matlab builtin 'unix', but displays stdout if return status is
% not 0

if nargin>1
    [status,stdout] = unix( command , option ) ;
else
    [status,stdout] = unix( command ) ;
end

if status
    fprintf('\n\nERROR running unix command\n%s\n',command)
    fprintf('stdout was: %s',stdout)
end
end