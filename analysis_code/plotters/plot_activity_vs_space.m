function [] = plot_activity_vs_space(datadir)
p=load([datadir '/p.mat']); p=p.p;
on=load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
off=load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
onb=load([datadir '/on_baselines_spikes.mat']); onb=onb.on_baselines;
offb=load([datadir '/off_baselines_spikes.mat']); offb=offb.off_baselines;
maxX=100;
maxY=100;
x=p.xcoordsE;
baseactivityON=cell(1,10);
baseactivityOFF=cell(1,10);
stimactivityON=cell(1,10);
stimactivityOFF=cell(1,10);
activityDifON=cell(1,10);
activityDifOFF=cell(1,10);
lbinedges=[0 10 20 30 40 50 60 70 80 90];
rbinedges=[10 20 30 40 50 60 70 80 90 100];
nsmells=p.nsmells;
ntrials=p.ntrials;
for i=1:nsmells
    for j=1:ntrials
        for k = 1:length(lbinedges)
            cells=find(x >= lbinedges(k) & x < rbinedges(k));
            bspksON = onb{1}{i}{j}(cells);
            bspksOFF = offb{1}{i}{j}(cells);
            rspksON = on{1}{i}{j}(cells);
            rspksOFF = off{1}{i}{j}(cells);
            spkDifON = rspksON - bspksON;
            spkDifOFF = rspksOFF - bspksOFF;
            baseactivityON{k} = [baseactivityON{k} bspksON];
            baseactivityOFF{k} = [baseactivityOFF{k} bspksOFF];
            stimactivityON{k} = [stimactivityON{k} rspksON];
            stimactivityOFF{k} = [stimactivityOFF{k} rspksOFF];
            activityDifON{k} = [activityDifON{k} spkDifON];
            activityDifOFF{k} = [activityDifOFF{k} spkDifOFF];
        end
    end
end
for i=1:length(lbinedges)
    meanBaseActivityON(i) = mean(baseactivityON{i});
    stdBaseActivityON(i) = std(baseactivityON{i})/sqrt(length(baseactivityON{i}));
    meanBaseActivityOFF(i) = mean(baseactivityOFF{i});
    stdBaseActivityOFF(i) = std(baseactivityOFF{i})/sqrt(length(baseactivityOFF{i}));
    meanStimActivityON(i) = mean(stimactivityON{i});
    stdStimActivityON(i) = std(stimactivityON{i})/sqrt(length(stimactivityON{i}));
    meanStimActivityOFF(i) = mean(stimactivityOFF{i});
    stdStimActivityOFF(i) = std(stimactivityOFF{i})/sqrt(length(stimactivityOFF{i}));
    meanActivityDifON(i) = mean(activityDifON{i});
    stdActivityDifON(i) = std(activityDifON{i})/sqrt(length(activityDifON{i}));
    meanActivityDifOFF(i) = mean(activityDifOFF{i});
    stdActivityDifOFF(i) = std(activityDifOFF{i})/sqrt(length(activityDifOFF{i}));
end
figure; hold on
shadedErrorBar(1:10,meanActivityDifON,stdActivityDifON)
shadedErrorBar(1:10,meanActivityDifOFF,stdActivityDifOFF)
legend({'','GC ON','','GC OFF'})
xlabel('Binned X-coordinate')
ylabel('Response - baseline spike count')
title('Response - baseline');

figure; hold on
shadedErrorBar(1:10,meanBaseActivityON,stdBaseActivityON,'lineprops','r')
shadedErrorBar(1:10,meanBaseActivityOFF,stdBaseActivityOFF,'lineprops','b')
legend({'GC ON','GC OFF'})
xlabel('Binned X-coordinate')
ylabel('Baseline spike count')
title('Baseline');

figure; hold on
shadedErrorBar(1:10,meanStimActivityON,stdStimActivityON)
shadedErrorBar(1:10,meanStimActivityOFF,stdStimActivityOFF)
legend({'GC ON','GC OFF'})
xlabel('Binned X-coordinate')
ylabel('Stimulus spike count')
title('Stimulus');
end

