function [W,sortX] = get_weight_matrix(datadir,g1,g2)
addpath('~/CARLsim4/tools/offline_analysis_toolbox')
slashInds=strfind(datadir,'/');
dataInd = strfind(datadir,'data/');
netTypeBegin=dataInd+5;
netTypeEnd=find(slashInds > netTypeBegin);
netTypeEnd=slashInds(netTypeEnd(1))-1;
netType = datadir(netTypeBegin:netTypeEnd);
p = load([datadir '/p.mat']); p=p.p;

CR=ConnectionReader([datadir '/conn_' g1 '_' g2 '.dat']);
[allTimestamps, allWeights] = CR.readWeights();
[~,sortX]=sort(p.xcoordsE);
W=reshape(allWeights(1,:), CR.getNumNeuronsPost(), CR.getNumNeuronsPre());
%W=W(sortX,sortX);
end

