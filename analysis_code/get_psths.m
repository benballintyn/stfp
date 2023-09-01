function [psths] = get_psths(spks,maxT,downSampleFactor,dt)
nStims = length(spks);
nTrials = length(spks{1});
ncells = length(spks{1}{1});
for i=1:nStims
    for j=1:ncells
        allspks = [];
        for k=1:nTrials
            allspks = [allspks spks{i}{k}{j}];
        end
        edges=0:downSampleFactor:maxT;
        [n,edges] = histcounts(allspks,edges);
        psths{i}(j,:) = n/(nTrials*downSampleFactor*dt); % maybe include dt later
    end
end
end

