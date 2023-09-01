function [] = plot_gain_loss_of_response(datadir)
frPSTHsON=load([datadir '/frPSTHsON.mat']); frPSTHsON=frPSTHsON.frPSTHsON;
frPSTHsOFF=load([datadir '/frPSTHsOFF.mat']); frPSTHsOFF=frPSTHsOFF.frPSTHsOFF;
[on_pvals, off_pvals] = get_sorted_responses(datadir);
pvaldif = off_pvals{1}{1}-on_pvals{1}{1};
[sortdifs,sortPvalDifs] = sort(pvaldif,'descend');
sortPvalDifs=sortPvalDifs(~isnan(sortdifs));
sortdifs=sortdifs(~isnan(sortdifs));
p=load([datadir '/p.mat']); p=p.p;
tvec=p.dt:p.dt*p.FRdownsampleFactor:p.trial_time;
for i=1:length(sortdifs)
    figure;
    subplot(1,2,1); plot(tvec,frPSTHsON{1}{1}(:,sortPvalDifs(i)),'linew',2);
    hold on; plot(tvec,frPSTHsOFF{1}{1}(:,sortPvalDifs(i)),'linew',2);
    xlabel('Time (s)','fontsize',15,'fontweight','bold'); ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold'); legend({'GC ON','GC OFF'})
    subplot(1,2,2); plot(tvec,frPSTHsON{1}{1}(:,sortPvalDifs(end-(i-1))),'linew',2); 
    hold on; plot(tvec,frPSTHsOFF{1}{1}(:,sortPvalDifs(end-(i-1))),'linew',2);
    xlabel('Time (s)','fontsize',15,'fontweight','bold'); ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold'); legend({'GC ON','GC OFF'})
    set(gcf,'Position',[10 10 1400 500])
    uiwait
end
end

