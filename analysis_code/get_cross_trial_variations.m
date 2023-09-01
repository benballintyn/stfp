function [meanCoeffsON,meanCoeffsOFF] = get_cross_trial_variations(datadir)
p=load([datadir '/p.mat']); p=p.p;
on=load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
off=load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
onR=load([datadir '/on_responsive_spikes.mat']); onR=onR.on_responsive;
offR=load([datadir '/off_responsive_spikes.mat']); offR=offR.off_responsive;
onB=load([datadir '/on_baselines_spikes.mat']); onB=onB.on_baselines;
offB=load([datadir '/off_baselines_spikes.mat']); offB=offB.off_baselines;

ngroups=length(on);
nsmells=p.nsmells;
ntrials=p.ntrials;
for i=1:ngroups
    for j=1:nsmells
        if (isempty(onR{i}{j}))
            coeffsON(j)=0;
        else
            nSpkDifsON=zeros(length(onR{i}{j}),ntrials);
            for k=1:ntrials
                nSpkDifsON(:,k) = on{i}{j}{k}(onR{i}{j}) - onB{i}{j}{k}(onR{i}{j});
            end
            coeffVarON = std(nSpkDifsON,[],2)./mean(nSpkDifsON,2);
            coeffsON(j) = mean(coeffVarON);
        end
        if (isempty(offR{i}{j}))
            coeffsOFF(j)=0;
        else
            nSpkDifsOFF=zeros(length(offR{i}{j}),ntrials);
            for k=1:ntrials
                nSpkDifsOFF(:,k) = off{i}{j}{k}(offR{i}{j}) - offB{i}{j}{k}(offR{i}{j});
            end
            coeffVarOFF = std(nSpkDifsOFF,[],2)./mean(nSpkDifsOFF,2);
            coeffsOFF(j) = mean(coeffVarOFF);
        end
        clear nSpkDifsON nSpkDifsOFF coeffVarON coeffVarOFF
    end
    meanCoeffsON(i) = mean(coeffsON);
    meanCoeffsOFF(i) = mean(coeffsOFF);
end
end

