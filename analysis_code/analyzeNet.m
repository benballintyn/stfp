function [] = analyzeNet(datadir)
net = load([datadir '/net.mat']); net=net.net;
netParams = load([datadir '/netParams.mat']); netParams=netParams.netParams;
simParams = load([datadir '/simParams.mat']); simParams=simParams.simParams;
exc_inds = net.groupInfo(1).start_ind:net.groupInfo(1).end_ind;
inh_inds = net.groupInfo(2).start_ind:net.groupInfo(2).end_ind;
% Parameters for creating firing rates
window = .1/simParams.dt; % 100ms
downsampleFactor = 10;

zResponsesON = zeros(simParams.nOdors,simParams.nTrials,length(exc_inds));
zResponsesOFF = zeros(simParams.nOdors,simParams.nTrials,length(exc_inds));
count = 1;
odors = zeros(simParams.nOdors*simParams.nTrials,1);
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
        
        meanBaselineON_E = mean(frsON(1:endbaseline,exc_inds),1);
        meanBaselineON_I = mean(frsON(1:endbaseline,inh_inds),1);
        stdBaselineON_E = std(frsON(1:endbaseline,exc_inds),[],1);
        stdBaselineON_I = std(frsON(1:endbaseline,inh_inds),[],1);
        meanResponsesON_E = mean(frsON(endbaseline:endstim,exc_inds),1);
        meanResponsesON_I = mean(frsON(endbaseline:endstim,inh_inds),1);
        zON_E = (meanResponsesON_E - meanBaselineON_E)./stdBaselineON_E;
        zON_I = (meanResponsesON_I - meanBaselineON_I)./stdBaselineON_I;
        XON(count,:) = meanResponsesON_E;
        classes(count) = i;
        meanFRON_E(i,j,:) = meanResponsesON_E;
        meanFRON_I(i,j,:) = meanResponsesON_I;
        zResponsesON_E(i,j,:) = zON_E;
        zResponsesON_I(i,j,:) = zON_I;
        
        % Get Z-scored responses in the GC OFF condition
        spikesPreOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCOFF.bin'],simParams.cells2record);
        
        spikesPostOFF = readSpikes([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCOFF.bin'],simParams.cells2record);
        
        spikesStimOFF(:,1) = spikesStimOFF(:,1) + simParams.baseline_duration;
        spikesPostOFF(:,1) = spikesPostOFF(:,1) + simParams.baseline_duration + simParams.stim_duration;
        
        allspksOFF = [spikesPreOFF; spikesStimOFF; spikesPostOFF];
        frsOFF = getFiringRates(allspksOFF,length(simParams.cells2record),totalDuration,simParams.dt,downsampleFactor,window);
        allFrsOFF(j,:,:) = frsOFF;
        
        meanBaselineOFF_E = mean(frsOFF(1:endbaseline,exc_inds),1);
        meanBaselineOFF_I = mean(frsOFF(1:endbaseline,inh_inds),1);
        stdBaselineOFF_E = std(frsOFF(1:endbaseline,exc_inds),[],1);
        stdBaselineOFF_I = std(frsOFF(1:endbaseline,inh_inds),[],1);
        meanResponsesOFF_E = mean(frsOFF(endbaseline:endstim,exc_inds),1);
        meanResponsesOFF_I = mean(frsOFF(endbaseline:endstim,inh_inds),1);
        zOFF_E = (meanResponsesOFF_E - meanBaselineOFF_E)./stdBaselineOFF_E;
        zOFF_I = (meanResponsesOFF_I - meanBaselineOFF_I)./stdBaselineOFF_I;
        XOFF(count,:) = meanResponsesOFF_E;
        meanFROFF_E(i,j,:) = meanResponsesOFF_E;
        meanFROFF_I(i,j,:) = meanResponsesOFF_I;
        zResponsesOFF_E(i,j,:) = zOFF_E;
        zResponsesOFF_I(i,j,:) = zOFF_I;
        odors(count) = i;
        count = count+1;
    end
    psthsON(i,:,:) = squeeze(mean(allFrsON,1));
    psthsOFF(i,:,:) = squeeze(mean(allFrsOFF,1));
    disp(['Done with odor ' num2str(i)])
end
save([datadir '/psthsON.mat'],'psthsON','-mat')
save([datadir '/psthsOFF.mat'],'psthsOFF','-mat')

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
    fakeMeanFRON = mean(squeeze(meanFRON_E(i,:,:)),1);
    fakeMeanFROFF = mean(squeeze(meanFROFF_E(i,:,:)),1);
    fakeMeanFRdif = fakeMeanFRON - fakeMeanFROFF;
    
    fakeMeanFRcdfON = getFRcdf(fakeMeanFRON,0,500);
    fakeMeanFRcdfOFF = getFRcdf(fakeMeanFROFF,0,500);
    fakeMeanFRdifCDF = getFRcdf(fakeMeanFRdif,-500,500);
    
    
    wdON(i) = shifted_sigmoid(1,1,.6,0,10,wasserstein_1d(realFRONcdf,fakeMeanFRcdfON));
    wdOFF(i) = shifted_sigmoid(1,1,.6,0,10,wasserstein_1d(realFROFFcdf,fakeMeanFRcdfOFF));
    wdONOFF(i) = shifted_sigmoid(1,1,.6,0,10,wasserstein_1d(realFRdifCDF,fakeMeanFRdifCDF));
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

% Plot PSTHs for excitatory and inhibitory cells
figure;
subplot(2,2,1); plot(squeeze(psthsON(1,:,exc_inds))); title('ON: excitatory')
subplot(2,2,2); plot(squeeze(psthsON(1,:,inh_inds))); title('ON: inhibitory')
subplot(2,2,3); plot(squeeze(psthsOFF(1,:,exc_inds))); title('OFF: excitatory');
subplot(2,2,4); plot(squeeze(psthsOFF(1,:,inh_inds))); title('OFF: inhibitory');
set(gcf,'Position',[10 10 1500 1200])

% Plot PSTHs as colormap
figure;
subplot(2,2,1); imagesc(squeeze(psthsON(1,:,exc_inds))'); title('ON: excitatory')
subplot(2,2,2); imagesc(squeeze(psthsON(1,:,inh_inds))'); title('ON: inhibitory')
subplot(2,2,3); imagesc(squeeze(psthsOFF(1,:,exc_inds))'); title('OFF: excitatory');
subplot(2,2,4); imagesc(squeeze(psthsOFF(1,:,inh_inds))'); title('OFF: inhibitory');

% Use PCA to plot ON/OFF clusters for each odor
[COEFF_ON, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(XON);
[COEFF_OFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(XOFF);
cmap = jet;
figure;
scatter3(XON*COEFF_ON(:,1),XON*COEFF_ON(:,2),XON*COEFF_ON(:,3),20,cmap(odors*50,:),'o','filled')
hold on;
scatter3(XOFF*COEFF_OFF(:,1),XOFF*COEFF_OFF(:,2),XOFF*COEFF_OFF(:,3),20,cmap(odors*50,:),'s','filled')

% Plot firing rate histograms
mON_E = squeeze(mean(meanFRON_E,2));
mOFF_E = squeeze(mean(meanFROFF_E,2));
mON_I = squeeze(mean(meanFRON_I,2));
mOFF_I = squeeze(mean(meanFROFF_I,2));
figure;
subplot(2,2,1); histogram(mON_E); xlabel('Firing rate (Hz)')
subplot(2,2,2); histogram(mOFF_E); xlabel('Firing rate (Hz)')
subplot(2,2,[3 4]); histogram(mON_E - mOFF_E); xlabel('\Delta FR (ON - OFF)')
suptitle('Excitatory')
set(gcf,'Position',[10 10 1500 1200])

figure;
subplot(2,2,1); histogram(mON_I); xlabel('Firing rate (Hz)')
subplot(2,2,2); histogram(mOFF_I); xlabel('Firing rate (Hz)')
subplot(2,2,[3 4]); histogram(mON_I - mOFF_I); xlabel('\Delta FR (ON - OFF)')
suptitle('Inhibitory')
set(gcf,'Position',[10 10 1500 1200])
end

