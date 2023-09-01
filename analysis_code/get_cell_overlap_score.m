function [mean_overlap_score] = get_cell_overlap_score(datadir,responseType)
switch responseType
    case 'spikes'
        on = load([datadir '/on_responsive_spikes.mat']); on=on.on_responsive;
        off = load([datadir '/off_responsive_spikes.mat']); off=off.off_responsive;
    case 'firing rates'
        on = load([datadir '/on_responsive_frs.mat']); on=on.on_responsive;
        off = load([datadir '/off_responsive_frs.mat']); off=off.off_responsive;
end
ngroups = length(on);
nstims = length(on{1});
for i=1:ngroups
    for j=1:nstims
        onoff_overlap = length(intersect(on{i}{j},off{i}{j}));
        %{
        for k=1:nstims
            cross_stim_overlap(k) = length(intersect(on{i}{j},on{i}{k}));
        end
        %}
        if (length([on{i}{:}]) == 0)
            overlap_scores(j) = 1;
        else
            overlap_scores(j) = onoff_overlap/(length([on{i}{:}])/nstims);
        end
    end
end
mean_overlap_score = mean(overlap_scores);
end

