function [p,frsON, frsOFF] = stfp_net_analysis(datadir,group4decoding,redo)
addpath('~/CARLsim4/tools/offline_analysis_toolbox')
% analysis parameters
FRdownsampleFactor = 10; % basically binWidth in ms
PSTHdownsampleFactor = 100; % basically binWidth in ms
%gaussWindowWidth = 250e-3; % in seconds (from old convert_spikes2frs)
alpha = 100; % 100ms
responseSigThresh = .01; % pvalue that must be achieved to define a cell as responsive
group_names = get_group_names(datadir);
p = extract_params([datadir '/params.txt']);
p.ngroups = length(group_names);
p.FRdownsampleFactor = FRdownsampleFactor;
p.responseSigThresh = responseSigThresh;
p.group_names = group_names;
p.PSTHdownsampleFactor = PSTHdownsampleFactor;
save([datadir '/p.mat'],'p','-mat')
ncells = get_ncells(p,group_names);
timeONCorrection = p.itt/p.dt;
timeOFFCorrection = (p.itt/p.dt) + p.nsmells*p.ntrials*(p.trial_time+p.itt)/p.dt;
if (~exist([datadir '/analysis_done.mat'],'file') || strcmp(redo,'yes'))
    %spikeCountsON = cell(length(group_names),p.nsmells,p.ntrials);
    %spikeCountsOFF = cell(length(group_names),p.nsmells,p.ntrials);
    %spike_timesON = cell(length(group_names),p.nsmells,p.ntrials);
    %spike_timesOFF = cell(length(group_names),p.nsmells,p.ntrials);
    %frsON = cell(length(group_names),p.nsmells,p.ntrials);
    %frsOFF = cell(length(group_names),p.nsmells,p.ntrials);
    %psthsON = cell(length(group_names));
    %psthsOFF = cell(length(group_names));
    for i=1:length(group_names)
        Xon_spikeCounts{i} = zeros(p.nsmells*p.ntrials,p.(['n' group_names{i}]));
        Xoff_spikeCounts{i} = zeros(p.nsmells*p.ntrials,p.(['n' group_names{i}]));
        trial_count=0;
        for j=1:p.nsmells
            for k=1:p.ntrials
                trial_count=trial_count+1;
                filenameON = [datadir '/spk_' group_names{i} '_on_' num2str(j) '_' num2str(k) '.dat'];
                filenameOFF = [datadir '/spk_' group_names{i} '_off_' num2str(j) '_' num2str(k) '.dat'];
                timeCorrection = ((j-1)*p.ntrials*(p.trial_time + p.itt) + (k-1)*(p.trial_time + p.itt))/p.dt;
                totalCorrectionON = timeONCorrection + timeCorrection - 1;
                totalCorrectionOFF = timeOFFCorrection + timeCorrection - 1;
                spikesON = get_spike_times(filenameON,ncells(i),totalCorrectionON);
                spikesOFF = get_spike_times(filenameOFF,ncells(i),totalCorrectionOFF);
                spkCountsON = get_spike_counts(spikesON);
                spkCountsOFF = get_spike_counts(spikesOFF);
                spikeCountsON{i}{j}{k} = spkCountsON;
                spikeCountsOFF{i}{j}{k} = spkCountsOFF;
                spike_timesON{i}{j}{k} = spikesON;
                spike_timesOFF{i}{j}{k} = spikesOFF;
                frsON{i}{j}{k} = convert_spikes2fr(p,spikesON,alpha,FRdownsampleFactor);
                frsOFF{i}{j}{k} = convert_spikes2fr(p,spikesOFF,alpha,FRdownsampleFactor);
                %frsON{i}{j}{k} = get_BAKS_frs(p,spikesON,FRdownsampleFactor);
                %frsOFF{i}{j}{k} = get_BAKS_frs(p,spikesOFF,FRdownsampleFactor);
                Xon_spikeCounts{i}(trial_count,:) = spkCountsON;
                Xoff_spikeCounts{i}(trial_count,:) = spkCountsOFF;
            end
        end
        psthsON{i} = get_psths(spike_timesON{i},(p.trial_time/p.dt),PSTHdownsampleFactor,p.dt);
        psthsOFF{i} = get_psths(spike_timesOFF{i},(p.trial_time/p.dt),PSTHdownsampleFactor,p.dt);
    end
    stim_IDs = repelem((1:p.nsmells)',p.ntrials,1);
    XtrON_knn = Xon_spikeCounts{group4decoding}(1:2:end,:);
    XtstON_knn = Xon_spikeCounts{group4decoding}(2:2:end,:);
    XtrOFF_knn = Xoff_spikeCounts{group4decoding}(1:2:end,:);
    XtstOFF_knn = Xoff_spikeCounts{group4decoding}(2:2:end,:);
    XtrONOFF_knn = Xon_spikeCounts{group4decoding};
    XtstONOFF_knn = Xoff_spikeCounts{group4decoding};
    save([datadir '/stim_IDs.mat'],'stim_IDs','-mat')
    save([datadir '/spike_timesON.mat'],'spike_timesON','-mat')
    save([datadir '/spike_timesOFF.mat'],'spike_timesOFF','-mat')
    save([datadir '/spikeCountsON.mat'],'spikeCountsON','-mat')
    save([datadir '/spikeCountsOFF.mat'],'spikeCountsOFF','-mat')
    save([datadir '/Xon_spikeCounts.mat'],'Xon_spikeCounts','-mat')
    save([datadir '/Xoff_spikeCounts.mat'],'Xoff_spikeCounts','-mat')
    save([datadir '/frsON.mat'],'frsON','-mat')
    save([datadir '/frsOFF.mat'],'frsOFF','-mat')
    save([datadir '/psthsON.mat'],'psthsON','-mat')
    save([datadir '/psthsOFF.mat'],'psthsOFF','-mat')
    get_FRpsths(datadir,'no');
    %{
    XtrONOFF_bayes = Xon_spikeCounts{group4decoding}(:,nonZeroVarCellsON);
    XtstONOFF_bayes = Xoff_spikeCounts{group4decoding}(:,nonZeroVarCellsON);
    XtrON_bayes = Xon_spikeCounts{group4decoding}(1:2:end,nonZeroVarCellsON);
    XtstON_bayes = Xon_spikeCounts{group4decoding}(2:2:end,nonZeroVarCellsON);
    XtrOFF_bayes = Xoff_spikeCounts{group4decoding}(1:2:end,nonZeroVarCellsOFF);
    XtstOFF_bayes = Xoff_spikeCounts{group4decoding}(2:2:end,nonZeroVarCellsOFF);
    [accuracyON_bayes,MODEL] = naive_bayes_prediction(XtrON_bayes,XtstON_bayes,stim_IDs(1:2:end));
    [accuracyOFF_bayes,MODEL] = naive_bayes_prediction(XtrOFF_bayes,XtstOFF_bayes,stim_IDs(1:2:end));
    [accuracyONOFF_bayes,MODEL] = naive_bayes_prediction(XtrONOFF_bayes,XtstONOFF_bayes,stim_IDs);
    save([datadir '/accuracyON_bayes.mat'],'accuracyON_bayes','-mat')
    save([datadir '/accuracyOFF_bayes.mat'],'accuracyOFF_bayes','-mat')
    save([datadir '/accuracyONOFF_bayes.mat'],'accuracyONOFF_bayes','-mat')
    %}
    [accuracyON_knn] = knn_prediction(XtrON_knn,XtstON_knn,stim_IDs(1:2:end));
    [accuracyOFF_knn] = knn_prediction(XtrOFF_knn,XtstOFF_knn,stim_IDs(1:2:end));
    [accuracyONOFF_knn] = knn_prediction(XtrONOFF_knn,XtstONOFF_knn,stim_IDs);
    save([datadir '/accuracyON_knn.mat'],'accuracyON_knn','-mat')
    save([datadir '/accuracyOFF_knn.mat'],'accuracyOFF_knn','-mat')
    save([datadir '/accuracyONOFF_knn.mat'],'accuracyONOFF_knn','-mat')
    
    get_stimulus_responses(datadir,'spikes')
    get_stimulus_responses(datadir,'firing rates');
    
    get_responsive_cells(datadir,'spikes');
    get_responsive_cells(datadir,'firing rates');
    
    [x_train, x_test] = make_xtrain_xtest(datadir,'spikes');
    %{
    save([datadir '/x_train.mat'],'x_train','-mat')
    save([datadir '/x_test.mat'],'x_test','-mat')
    [accuracyON_bayes,MODEL] = naive_bayes_prediction(x_train{group4decoding}(1:2:end,:),x_train{group4decoding}(2:2:end,:),stim_IDs(1:2:end));
    [accuracyOFF_bayes,MODEL] = naive_bayes_prediction(x_test{group4decoding}(1:2:end,:),x_test{group4decoding}(2:2:end,:),stim_IDs(1:2:end));
    [accuracyONOFF_bayes,MODEL] = naive_bayes_prediction(x_train{group4decoding},x_test{group4decoding},stim_IDs);
    save([datadir '/accuracyON_bayes.mat'],'accuracyON_bayes','-mat')
    save([datadir '/accuracyOFF_bayes.mat'],'accuracyOFF_bayes','-mat')
    save([datadir '/accuracyONOFF_bayes.mat'],'accuracyONOFF_bayes','-mat')
    %}
    analysis_done=1;
    save([datadir '/analysis_done.mat'],'analysis_done','-mat')
end
end