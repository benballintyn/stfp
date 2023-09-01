%redo_frs
datadirs{1} = '/media/ben/Manwe/phd/carlsim/data/EI_net/surrogate_run2';
datadirs{2} = '/media/ben/Manwe/phd/carlsim/data/EI_net_cluster/surrogate_run2';
datadirs{3} = '/media/ben/Manwe/phd/carlsim/data/EI_net_gaussian/surrogate_run2';
datadirs{4} = '/media/ben/Manwe/phd/carlsim/data/EI_net_wtGradient/surrogate_run1';
datadirs{5} = '/media/ben/Manwe/phd/carlsim/data/EI_net_wtGradient_gauss/surrogate_run1';
for d=1:5
    run_num=load([datadirs{d} '/run_num.mat']); run_num=run_num.run_num;
    downsampleFactor=10;
    window=100;
    for i=1:run_num
        curdir = [datadirs{d} '/' num2str(i)];
        p=load([curdir '/p.mat']); p=p.p;
        spksON=load([curdir '/spike_timesON.mat']); spksON=spksON.spike_timesON;
        spksOFF=load([curdir '/spike_timesOFF.mat']); spksOFF=spksOFF.spike_timesOFF;
        for j=1:p.ngroups
            for k=1:p.nsmells
                for l=1:p.ntrials
                    frsON{j}{k}{l} = convert_spikes2fr(p,spksON{j}{k}{l},window,downsampleFactor);
                    frsOFF{j}{k}{l} = convert_spikes2fr(p,spksOFF{j}{k}{l},window,downsampleFactor);
                end
            end
        end
        save([curdir '/frsON.mat'],'frsON','-mat')
        save([curdir '/frsOFF.mat'],'frsOFF','-mat')
        disp(['done with ' num2str(i)])
    end
end