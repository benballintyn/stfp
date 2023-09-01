function [score,p1,p2,p3] = scoreBehavior(datadir,frthresh)
net = load([datadir '/net.mat']); net=net.net;
netParams = load([datadir '/netParams.mat']); netParams=netParams.netParams
simParams = load([datadir '/simParams.mat']); simParams=simParams.simParams;
exc_inds = net.groupInfo(1).start_ind:net.groupInfo(1).end_ind;
inh_inds = net.groupInfo(2).start_ind:net.groupInfo(2).end_ind;
window = .1/simParams.dt; % 100ms
downsampleFactor = 10;

for i=1:simParams.nOdors
    for j=1:simParams.nTrials
        % Get Z-scored responses in the GC ON condition
        spikesPreON = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCON.bin'],simParams.cells2record);
        
        spikesStimON = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCON.bin'],simParams.cells2record);
        
        spikesPostON = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCON.bin'],simParams.cells2record);
        
        spikesStimON(:,1) = spikesStimON(:,1) + simParams.baseline_duration;
        spikesPostON(:,1) = spikesPostON(:,1) + simParams.baseline_duration + simParams.stim_duration;
        totalDuration = simParams.baseline_duration + simParams.stim_duration + simParams.poststim_duration;
        
        allspksON = [spikesPreON; spikesStimON; spikesPostON];
        frsON = getFiringRates(allspksON,length(simParams.cells2record),totalDuration,simParams.dt,downsampleFactor,window);
        
        endbaseline = simParams.baseline_duration/downsampleFactor;
        endstim = endbaseline + simParams.stim_duration/downsampleFactor;
        
        meanResponsesON_E = mean(frsON(endbaseline:endstim,exc_inds),1);
        meanResponsesON_I = mean(frsON(endbaseline:endstim,inh_inds),1);
        
        meanFRON_E(i,j,:) = meanResponsesON_E;
        meanFRON_I(i,j,:) = meanResponsesON_I;
        
        % Get Z-scored responses in the GC OFF condition
        spikesPreOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCOFF.bin'],simParams.cells2record);
        
        spikesPostOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF(:,1) = spikesStimOFF(:,1) + simParams.baseline_duration;
        spikesPostOFF(:,1) = spikesPostOFF(:,1) + simParams.baseline_duration + simParams.stim_duration;
        
        allspksOFF = [spikesPreOFF; spikesStimOFF; spikesPostOFF];
        frsOFF = getFiringRates(allspksOFF,length(simParams.cells2record),totalDuration,simParams.dt,downsampleFactor,window);
        
        meanResponsesOFF_E = mean(frsOFF(endbaseline:endstim,exc_inds),1);
        meanResponsesOFF_I = mean(frsOFF(endbaseline:endstim,inh_inds),1);
        
        meanFROFF_E(i,j,:) = meanResponsesOFF_E;
        meanFROFF_I(i,j,:) = meanResponsesOFF_I;
    end
    disp(['Done with odor ' num2str(i)])
end
[p1,p2,p3] = behaviorAnalog(simParams.nOdors,meanFRON_E,meanFROFF_E,frthresh,'no');
score = (1 - p1) + (1 - p2) + p3;
save([datadir '/behavior_score.mat'],'score','-mat')
end

