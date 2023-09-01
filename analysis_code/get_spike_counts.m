function [spike_counts] = get_spike_counts(spks)
ncells = length(spks);
spike_counts=zeros(1,ncells);
for i=1:ncells
    spike_counts(i) = length(spks{i});
end
end

