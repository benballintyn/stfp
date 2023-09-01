function [mean_score1,mean_score2,mean_score3,mean_score4,avgXcorr] = get_correlation_scores(datadir,group2use,responseType)
p=load([datadir '/p.mat']); p=p.p;
nOdors=p.nsmells;
nTrials=p.ntrials;
switch responseType
    case 'spikes'
        xtr=load([datadir '/x_train_spikes.mat']); xtr=xtr.x_train;
        xtst=load([datadir '/x_test_spikes.mat']); xtst=xtst.x_test;
    case 'firing rates'
        xtr=load([datadir '/x_train_frs.mat']); xtr=xtr.x_train;
        xtst=load([datadir '/x_test_frs.mat']); xtst=xtst.x_test;
end

X = [xtr{group2use}; xtst{group2use}];
Xcorr=corr(X');
notEye=~eye(nTrials);

for i=1:2*nOdors
    for j=1:2*nOdors
        iInd1=(i-1)*nTrials + 1;
        iInd2=i*nTrials;
        jInd1=(j-1)*nTrials + 1;
        jInd2=j*nTrials;
        curSquare = Xcorr(iInd1:iInd2,jInd1:jInd2);
        avgXcorr(i,j) = mean(curSquare(notEye));
    end
end
%{
ON_ON_square = avgXcorr(1:nOdors,1:nOdors);
ON_OFF_square = avgXcorr(1:nOdors,(nOdors+1):2*nOdors);
OFF_ON_square = avgXcorr((nOdors+1):2*nOdors,1:nOdors);
OFF_OFF_square = avgXcorr((nOdors+1):2*nOdors,(nOdors+1):2*nOdors);
notEye = ~eye(nOdors);
ON_ON_score = mean(trace(ON_ON_square))/(mean(trace(ON_ON_square))+mean(ON_ON_square(notEye)));
ON_OFF_score = mean(trace(ON_OFF_square))/(mean(trace(ON_OFF_square))+mean(ON_OFF_square(notEye)));
OFF_ON_score = mean(trace(OFF_ON_square))/(mean(trace(OFF_ON_square))+mean(OFF_ON_square(notEye)));
OFF_OFF_score = mean(trace(OFF_OFF_square))/(mean(trace(OFF_OFF_square))+mean(OFF_OFF_square(notEye)));
ON_OFF_score = 1 - ON_OFF_score;
OFF_ON_score = 1 - OFF_ON_score;
%}
for i=1:nOdors
    onoff_corr = avgXcorr(i,i+nOdors);
    %{
    % A+GC:A-GC/<A+GC:B/E-GC>
    score1(i) = onoff_corr/mean(avgXcorr(i,setdiff((nOdors+1:2*nOdors),i+nOdors)));
    % A+GC:A-GC/<A-GC:B/E-GC>
    score2(i) = onoff_corr/mean(avgXcorr(i+nOdors,setdiff((nOdors+1:2*nOdors),i+nOdors)));
    % A+GC:A-GC/<A+GC:B/E+GC>
    score3(i) = onoff_corr/mean(avgXcorr(i,setdiff(1:nOdors,i)));
    % A+GC:A-GC/<A-GC:B/E-GC>
    score4(i) = onoff_corr/mean(avgXcorr(i+nOdors,setdiff((nOdors+1):2*nOdors,i+nOdors)));
    %}
    score1(i) = abs(onoff_corr - mean(avgXcorr(i,setdiff((nOdors+1:2*nOdors),i+nOdors))));
    score2(i) = abs(onoff_corr - mean(avgXcorr(i+nOdors,setdiff((nOdors+1:2*nOdors),i+nOdors))));
    score3(i) = abs(onoff_corr - mean(avgXcorr(i,setdiff(1:nOdors,i))));
    score4(i) = abs(onoff_corr - mean(avgXcorr(i+nOdors,setdiff(1:nOdors,i))));
end
%{
mean_score1=mean(score1);
mean_score2=mean(score2);
mean_score3=mean(score3);
mean_score4=mean(score4);
%}
mean_score1=mean(score1);
mean_score2=mean(score2);
mean_score3=mean(score3);
mean_score4=mean(score4);
if (isnan(mean_score1))
    mean_score1=1;
end
if (isnan(mean_score2))
    mean_score2=1;
end
if (isnan(mean_score3))
    mean_score3=1;
end
if (isnan(mean_score4))
    mean_score4=1;
end
end

