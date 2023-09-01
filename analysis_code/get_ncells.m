function [ncells] = get_ncells(p,group_names)
for i=1:length(group_names)
    ncells(i) = p.(['n' group_names{i}]);
end
end

