function [vON,vOFF,FON,FOFF] = plot_activity_locations(datadir)
p=load([datadir '/p.mat']); p=p.p;
%{
on=load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
off=load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
onb=load([datadir '/on_baselines_spikes.mat']); onb=onb.on_baselines;
offb=load([datadir '/off_baselines_spikes.mat']); offb=offb.off_baselines;
%}
psthsON = load([datadir '/frPSTHsON.mat']); psthsON=psthsON.frPSTHsON;
psthsOFF = load([datadir '/frPSTHsOFF.mat']); psthsOFF=psthsOFF.frPSTHsOFF;
for i=1:p.ntrials
    %{
    bsON(:,i) = onb{1}{1}{i};
    bsOFF(:,i) = offb{1}{1}{i};
    rsON(:,i) = on{1}{1}{i};
    rsOFF(:,i) = off{1}{1}{i};
    %}
end
%{
meanBON = mean(bsON,2);
meanBOFF = mean(bsOFF,2);
meanRsON = mean(rsON,2);
meanRsOFF = mean(rsOFF,2);
meanDiffsON = meanRsON - meanBON;
meanDiffsOFF = meanRsOFF - meanBOFF;
%}
meanDiffsON = mean(psthsON{1}{1}(100:200,:),1) - mean(psthsON{1}{1}(1:100,:),1);
meanDiffsOFF = mean(psthsOFF{1}{1}(100:200,:),1) - mean(psthsOFF{1}{1}(1:100,:),1);
xcoords=p.xcoordsE;
ycoords=p.ycoordsE;
figure; scatter(xcoords,ycoords)
FON=scatteredInterpolant([xcoords' ycoords'],meanDiffsON');
FOFF=scatteredInterpolant([xcoords' ycoords'],meanDiffsOFF');
x=0:.1:100;
y=0:.1:100;
[Xq,Yq] = meshgrid(x,y);
vON=FON(Xq,Yq);
vOFF=FOFF(Xq,Yq);

figure;
subplot(1,2,1)
imagesc(vON); set(gca,'ydir','normal'); colormap(jet); colorbar();
xlabel('X coordinate')
ylabel('Y coordinate')
set(gca,'xtick',1:100:1001,'xticklabels',0:10:100,'ytick',1:100:1001,'yticklabels',0:10:100)
subplot(1,2,2)
imagesc(vOFF); set(gca,'ydir','normal'); colorbar();
xlabel('X coordinate')
ylabel('Y coordinate')
set(gca,'xtick',1:100:1001,'xticklabels',0:10:100,'ytick',1:100:1001,'yticklabels',0:10:100)
set(gcf,'Position',[10 10 1600 600])
end


