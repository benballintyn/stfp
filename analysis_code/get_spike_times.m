function [spike_times] = get_spike_times(filename,ncells,timeCorrection)
SR = SpikeReader(filename);
spks = SR.readSpikes(-1);
spike_times = cell(ncells,1);
if (size(spks,1)==1)
    for i=1:ncells
        spike_times{i} = [];
    end
else
    for i=1:ncells
        spike_times{i} = spks(1,spks(2,:)==i) - timeCorrection;
    end
end
end

