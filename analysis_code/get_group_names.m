function [group_names] = get_group_names(datadir)
if (exist([datadir '/group_names.mat']))
    group_names=load([datadir '/group_names.mat']); group_names=group_names.group_names;
else
    spkFiles = dir([datadir '/spk_*']);
    group_names = {};
    ngroups=0;
    for i=1:length(spkFiles)
        underscores = strfind(spkFiles(i).name,'_');
        name = spkFiles(i).name(5:underscores(2)-1);
        if (~ismember(name,group_names))
            ngroups=ngroups+1;
            group_names{ngroups} = name;
        end
    end
    save([datadir '/group_names.mat'],'group_names','-mat')
end
end

