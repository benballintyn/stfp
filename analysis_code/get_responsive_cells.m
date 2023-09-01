function [on_responsive, off_responsive] = get_responsive_cells(datadir,responseType)
p = load([datadir '/p.mat']); p=p.p;
ngroups=p.ngroups;
nsmells=p.nsmells;
ntrials=p.ntrials;
group_names = get_group_names(datadir);
ncells = get_ncells(p,group_names);
switch responseType
    case 'spikes'
        on_baselines = load([datadir '/on_baselines_spikes.mat']); on_baselines=on_baselines.on_baselines;
        off_baselines = load([datadir '/off_baselines_spikes.mat']); off_baselines=off_baselines.off_baselines;
        on_responses = load([datadir '/on_responses_spikes.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses_spikes.mat']); off_responses=off_responses.off_responses;
    case 'firing rates'
        on_baselines = load([datadir '/on_baselines_frs.mat']); on_baselines=on_baselines.on_baselines;
        off_baselines = load([datadir '/off_baselines_frs.mat']); off_baselines=off_baselines.off_baselines;
        on_responses = load([datadir '/on_responses_frs.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses_frs.mat']); off_responses=off_responses.off_responses;
end

for i=1:ngroups
    for j=1:nsmells
        on_responsive{i}{j} = [];
        off_responsive{i}{j} = [];
        for k=1:ncells(i)
            for l=1:ntrials
                on_bases(l) = on_baselines{i}{j}{l}(k);
                on_resps(l) = on_responses{i}{j}{l}(k);
                off_bases(l) = off_baselines{i}{j}{l}(k);
                off_resps(l) = off_responses{i}{j}{l}(k);
            end
            %[hON,pvalON] = ttest2(on_bases,on_resps);
            %[hOff,pvalOFF] = ttest2(off_bases,off_resps);
            [pval,hON] = ranksum(on_bases,on_resps,p.responseSigThresh);
            [pval,hOFF] = ranksum(off_bases,off_resps,p.responseSigThresh);
            if (hON)
                curcells = on_responsive{i}{j};
                on_responsive{i}{j} = [curcells k];
            end
            if (hOFF)
                curcells = off_responsive{i}{j};
                off_responsive{i}{j} = [curcells k];
            end
        end
    end
end
switch responseType
    case 'spikes'
        save([datadir '/on_responsive_spikes.mat'],'on_responsive','-mat')
        save([datadir '/off_responsive_spikes.mat'],'off_responsive','-mat')
    case 'firing rates'
        save([datadir '/on_responsive_frs.mat'],'on_responsive','-mat')
        save([datadir '/off_responsive_frs.mat'],'off_responsive','-mat')
end
end

