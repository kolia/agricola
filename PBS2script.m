function script = PBS2script( PBS )

script = sprintf('#!/bin/sh\n') ;
script = sprintf('%s#agricola.sh\n\n',script) ;

directives = fieldnames(PBS) ;
for i=1:length(directives)
    directive = PBS.(directives{i}) ;
    if ischar(directive)
        script = sprintf('%s#PBS -%s %s\n',script,directives{i},directive) ;
    elseif isstruct(directive) && (strcmp(directives{i},'W') || strcmp(directives{i},'l'))
        fields = fieldnames(directive) ;
        for j=1:length(fields)
            script = sprintf('%s#PBS -%s %s=%s\n',...
                script,directives{i},fields{j},directive.(fields{j})) ;
        end
    end
end

script = sprintf('%s\nmatlab -nosplash -nodisplay -nodesktop -r',script) ;
script = sprintf('%s "job_number = $PBS_ARRAYID ; agricola"',script) ;
script = sprintf('%s 1> result_$PBS_ARRAYID.out',script) ;
script = sprintf('%s 2> result_$PBS_ARRAYID.err\n',script) ;
end