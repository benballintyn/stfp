function score = scoreNet(datadir)
net = load([datadir '/net.mat']); net=net.net;
netParams = load([datadir '/netParams.mat']); netParams=netParams.netParams;
simParams = load([datadir '/simParams.mat']); simParams=simParams.simParams;
exc_inds = net.groupInfo(1).start_ind:net.groupInfo(1).end_ind;
% Parameters for creating firing rates
window = .1/simParams.dt; % 100ms
downsampleFactor = 10;

%zResponsesON = zeros(simParams.nOdors,simParams.nTrials,length(simParams.cells2record));
%zResponsesOFF = zeros(simParams.nOdors,simParams.nTrials,length(simParams.cells2record));
count = 1;
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
        allFrsON(j,:,:) = frsON;
        
        endbaseline = simParams.baseline_duration/downsampleFactor;
        endstim = endbaseline + simParams.stim_duration/downsampleFactor;
        
        %meanBaselineON = mean(frsON(1:endbaseline,exc_inds),1);
        %stdBaselineON = std(frsON(1:endbaseline,exc_inds),[],1);
        meanResponsesON = mean(frsON(endbaseline:endstim,exc_inds),1);
        %zON = (meanResponsesON - meanBaselineON)./stdBaselineON;
        XON(count,:) = meanResponsesON;
        classes(count) = i;
        meanFRON(i,j,:) = meanResponsesON;
        %zResponsesON(i,j,:) = zON;
        
        % Get Z-scored responses in the GC OFF condition
        spikesPreOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCOFF.bin'],simParams.cells2record);
        
        spikesPostOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF(:,1) = spikesStimOFF(:,1) + simParams.baseline_duration;
        spikesPostOFF(:,1) = spikesPostOFF(:,1) + simParams.baseline_duration + simParams.stim_duration;
        
        allspksOFF = [spikesPreOFF; spikesStimOFF; spikesPostOFF];
        frsOFF = getFiringRates(allspksOFF,length(simParams.cells2record),totalDuration,simParams.dt,downsampleFactor,window);
        %allFrsOFF(j,:,:) = frsOFF;
        
        %meanBaselineOFF = mean(frsOFF(1:endbaseline,exc_inds),1);
        %stdBaselineOFF = std(frsOFF(1:endbaseline,exc_inds),[],1);
        meanResponsesOFF = mean(frsOFF(endbaseline:endstim,exc_inds),1);
        %zOFF = (meanResponsesOFF - meanBaselineOFF)./stdBaselineOFF;
        XOFF(count,:) = meanResponsesOFF;
        meanFROFF(i,j,:) = meanResponsesOFF;
        %zResponsesOFF(i,j,:) = zOFF;
        odors(count) = i;
        count = count+1;
    end
    disp(['Done with odor ' num2str(i)])
end

accuracyON = knn_prediction(XON,classes,100);
accuracyOFF = knn_prediction(XOFF,classes,100);
accuracyONOFF = knn_cross_comparison(XON,XOFF,classes);
accuracyOFFON = knn_cross_comparison(XOFF,XON,classes);


realData = load('~/phd/stfp/abc_code/GCxData.txt');
realFRON = realData(:,2);
realFROFF = realData(:,3);
realOdorResponsive = realData(:,4);
realLightResponsive = realData(:,5);
realFRdif = realFRON - realFROFF;

realFRONcdf = getFRcdf(realFRON,0,500);
realFROFFcdf = getFRcdf(realFROFF,0,500);
realFRdifCDF = getFRcdf(realFRdif,-500,500);
for i=1:simParams.nOdors
    fakeMeanFRON = mean(squeeze(meanFRON(i,:,:)),1);
    fakeMeanFROFF = mean(squeeze(meanFROFF(i,:,:)),1);
    fakeMeanFRdif = fakeMeanFRON - fakeMeanFROFF;
    
    fakeMeanFRcdfON = getFRcdf(fakeMeanFRON,0,500);
    fakeMeanFRcdfOFF = getFRcdf(fakeMeanFROFF,0,500);
    fakeMeanFRdifCDF = getFRcdf(fakeMeanFRdif,-500,500);
    
    
    wdON(i) = shifted_sigmoid(1,1,3,0,2,wasserstein_1d(realFRONcdf,fakeMeanFRcdfON));
    wdOFF(i) = shifted_sigmoid(1,1,3,0,2,wasserstein_1d(realFROFFcdf,fakeMeanFRcdfOFF));
    wdONOFF(i) = shifted_sigmoid(1,1,3,0,2,wasserstein_1d(realFRdifCDF,fakeMeanFRdifCDF));
end

wdScoreON = mean(wdON);
wdScoreOFF = mean(wdOFF);
wdScoreONOFF = mean(wdONOFF);
accuracyONscore = (1 - mean(accuracyON));
accuracyOFFscore = (1 - mean(accuracyOFF));
accuracyONOFFscore = mean([accuracyONOFF accuracyOFFON]);

subscores = [wdScoreON wdScoreOFF wdScoreONOFF accuracyONscore accuracyOFFscore accuracyONOFFscore];
fprintf('Wasserstein Distance (ON): %1$f\n',wdScoreON)
fprintf('Wasserstein Distance (OFF): %1$f\n',wdScoreOFF)
fprintf('Wasserstein Distance (ONOFF): %1$f\n',wdScoreONOFF)
fprintf('Odor Discrimination (ON): %1$f\n',accuracyONscore)
fprintf('Odor Discrimination (OFF): %1$f\n',accuracyOFFscore)
fprintf('Odor Discrimination (ON/OFF): %1$f\n',accuracyONOFFscore)
score = sum(subscores.^2);
fprintf('Total score: %1$f\n',score)
save([datadir '/score.mat'],'score','-mat')
save([datadir '/subscores.mat'],'subscores','-mat')
end

