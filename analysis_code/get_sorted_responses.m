function [on_pvals, off_pvals] = get_sorted_responses(datadir)
p=load([datadir '/p.mat']); p=p.p;
on=load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
off=load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
onb=load([datadir '/on_baselines_spikes.mat']); onb=onb.on_baselines;
offb=load([datadir '/off_baselines_spikes.mat']); offb=offb.off_baselines;
[ncells] = get_ncells(p,p.group_names);
for i=1:p.ngroups
    for j=1:p.nsmells
        for k=1:p.ntrials
            onbase(:,k) = onb{i}{j}{k}';
            offbase(:,k) = offb{i}{j}{k}';
            onSpks(:,k) = on{i}{j}{k}';
            offSpks(:,k) = off{i}{j}{k}';
        end
        for k=1:ncells(i)
            [pval,h] = ranksum(onbase(k,:),onSpks(k,:));
            on_pvals{i}{j}(k) = pval;
            [pval,h] = ranksum(offbase(k,:),offSpks(k,:));
            off_pvals{i}{j}(k) = pval;
        end
        clear onbase offbase onSpks offSpks
    end
end
end

