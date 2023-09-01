function [allSpks] = load_all_spks(datadir)
if (exist([datadir '/p.mat'],'file'))
    p=load([datadir '/p.mat']); p=p.p;
else
    p=extract_params([datadir '/params.txt']);
end
group_names=get_group_names(datadir);
ngroups=length(group_names);
nsmells=p.nsmells;
ntrials=p.ntrials;

allSpks=[];
for i=1:ngroups
    for j=1:nsmells
        for k=1:ntrials
            fname = [datadir '/spk_' group_names{i} '_on_' num2str(j) '_' num2str(k) '.dat'];
            SR=SpikeReader(fname);
            spks=SR.readSpikes(-1);
            allSpks=[allSpks spks];
            
            fname = [datadir '/spk_' group_names{i} '_ISIs_on_' num2str(j) '_' num2str(k) '.dat'];
            SR=SpikeReader(fname);
            spks=SR.readSpikes(-1);
            allSpks=[allSpks spks];
        end
    end
end
for i=1:ngroups
    for j=1:nsmells
        for k=1:ntrials
            fname = [datadir '/spk_' group_names{i} '_off_' num2str(j) '_' num2str(k) '.dat'];
            SR=SpikeReader(fname);
            spks=SR.readSpikes(-1);
            allSpks=[allSpks spks];
            
            fname = [datadir '/spk_' group_names{i} '_ISIs_off_' num2str(j) '_' num2str(k) '.dat'];
            SR=SpikeReader(fname);
            spks=SR.readSpikes(-1);
            allSpks=[allSpks spks];
        end
    end
end
end

