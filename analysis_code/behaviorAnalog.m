function [p1,p2,p3] = behaviorAnalog(nOdors,frsON,frsOFF,thresh,doplot)

count=0;
for i=1:nOdors
    undems = setdiff(1:nOdors,i);
    for j=undems
        count=count+1;
        odors2use(count,:) = [i j];
    end
end

for i=1:nOdors
    meanFRON(i,:)  = mean(squeeze(frsON(i,:,:)),1);
    meanFROFF(i,:) = mean(squeeze(frsOFF(i,:,:)),1);
    taggedON(i,:)  = meanFRON(i,:) > thresh;
    taggedOFF(i,:) = meanFROFF(i,:) > thresh;
end

for i=1:size(odors2use,1)
    demONdemONcorr     = corr(taggedON(odors2use(i,1),:)',taggedON(odors2use(i,1),:)');
    demONdemOFFcorr    = corr(taggedON(odors2use(i,1),:)',taggedOFF(odors2use(i,1),:)');
    demONundemONcorr   = corr(taggedON(odors2use(i,1),:)',taggedON(odors2use(i,2),:)');
    demONundemOFFcorr  = corr(taggedON(odors2use(i,1),:)',taggedOFF(odors2use(i,2),:)');
    demOFFdemONcorr    = corr(taggedOFF(odors2use(i,1),:)',taggedON(odors2use(i,1),:)');
    demOFFdemOFFcorr   = corr(taggedOFF(odors2use(i,1),:)',taggedOFF(odors2use(i,1),:)');
    demOFFundemONcorr  = corr(taggedOFF(odors2use(i,1),:)',taggedON(odors2use(i,2),:)');
    demOFFundemOFFcorr = corr(taggedOFF(odors2use(i,1),:)',taggedOFF(odors2use(i,2),:)');
    
    % General
    alpha=.6/(demONdemONcorr - demONundemONcorr);
    if (isinf(alpha))
        alpha = double(intmax);
    end
    
    % ON --> ON
    y = demONdemONcorr - demONundemONcorr;
    undemEatenONONcorr(i) = (1 - alpha*y)/2;
    demEatenONONcorr(i) = 1 - undemEatenONONcorr(i);
    if (undemEatenONONcorr(i) > 1)
        undemEatenONONcorr(i) = 1;
        demEatenONONcorr(i) = 0;
    elseif (undemEatenONONcorr(i) < 0)
        undemEatenONONcorr(i) = 0;
        demEatenONONcorr(i) = 1;
    end
    
    % ON --> OFF
    y = demONdemOFFcorr - demONundemOFFcorr;
    undemEatenONOFFcorr(i) = (1 - alpha*y)/2;
    demEatenONOFFcorr(i) = 1 - undemEatenONOFFcorr(i);
    if (undemEatenONOFFcorr(i) > 1)
        undemEatenONOFFcorr(i) = 1;
        demEatenONOFFcorr(i) = 0;
    elseif (undemEatenONOFFcorr(i) < 0)
        undemEatenONOFFcorr(i) = 0;
        demEatenONOFFcorr(i) = 1;
    end
    
    % OFF --> ON
    y = demOFFdemONcorr - demOFFundemONcorr;
    undemEatenOFFONcorr(i) = (1 - alpha*y)/2;
    demEatenOFFONcorr(i) = 1 - undemEatenOFFONcorr(i);
    if (undemEatenOFFONcorr(i) > 1)
        undemEatenOFFONcorr(i) = 1;
        demEatenOFFONcorr(i) = 0;
    elseif (undemEatenOFFONcorr(i) < 0)
        undemEatenOFFONcorr(i) = 0;
        demEatenOFFONcorr(i) = 1;
    end
    
    % OFF --> OFF
    y = demOFFdemOFFcorr - demOFFundemOFFcorr;
    undemEatenOFFOFFcorr(i) = (1 - alpha*y)/2;
    demEatenOFFOFFcorr(i) = 1 - undemEatenOFFOFFcorr(i);
    if (undemEatenOFFOFFcorr(i) > 1)
        undemEatenOFFOFFcorr(i) = 1;
        demEatenOFFOFFcorr(i) = 0;
    elseif (undemEatenOFFOFFcorr(i) < 0)
        undemEatenOFFOFFcorr(i) = 0;
        demEatenOFFOFFcorr(i) = 1;
    end
end

demEatenONONmean     = mean(demEatenONONcorr);
demEatenONONstd      = std(demEatenONONcorr);
undemEatenONONmean   = mean(undemEatenONONcorr);
undemEatenONONstd    = std(undemEatenONONcorr);

demEatenONOFFmean    = mean(demEatenONOFFcorr);
demEatenONOFFstd     = std(demEatenONOFFcorr);
undemEatenONOFFmean  = mean(undemEatenONOFFcorr);
undemEatenONOFFstd   = std(undemEatenONOFFcorr);

demEatenOFFONmean    = mean(demEatenOFFONcorr);
demEatenOFFONstd     = std(demEatenOFFONcorr);
undemEatenOFFONmean  = mean(undemEatenOFFONcorr);
undemEatenOFFONstd   = std(undemEatenOFFONcorr);

demEatenOFFOFFmean   = mean(demEatenOFFOFFcorr);
demEatenOFFOFFstd    = std(demEatenOFFOFFcorr);
undemEatenOFFOFFmean = mean(undemEatenOFFOFFcorr);
undemEatenOFFOFFstd  = std(undemEatenOFFOFFcorr);

[h1,p1]=ttest2(demEatenONOFFcorr,undemEatenONOFFcorr);
[h2,p2]=ttest2(demEatenOFFONcorr,undemEatenOFFONcorr);
[h3,p3]=ttest2(demEatenOFFOFFcorr,undemEatenOFFOFFcorr,'tail','right');
switch doplot
    case 'yes'
        % PLOTTING
        x = [1 2 3 4];
        y = [demEatenONONmean undemEatenONONmean; ...
             demEatenONOFFmean undemEatenONOFFmean; ...
             demEatenOFFONmean undemEatenOFFONmean; ...
             demEatenOFFOFFmean undemEatenOFFOFFmean];

        stds = [demEatenONONstd undemEatenONONstd ...
                demEatenONOFFstd undemEatenONOFFstd ...
                demEatenOFFONstd undemEatenOFFONstd ...
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
        ylim([0 1])
        title(['p(ONOFF): ' num2str(p1) ' p(OFFON): ' num2str(p2) ' p(OFFOFF): ' num2str(p3)])
end

