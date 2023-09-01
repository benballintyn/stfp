function [score,sub_scores] = get_objective_score(datadir,scoreType,groups2score,desiredMeanResponse,responseType)
% score to minimize
p = load([datadir '/p.mat']); p=p.p;
switch scoreType
    case 'knn'
        aON = load([datadir '/accuracyON_knn.mat']); aON=aON.accuracyON_knn;
        aOFF = load([datadir '/accuracyOFF_knn.mat']); aOFF=aOFF.accuracyOFF_knn;
        aONOFF = load([datadir '/accuracyONOFF_knn.mat']); aONOFF=aONOFF.accuracyONOFF_knn;
    case 'bayes'
        aON = load([datadir '/accuracyON_bayes.mat']); aON=aON.accuracyON_bayes;
        aOFF = load([datadir '/accuracyOFF_bayes.mat']); aOFF=aOFF.accuracyOFF_bayes;
        aONOFF = load([datadir '/accuracyONOFF_bayes.mat']); aONOFF=aONOFF.accuracyONOFF_bayes;
end
switch responseType
    case 'spikes'
        on_responses = load([datadir '/on_responses_spikes.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses_spikes.mat']); off_responses=off_responses.off_responses;
        on_responsive=load([datadir '/on_responsive_spikes.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive=load([datadir '/off_responsive_spikes.mat']); off_responsive=off_responsive.off_responsive;
        on_baselines=load([datadir '/on_baselines_spikes.mat']); on_baselines=on_baselines.on_baselines;
        off_baselines=load([datadir '/off_baselines_spikes.mat']); off_baselines=off_baselines.off_baselines;
    case 'firing rates'
        on_responses = load([datadir '/on_responses.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses.mat']); off_responses=off_responses.off_responses;
        on_responsive=load([datadir '/on_responsive.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive=load([datadir '/off_responsive.mat']); off_responsive=off_responsive.off_responsive;
        on_baselines=load([datadir '/on_baselines.mat']); on_baselines=on_baselines.on_baselines;
        off_baselines=load([datadir '/off_baselines.mat']); off_baselines=off_baselines.off_baselines;
end

for i=1:length(groups2score)
    curGroup = groups2score(i);
    for j=1:p.nsmells
        for k=1:p.ntrials
            meanRatesON{i}(j,k) = mean(on_responses{curGroup}{j}{k});
            meanRatesOFF{i}(j,k) = mean(off_responses{curGroup}{j}{k});
            meanBaseON{i}(j,k) = mean(on_baselines{i}{j}{k});
            meanBaseOFF{i}(j,k) = mean(off_baselines{i}{j}{k});
        end
        meanRon_trialAv{curGroup}(j) = mean(meanRatesON{i}(j,:));
        meanRoff_trialAv{curGroup}(j) = mean(meanRatesOFF{i}(j,:));
        nONresponsive(curGroup,j) = length(on_responsive{curGroup}{j});
        nOFFresponsive(curGroup,j) = length(off_responsive{curGroup}{j});
    end
    meanNOnResponsive(curGroup) = length([on_responsive{curGroup}{:}])/p.nsmells;
    meanNOffResponsive(curGroup) = length([off_responsive{curGroup}{:}])/p.nsmells;
end
for i=setdiff(1:p.ngroups,groups2score)
    for j=1:p.nsmells
        for k=1:p.ntrials
            meanRatesON2{i}(j,k) = mean(on_responses{i}{j}{k});
            meanRatesOFF2{i}(j,k) = mean(off_responses{i}{j}{k});
        end
        meanRon2_trialAv{i}(j) = mean(meanRatesON2{i}(j,:));
        meanRoff2_trialAv{i}(j) = mean(meanRatesOFF2{i}(j,:));
    end
end

if (mean(meanNOnResponsive) + mean(meanNOffResponsive) < 10 )
    respDifScore = 1;
else
    respDifScore = abs((mean(meanNOnResponsive) - mean(meanNOffResponsive)))/((mean(meanNOnResponsive) + mean(meanNOffResponsive)));
end
%{
y=normpdf(0:1:p.nE,100,50); y=y/max(y);
if (ceil(meanNOnResponsive(groups2score)) == 0)
    respScoreON = 1;
else
    respScoreON = 1 - y(ceil(meanNOnResponsive(groups2score)));
end
if (ceil(meanNOffResponsive(groups2score)) == 0)
    respScoreOFF = 1;
else
    respScoreOFF = 1 - y(ceil(meanNOffResponsive(groups2score)));
end
%}
if (mean(mean(nONresponsive(groups2score,:),2)) == 0)
    respCVON = double(intmax);
else
    respCVON = mean(std(nONresponsive(groups2score,:),[],2))/mean(mean(nONresponsive(groups2score,:),2));
end
respVarScoreON = shifted_sigmoid(1,1,10,0,.15,respCVON);
if (mean(mean(nOFFresponsive(groups2score,:),2)) == 0)
    respCVOFF = double(intmax);
else
    respCVOFF = mean(std(nOFFresponsive(groups2score,:),[],2))/mean(mean(nOFFresponsive(groups2score,:),2));
end
respVarScoreOFF = shifted_sigmoid(1,1,10,0,.15,respCVOFF);
%meanRON = mean(meanRon_trialAv{groups2score}(:));
%meanROFF = mean(meanRoff_trialAv{groups2score}(:));
%scaledMeanRdif = (meanRON - meanROFF)/((meanRON + meanROFF)/2);
%meanRdifScore = abs(shifted_sigmoid(2,1,3,1,0,scaledMeanRdif));
meanRKLdiv = get_meanRdifScore((meanRon_trialAv{groups2score}(:))-(meanRoff_trialAv{groups2score}(:)));
meanRdifScore = shifted_sigmoid(1,1,4,0,1.5,meanRKLdiv);
meanBaseDif = mean(meanBaseOFF{groups2score}(:) - meanBaseON{groups2score}(:));
meanBaseDifScore = abs(shifted_sigmoid(2,1,2,1,0,meanBaseDif));
%maxMeanR = max(max(mean([meanRatesON(:)]),mean([meanRatesOFF(:)])),max(mean([meanRatesON2(:)]),mean([meanRatesOFF2(:)])));
%meanRScore = abs(shifted_sigmoid(2,1,.2,1,halfMaxFR,maxMeanR)); %shifted_sigmoid(1,1,1,0,halfMaxFR,maxMeanR);
meanRON = mean(meanRon_trialAv{groups2score}(:));
meanROFF = mean(meanRoff_trialAv{groups2score}(:));
meanRScoreON = abs(shifted_sigmoid(2,1,.3,1,desiredMeanResponse,meanRON));
meanRScoreOFF = abs(shifted_sigmoid(2,1,.3,1,desiredMeanResponse,meanROFF));

discrimination_score = (1 - aON) + (1 - aOFF) + aONOFF;

cell_overlap_score = get_cell_overlap_score(datadir,responseType);

[corrDif1,corrDif2,corrDif3,corrDif4,avgXcorr] = get_correlation_scores(datadir,1,responseType);

[meanCoeffsON,meanCoeffsOFF] = get_cross_trial_variations(datadir);
m=[meanCoeffsON meanCoeffsOFF];
cross_trial_variation_score = shifted_sigmoid(1,1,10,0,.2,max(m));
for i=1:10
    [p1,p2,p3] = get_behavior_analog2(datadir,i,groups2score,'linear','no');
    bs1(i) = 1 - p1;
    bs2(i) = 1 - p2;
    bs3(i) = p3;
end
meanBehaviorScore1 = mean(bs1);
meanBehaviorScore2 = mean(bs2);
meanBehaviorScore3 = mean(bs3);
%sub_scores = [responsiveness_score cell_overlap_score meanRdifScore meanRScore (1-aON) (1-aOFF) aONOFF];
sub_scores = [respDifScore meanRScoreON meanRScoreOFF meanRdifScore ...
              meanBaseDifScore corrDif1 corrDif2 corrDif3 cross_trial_variation_score ...
              respVarScoreON respVarScoreOFF meanBehaviorScore1 ...
              meanBehaviorScore2 meanBehaviorScore3];

score = sum(sub_scores.^4);
disp(['SCORE = ' num2str(score)])
disp(['Mean response score ON = ' num2str(meanRScoreON)])
disp(['Mean response score OFF = ' num2str(meanRScoreOFF)])
disp(['Mean baseline difference score = ' num2str(meanBaseDifScore)])
disp(['Mean response difference score = ' num2str(meanRdifScore)])
disp(['Correlation scores: ' num2str(corrDif1) '  ' num2str(corrDif2) '  ' num2str(corrDif3) '  ' num2str(corrDif4)])
%disp(['Cell overlap score = ' num2str(cell_overlap_score)])
disp(['RespDifScore = ' num2str(respDifScore)])
%disp(['respScoreON = ' num2str(respScoreON)])
%disp(['respScoreOFF = ' num2str(respScoreOFF)])
disp(['Cross-trial variability = ' num2str(cross_trial_variation_score)])
disp(['response variability ON = ' num2str(respVarScoreON)])
disp(['response variability OFF = ' num2str(respVarScoreOFF)])
disp(['Behavior Score 1 = ' num2str(meanBehaviorScore1)])
disp(['Behavior Score 2 = ' num2str(meanBehaviorScore2)])
disp(['Behavior Score 3 = ' num2str(meanBehaviorScore3)])
%disp(['ON discrimination score = ' num2str((1 - aON))]);
%disp(['OFF discrimination score = ' num2str((1 - aOFF))]);
%disp(['ONOFF discrimination score = ' num2str(aONOFF)])
switch responseType
    case 'spikes'
        save([datadir '/score_spikes.mat'],'score','-mat')
        save([datadir '/sub_scores_spikes.mat'],'sub_scores','-mat')
    case 'firing rates'
        save([datadir '/score_frs.mat'],'score','-mat')
        save([datadir '/sub_scores_frs.mat'],'sub_scores','-mat')
end
end

