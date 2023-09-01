function [W] = get_formatted_weight_matrix(datadir)
addpath('~/CARLsim4/tools/offline_analysis_toolbox')
slashInds=strfind(datadir,'/');
dataInd = strfind(datadir,'data/');
netTypeBegin=dataInd+5;
netTypeEnd=find(slashInds > netTypeBegin);
netTypeEnd=slashInds(netTypeEnd(1))-1;
netType = datadir(netTypeBegin:netTypeEnd);
p = load([datadir '/p.mat']); p=p.p;
switch netType
    case 'EI_net'
        W=zeros(p.nE,p.nE);
        disp(['EI_net does not have saved weight matrices']);
    case 'EI_net_cluster'
        CR=ConnectionReader([datadir '/conn_E_E.dat']);
        [allTimestamps, allWeights] = CR.readWeights();
        W=reshape(allWeights(1,:), CR.getNumNeuronsPost(), CR.getNumNeuronsPre());
        modfactor=p.modFactor;
        cellInds=1:p.nE;
        modVals = mod(cellInds,modfactor)+1;
        [~,clustIDs] = sort(modVals);
        W = W(clustIDs,clustIDs);
    case 'EI_net_gaussian'
        CR=ConnectionReader([datadir '/conn_E_E.dat']);
        [allTimestamps, allWeights] = CR.readWeights();
        W=reshape(allWeights(1,:), CR.getNumNeuronsPost(), CR.getNumNeuronsPre());
        xcoords=p.xcoords;
        ycoords=p.ycoords;
        [~,xinds]= sort(xcoords);
        W=W(xinds,xinds);
end
end

