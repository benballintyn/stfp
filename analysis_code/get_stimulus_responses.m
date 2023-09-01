function [on_baselines,on_responses,off_baselines,off_responses] = get_stimulus_responses(datadir,responseType)
p = load([datadir '/p.mat']); p=p.p;
ngroups=p.ngroups;
nsmells=p.nsmells;
ntrials=p.ntrials;
group_names = get_group_names(datadir);
ncells = get_ncells(p,group_names);
switch responseType
    case 'spikes'
        spksON = load([datadir '/spike_timesON.mat']); spksON=spksON.spike_timesON;
        spksOFF = load([datadir '/spike_timesOFF.mat']); spksOFF=spksOFF.spike_timesOFF;
        for i=1:ngroups
            for j=1:nsmells
                for k=1:ntrials
                    for l=1:ncells(i)
                        on_baselines{i}{j}{k}(l) = length(find(spksON{i}{j}{k}{l} < p.stimon));
                        nspks_after_stimon = find(spksON{i}{j}{k}{l} > p.stimon);
                        nspks_before_stimoff = find(spksON{i}{j}{k}{l} < p.stimoff);
                        on_responses{i}{j}{k}(l) = length(intersect(nspks_after_stimon,nspks_before_stimoff));

                        off_baselines{i}{j}{k}(l) = length(find(spksOFF{i}{j}{k}{l} < p.stimon));
                        nspks_after_stimon = find(spksOFF{i}{j}{k}{l} > p.stimon);
                        nspks_before_stimoff = find(spksOFF{i}{j}{k}{l} < p.stimoff);
                        off_responses{i}{j}{k}(l) = length(intersect(nspks_after_stimon,nspks_before_stimoff));
                    end
                end
            end
        end
        save([datadir '/on_baselines_spikes.mat'],'on_baselines','-mat')
        save([datadir '/off_baselines_spikes.mat'],'off_baselines','-mat')
        save([datadir '/on_responses_spikes.mat'],'on_responses','-mat')
        save([datadir '/off_responses_spikes.mat'],'off_responses','-mat')
    case 'firing rates'
        frsON = load([datadir '/frsON.mat']); frsON=frsON.frsON;
        frsOFF = load([datadir '/frsOFF.mat']); frsOFF=frsOFF.frsOFF;
        stimon=(p.stimon/p.FRdownsampleFactor);
        stimoff=(p.stimoff/p.FRdownsampleFactor);
        for i=1:ngroups
            for j=1:nsmells
                for k=1:ntrials
                    on_baselines{i}{j}{k} = mean(frsON{i}{j}{k}(1:stimon,:),1);
                    off_baselines{i}{j}{k} = mean(frsOFF{i}{j}{k}(1:stimon,:),1);
                    on_responses{i}{j}{k} = mean(frsON{i}{j}{k}(stimon:stimoff,:),1);
                    off_responses{i}{j}{k} = mean(frsOFF{i}{j}{k}(stimon:stimoff,:),1);
                end
            end
        end
        save([datadir '/on_baselines_frs.mat'],'on_baselines','-mat')
        save([datadir '/off_baselines_frs.mat'],'off_baselines','-mat')
        save([datadir '/on_responses_frs.mat'],'on_responses','-mat')
        save([datadir '/off_responses_frs.mat'],'off_responses','-mat')
end
end

