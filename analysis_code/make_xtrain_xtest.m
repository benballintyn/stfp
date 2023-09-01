function [x_train, x_test] = make_xtrain_xtest(datadir,responseType)
p = load([datadir '/p.mat']); p=p.p;
ngroups=p.ngroups;
nsmells=p.nsmells;
ntrials=p.ntrials;
group_names = get_group_names(datadir);
ncells = get_ncells(p,group_names);
switch responseType
    case 'spikes'
        on = load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
        off = load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
    case 'firing rates'
        on = load([datadir '/on_responses_frs.mat']); on=on.on_responses;
        off = load([datadir '/off_responses_frs.mat']); off=off.off_responses;
end

for i=1:ngroups
    trial_count = 0;
    for j=1:nsmells
        for k=1:ntrials
            trial_count=trial_count+1;
            for l=1:ncells(i)
                x_train{i}(trial_count,l) = on{i}{j}{k}(l);
                x_test{i}(trial_count,l) = off{i}{j}{k}(l);
            end
        end
    end
end

switch responseType
    case 'spikes'
        save([datadir '/x_train_spikes.mat'],'x_train','-mat')
        save([datadir '/x_test_spikes.mat'],'x_test','-mat')
    case 'firing rates'
        save([datadir '/x_train_frs.mat'],'x_train','-mat')
        save([datadir '/x_test_frs.mat'],'x_test','-mat')
end
end

