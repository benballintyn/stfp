function [demEatenONOFF,undemEatenONOFF,demEatenOFFON,undemEatenOFFON] = get_behavior_analog(datadir,thresh,group2use)
p=load([datadir '/p.mat']); p=p.p;
onR = load([datadir '/on_responses_spikes.mat']); onR=onR.on_responses;
offR = load([datadir '/off_responses_spikes.mat']); offR=offR.off_responses;
count=0;
for i=1:p.nsmells
    for j=i+1:p.nsmells
        count=count+1;
        odors2use(count,:) = [i j];
    end
end

for i=1:size(odors2use,1)
    for k = 1:2
        for j=1:p.ntrials
            rsON{k}(j,:) = onR{group2use}{odors2use(i,k)}{j};
            rsOFF{k}(j,:) = offR{group2use}{odors2use(i,k)}{j};
        end
        meanRsON{k} = mean(rsON{k},1);
        meanRsOFF{k} = mean(rsOFF{k},1);
    end
    demTaggedON = meanRsON{1} > thresh;
    demTaggedOFF = meanRsOFF{1} > thresh;
    undemTaggedON = meanRsON{2} > thresh;
    undemTaggedOFF = meanRsOFF{2} > thresh;
    
    demOFFcorr = corr(demTaggedON',demTaggedOFF');
    undemONcorr = corr(demTaggedON',undemTaggedON');
    undemOFFcorr = corr(demTaggedON',undemTaggedOFF');
    
    alpha=.6/(1 - undemONcorr);
    y=demOFFcorr - undemOFFcorr;
    undemEatenONOFF(i) = (1 - alpha*y)/2;
    demEatenONOFF(i) = 1 - undemEatenONOFF(i);
    
    alpha=.6/(1 - undemOFFcorr);
    undemOFFONcorr = corr(demTaggedOFF',undemTaggedON');
    y=demOFFcorr - undemOFFONcorr;
    undemEatenOFFON(i) = (1 - alpha*y)/2;
    demEatenOFFON(i) = 1 - undemEatenOFFON(i);
    
    undemOFFOFFcorr = corr(demTaggedOFF',undemTaggedOFF');
    y=1 - undemOFFOFFcorr;
    undemEatenOFFOFF(i) = (1 - alpha*y)/2;
    demEatenOFFOFF(i) = 1 - undemEatenOFFOFF(i);
end

undemEatenONOFFstd = std(undemEatenONOFF);
demEatenONOFFstd = std(demEatenONOFF);
undemEatenOFFONstd = std(undemEatenOFFON);
demEatenOFFONstd = std(demEatenOFFON);
undemEatenOFFOFFstd = std(undemEatenOFFOFF);
demEatenOFFOFFstd = std(demEatenOFFOFF);

x = [1 2 3 4 ];
y = [.8 .2; mean(demEatenONOFF) mean(undemEatenONOFF); ...
    mean(demEatenOFFON) mean(undemEatenOFFON); mean(demEatenOFFOFF) mean(undemEatenOFFOFF)];
stds = [0 0 demEatenONOFFstd undemEatenONOFFstd demEatenOFFONstd undemEatenOFFONstd ...
        demEatenOFFOFFstd undemEatenOFFOFFstd];
figure;
bar(x,y); hold on;
x2([1 3 5 7]) = x-.15;
x2([2 4 6 8]) = x+.15;
y2=[y(1,:) y(2,:) y(3,:) y(4,:)];
errorbar(x2,y2,stds,'LineStyle','none','color','k')
legend({'Demonstrated','Undemonstrated'},'location','northeast');
ylabel('Proportion food consumed','fontsize',15,'fontweight','bold')
xticklabels={'\textbf{Control}', ...
             '\textbf{\begin{tabular}{c} Train: GC ON \\ \ Test: GC OFF \end{tabular}}', ...
             '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC ON \end{tabular}}', ...
             '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC OFF \end{tabular}}'};
set(gca,'TickLabelInterpreter','latex','xticklabels',xticklabels)
set(gcf,'Position',[10 10 1500 1000])

%{
demTaggedON = meanRsON{1} >= thresh;
demTaggedOFF = meanRsOFF{1} >= thresh;
undemTaggedON = meanRsON{2} >= thresh;
undemTaggedOFF = meanRsOFF{2} >= thresh;

demOFFcorr = corr(meanRsON{1}(tagged)',meanRsOFF{1}(tagged)');
undemONcorr = corr(meanRsON{1}(tagged)',meanRsON{2}(tagged)');
undemOFFcorr = corr(meanRsON{1}(tagged)',meanRsOFF{2}(tagged)');

demOFFcorr = corr(demTaggedON',demTaggedOFF');
undemONcorr = corr(demTaggedON',undemTaggedON');
undemOFFcorr = corr(demTaggedON',undemTaggedOFF');
%}
end

