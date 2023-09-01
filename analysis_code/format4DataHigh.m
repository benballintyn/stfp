function [D] = format4DataHigh(datadir,conglomerate)
p=load([datadir '/p.mat']); p=p.p;
spksON=load([datadir '/spike_timesON.mat']); spksON=spksON.spike_timesON;
spksOFF=load([datadir '/spike_timesOFF.mat']); spksOFF=spksOFF.spike_timesOFF;

ngroups = length(spksON);
nsmells = p.nsmells;
ntrials = p.ntrials;
ntsteps = p.trial_time/p.dt;
cmap=jet;
switch conglomerate
    case 'yes'
        nTotal=0;
        for i=1:ngroups
            ncells(i) = length(spksON{i}{1}{1});
            nTotal=nTotal+ncells(i);
        end
        count=0;
        for i=1:nsmells
            for j=1:ntrials
                count=count+1;
                D(count).data=zeros(nTotal,ntsteps);
                D(count).condition = ['smell' num2str(i) 'ON'];
                D(count).epochStarts=1;
                D(count).epochColors=cmap(ceil(i*(32/nsmells)),:);
                curCell=0;
                for k=1:ngroups
                    for l=1:ncells(k)
                        curCell=curCell+1;
                        D(count).data(curCell,spksON{k}{i}{j}{l})=1;
                    end
                end
            end
        end
        for i=1:nsmells
            for j=1:ntrials
                count=count+1;
                D(count).data=zeros(nTotal,ntsteps);
                D(count).condition = ['smell' num2str(i) 'OFF'];
                D(count).epochStarts=1;
                D(count).epochColors=cmap(ceil(2*i*(32/nsmells)),:);
                curCell=0;
                for k=1:ngroups
                    for l=1:ncells(k)
                        curCell=curCell+1;
                        D(count).data(curCell,spksOFF{k}{i}{j}{l})=1;
                    end
                end
            end
        end
    case 'no'
end
end

