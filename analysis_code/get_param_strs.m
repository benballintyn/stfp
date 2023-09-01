function [paramStrs] = get_param_strs(params)
% Inputs:
% 1. params -> must be a cell array of strings with one string per cell
for i=1:length(params)
    newstr=params{i};
    ind=strfind(newstr,'_prob');
    if (~isempty(ind))
        newstr=newstr(1:ind-1);
        ind=strfind(newstr,'_');
        if (~isempty(ind))
            newstr=['P_{' newstr(ind+1:end) '}(' newstr(1:ind-1) ')'];
        else
            newstr=['P(' newstr ')'];
        end
    end
    ind=strfind(newstr,'2');
    if (~isempty(ind))
        newstr=strrep(newstr,'2',' -> ');
    end
    paramStrs{i}=newstr;
end
end

