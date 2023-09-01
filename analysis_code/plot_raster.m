function [] = plot_raster(datadir,group,onoff,stim,trial)
SR = SpikeReader([datadir '/spk_' group '_' onoff '_' num2str(stim) '_' num2str(trial) '.dat']);
spks = SR.readSpikes(-1);
scatter(spks(1,:),spks(2,:),'.')
end

