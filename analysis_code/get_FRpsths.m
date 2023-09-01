function [frPSTHsON,frPSTHsOFF] = get_FRpsths(datadir,allowSkip)
if (strcmp(allowSkip,'yes') && exist([datadir '/frPSTHsON.mat'],'file'))
    frPSTHsON=load([datadir '/frPSTHsON.mat']); frPSTHsON=frPSTHsON.frPSTHsON;
    frPSTHsOFF=load([datadir '/frPSTHsOFF.mat']); frPSTHsOFF=frPSTHsOFF.frPSTHsOFF;
    disp(['frPSTHs already done for ' datadir])
else
    p = load([datadir '/p.mat']); p=p.p;
    frsON=load([datadir '/frsON.mat']); frsON=frsON.frsON;
    frsOFF=load([datadir '/frsOFF.mat']); frsOFF=frsOFF.frsOFF;
    ngroups=p.ngroups;
    nsmells=p.nsmells;
    ntrials=p.ntrials;
    for i=1:ngroups
        for j=1:nsmells
            for k=1:ntrials
                allTrialsFRsON{i}{j}(:,:,k) = frsON{i}{j}{k};
                allTrialsFRsOFF{i}{j}(:,:,k) = frsOFF{i}{j}{k};
            end
            frPSTHsON{i}{j} = mean(allTrialsFRsON{i}{j},3);
            frPSTHsOFF{i}{j} = mean(allTrialsFRsOFF{i}{j},3);
        end
    end
    save([datadir '/frPSTHsON.mat'],'frPSTHsON','-mat')
    save([datadir '/frPSTHsOFF.mat'],'frPSTHsOFF','-mat')
end
end

