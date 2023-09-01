function [] = plot_net_results(datadir,saveStr,responseType)
if (~strcmp(saveStr,'') && ~exist(saveStr,'dir'))
    mkdir(saveStr)
end
p = load([datadir '/p.mat']); p=p.p;
ngroups=p.ngroups;
nsmells=p.nsmells;
ntrials=p.ntrials;
group_names = get_group_names(datadir);
ncells = get_ncells(p,group_names);

frsON = load([datadir '/frsON.mat']); frsON=frsON.frsON;
frsOFF = load([datadir '/frsOFF.mat']); frsOFF=frsOFF.frsOFF;
psthsON = load([datadir '/psthsON.mat']); psthsON=psthsON.psthsON;
psthsOFF = load([datadir '/psthsOFF.mat']); psthsOFF=psthsOFF.psthsOFF;
switch responseType
    case 'spikes'
        on_responsive = load([datadir '/on_responsive_spikes.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive = load([datadir '/off_responsive_spikes.mat']); off_responsive=off_responsive.off_responsive;
        on_responses = load([datadir '/on_responses_spikes.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses_spikes.mat']); off_responses=off_responses.off_responses;
    case 'firing rates'
        on_responsive = load([datadir '/on_responsive.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive = load([datadir '/off_responsive.mat']); off_responsive=off_responsive.off_responsive;
        on_responses = load([datadir '/on_responses.mat']); on_responses=on_responses.on_responses;
        off_responses = load([datadir '/off_responses.mat']); off_responses=off_responses.off_responses;
end

%% print score summary
[score] = get_objective_score(datadir,'knn',1,10,responseType);

%{
%% plot the weight matrix
W = get_formatted_weight_matrix(datadir);
figure;
imagesc(W)
xlabel('Cell ID')
ylabel('Cell ID')
if (~strcmp(saveStr,''))
    saveas(gcf,[saveStr '/weightMatrix'],'fig')
    print([saveStr '/weightMatrix'],'-dtiffn','-r300')
end

%% Plotting PSTHs of 2 cells on which is responsive during ON and one which is responsive during OFF
%{
on_but_not_off = setdiff(on_responsive{1}{1},off_responsive{1}{1});
off_but_not_on = setdiff(off_responsive{1}{1},on_responsive{1}{1});
if (isempty(on_but_not_off))
else
    maxy1 = max(max(max(psthsON{1}{1}(on_but_not_off,:))),max(max(psthsOFF{1}{1}(on_but_not_off,:))));
    maxy2 = max(max(max(psthsON{1}{1}(off_but_not_on,:))),max(max(psthsOFF{1}{1}(off_but_not_on,:))));
    figure;
    subplot(2,2,1)
    plot(psthsON{1}{1}(on_but_not_off,:)','LineWidth',2); ylim([0 maxy1])
    subplot(2,2,2);
    plot(psthsOFF{1}{1}(on_but_not_off,:)','LineWidth',2); ylim([0 maxy1])
    subplot(2,2,3)
    plot(psthsON{1}{1}(off_but_not_on,:)','LineWidth',2); ylim([0 maxy2])
    subplot(2,2,4)
    plot(psthsOFF{1}{1}(off_but_not_on,:)','LineWidth',2); ylim([0 maxy2])
    set(gcf,'Position',[10 10 1200 500])
    drawnow;
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/psths'],'fig')
        print([saveStr '/psths'],'-dtiffn','-r300')
    end
end

%% Plotting firing rates of on and off responsive cells
if isempty(on_responsive{1}{1})
else
    figure;
    subplot(2,2,1)
    maxy = max(max(max(frsON{1}{1}{1}(:,on_responsive{1}{1}))),max(max(frsOFF{1}{1}{1}(:,on_responsive{1}{1}))));
    plot(frsON{1}{1}{1}(:,on_responsive{1}{1}),'LineWidth',2); ylim([0 maxy])
    subplot(2,2,2)
    plot(frsOFF{1}{1}{1}(:,on_responsive{1}{1}),'LineWidth',2); ylim([0 maxy])
    subplot(2,2,3)
    maxy = max(max(max(frsON{1}{1}{1}(:,off_responsive{1}{1}))),max(max(frsOFF{1}{1}{1}(:,off_responsive{1}{1}))));
    plot(frsON{1}{1}{1}(:,off_responsive{1}{1}),'LineWidth',2); ylim([0 maxy])
    subplot(2,2,4)
    plot(frsOFF{1}{1}{1}(:,off_responsive{1}{1}),'LineWidth',2); ylim([0 maxy])
    set(gcf,'Position',[10 10 1200 500])
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/on_off_responsive_frs'],'fig')
        print([saveStr '/on_off_responsive_frs'],'-dtiffn','-r300')
    end
end

%% Plotting firing rates of on and off responsive cells
figure;
subplot(2,2,1)
maxy = max(max(max(frsON{1}{1}{1})),max(max(frsOFF{1}{1}{1})));
plot(frsON{1}{1}{1},'LineWidth',2); ylim([0 maxy]); title('E ON')
subplot(2,2,2)
plot(frsOFF{1}{1}{1},'LineWidth',2); ylim([0 maxy]); title('E OFF')
subplot(2,2,3)
maxy = max(max(max(frsON{2}{1}{1})),max(max(frsOFF{2}{1}{1}))); 
plot(frsON{2}{1}{1},'LineWidth',2); ylim([0 maxy]); title('I ON')
subplot(2,2,4)
plot(frsOFF{2}{1}{1},'LineWidth',2); ylim([0 maxy]); title('I OFF')
set(gcf,'Position',[10 10 1200 500])
if (~strcmp(saveStr,''))
    saveas(gcf,[saveStr '/allFRs'],'fig')
    print([saveStr '/allFRs'],'-dtiffn','-r300')
end
%}
%}
plot_all_on_off_frPSTHS(datadir,'all',responseType);
plot_all_on_off_frPSTHS(datadir,'on responsive',responseType)
plot_all_on_off_frPSTHS(datadir,'off responsive',responseType)
%{
%% Do some PCA and plot ON vs. OFF
xtr = load([datadir '/x_train.mat']); xtr=xtr.x_train;
xtst = load([datadir '/x_test.mat']); xtst=xtst.x_test;
for i=1:length(xtr)
    X = [xtr{i}; xtst{i}];
    [COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(X);
    xcoords = X*COEFF(:,1);
    ycoords = X*COEFF(:,2);
    zcoords = X*COEFF(:,3);
    cmap = jet;
    n=2*nsmells*ntrials;
    stim_IDs = load([datadir '/stim_IDs.mat']); stim_IDs=stim_IDs.stim_IDs;
    figure;
    scatter3(xcoords(1:n/2),ycoords(1:n/2),zcoords(1:n/2),50,cmap(stim_IDs*floor(64/nsmells),:),'filled')
    hold on;
    scatter3(xcoords(n/2+1:n),ycoords(n/2+1:n),zcoords(n/2+1:n),50,cmap(stim_IDs*floor(64/nsmells),:),'x')
    xlabel('PC 1'); ylabel('PC 2'); zlabel('PC 3')
    title(['' group_names{i} '  EXPLAINED = ' num2str(sum(EXPLAINED(1:3)))])
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/pca_plot' group_names{i}],'fig')
        print([saveStr '/pca_plot' group_names{i}],'-dtiffn','-r300')
    end
end
%}

%% Compare firing rates for each group
for i=1:ngroups
    for j=1:nsmells
        for k=1:ncells(i)
            for l=1:ntrials
                meanRon(l) = on_responses{i}{j}{l}(k);
                meanRoff(l) = off_responses{i}{j}{l}(k);
            end
            meanRsON(j,k) = mean(meanRon);
            meanRsOFF(j,k) = mean(meanRoff);
        end
    end
    %{
    C = [meanRsON(:) meanRsOFF(:)];
    g = [zeros(1,length(meanRsON(:))) ones(1,length(meanRsOFF(:)))];
    %[h,pval] = ttest2(meanRon,meanRoff);
    [pval,h] = ranksum(meanRsON(:),meanRsOFF(:));
    figure; 
    h2=boxplot(C,g); set(h2,'LineWidth',2);
    title(['Group ' num2str(i) ': ' group_names{i} ' pval = ' num2str(pval)]);
    set(gca,'XTickLabels',{'ON','OFF'})
    drawnow
    figure;
    histogram(meanRsOFF(:) - meanRsON(:)); xlabel('\Delta FR  (OFF - ON)')
    title(group_names{i})
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/deltaFrs' num2str(i)],'fig')
        print([saveStr '/deltaFrs' num2str(i)],'-dtiffn','-r300')
    end
    %}
    plot_meanRdifs((meanRsOFF(:)-meanRsON(:)),'\Delta FR (OFF - ON)',group_names{i})
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/meanRdifs' group_names{i}],'fig')
        print([saveStr '/meanRdifs' group_names{i}],'-dtiffn','-r300')
    end
    clear meanRon meanRoff meanRsON meanRsOFF count
end
%{
%% compare number of on/off responsive cells
for i=1:ngroups
    for j=1:nsmells
        nOnResponsive(i,j) = length(on_responsive{i}{j});
        nOffResponsive(i,j) = length(off_responsive{i}{j});
    end
    
    C = [nOnResponsive(i,:) nOffResponsive(i,:)];
    g = [zeros(1,nsmells) ones(1,nsmells)];
    [h,pval] = ttest2(nOnResponsive(i,:),nOffResponsive(i,:));
    figure;
    axBox{i} = gca;
    h2=boxplot(C,g); set(h2,'LineWidth',2);
    title(axBox{i},[group_names{i} ' on vs. off responsive   p = ' num2str(pval)])
    ylabel(axBox{i},'# of cells')
    set(axBox{i},'XTickLabels',{'ON','OFF'})
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/nOnOffResponses' group_names{i}],'fig')
        print([saveStr '/nOnOffResponses' group_names{i}],'-dtiffn','-r300')
    end
end
%}
%% plot images of representative firing rates
for i=1:ngroups
    maxFR = max(max(frsON{i}{1}{1}(:)),max(frsOFF{i}{1}{1}(:)));
    figure;
    subplot(1,2,1)
    imagesc(frsON{i}{1}{1}'); colormap(jet); colorbar(); caxis([0 maxFR])
    title([group_names{i} ': ON'])
    subplot(1,2,2)
    imagesc(frsOFF{i}{1}{1}'); colormap(jet); colorbar(); caxis([0 maxFR])
    title([group_names{i} ': OFF'])
    set(gcf,'Position',[10 10 1200 500])
    if (~strcmp(saveStr,''))
        saveas(gcf,[saveStr '/networkTrace' group_names{i}],'fig')
        print([saveStr '/networkTrace' group_names{i}],'-dtiffn','-r300')
    end
end
%% plot cell overlap box plots
nonDiagInds=~logical(eye(nsmells));
for i=1:nsmells
    nOnResponsive2(i) = length(on_responsive{1}{i});
    nOffResponsive2(i) = length(off_responsive{1}{i});
    for j=1:nsmells
        overlapsON(i,j) = length(intersect(on_responsive{1}{i},on_responsive{1}{j}));
        overlapsOFF(i,j) = length(intersect(off_responsive{1}{i},off_responsive{1}{j}));
        overlapsONOFF(i,j) = length(intersect(on_responsive{1}{i},off_responsive{1}{j}));
    end
    onoffoverlap(i)=length(intersect(on_responsive{1}{i},off_responsive{1}{i}));
end
violinData{1} = nOnResponsive2;
violinData{2} = nOffResponsive2;
violinData{3} = overlapsON(nonDiagInds);
violinData{4} = overlapsOFF(nonDiagInds);
violinData{5} = overlapsONOFF(nonDiagInds);
violinData{6} = onoffoverlap;
mean1=mean(violinData{1});
mean2=mean(violinData{2});
mean3=mean(violinData{3});
mean4=mean(violinData{4});
mean5=mean(violinData{5});
mean6=mean(violinData{6});
allMeans=[mean1 mean2 mean3 mean4 mean5 mean6];
lineXlow=(0:5) - .3;
lineXhigh=(0:5) + .3;

lineXs=[lineXlow' lineXhigh'];
lineYs=[allMeans' allMeans'];
xvals = [zeros(1,length(violinData{1})) ones(1,length(violinData{2})) ones(1,length(violinData{3}))*2 ones(1,length(violinData{4}))*3 ones(1,length(violinData{5}))*4 ones(1,length(violinData{6}))*5];
yvals = [violinData{1} violinData{2} violinData{3}' violinData{4}' violinData{5}' violinData{6}];
xtl1='\textbf{\begin{tabular}{c} N ON \\ responsive\end{tabular}}';
xtl2='\textbf{\begin{tabular}{c} N OFF \\ responsive\end{tabular}}';
xtl3='\textbf{\begin{tabular}{c} Odor pair ON \\ responsive\end{tabular}}';
xtl4='\textbf{\begin{tabular}{c} Odor pair OFF \\ responsive\end{tabular}}';
xtl5='\textbf{\begin{tabular}{c} Odor pair \\ ON \& OFF \\ responsive\end{tabular}}';
xtl6='\textbf{\begin{tabular}{c} ON \& OFF \\ responsive\end{tabular}}';
%xticklabels={'\textbf{N ON} \\  \textbf{responsive}','\textbf{N OFF responsive}','Multi-odor ON responsive','Multi-odor OFF responsive','ON \& OFF responsive'};
xticklabels={xtl1,xtl2,xtl3,xtl4,xtl5,xtl6};
figure;
violin(violinData,'xlabel',xticklabels,'facecolor','b')
%scatter(xvals,yvals,20,'k','filled')
xlim([0 7])
%{
hold on;
for i=1:6
    plot(lineXs(i,:)',lineYs(i,:)','r','linew',3)
end
%}
ylabel('# of neurons','fontsize',20,'fontweight','bold')
%violin(violinData,'facecolor','b')
set(gca,'TickLabelInterpreter','latex','xtick',1:6,'xticklabels',xticklabels,'xticklabelrotation',0)
set(gcf,'Position',[10 10 1400 800])
%{
figure;
axOverlap=gca;
C = [nOnResponsive2 nOffResponsive2 overlapsON(nonDiagInds)' overlapsOFF(nonDiagInds)' onoffoverlap];
g = [zeros(1,nsmells) ones(1,nsmells) ones(1,nsmells^2-nsmells)*2 ones(1,nsmells^2-nsmells)*3 ones(1,nsmells)*4];
h=boxplot(C,g); set(h,'LineWidth',3);
set(axOverlap,'XTickLabels',{'N on responsive','N off responsive','Cross Stim overlaps ON','Cross stim overlaps off', 'onoff overlaps'},'XTickLabelRotation',45)
ylabel(axOverlap,'# of Cells','fontsize',15,'fontweight','bold')
%xticklabels({'N on responsive','N off responsive','Cross Stim overlaps ON','Cross stim overlaps off', 'onoff overlaps'})
drawnow
%}
if (~strcmp(saveStr,''))
    saveas(gcf,[saveStr '/cellOverlaps'],'fig')
    print([saveStr '/cellOverlaps'],'-dtiffn','-r300')
end

%% get pseudo-behavior
[p1,p2,p3] = get_behavior_analog2(datadir,5,1,'linear','yes');
end

