function [ie_connProbOB2E,ie_connProbOB2I,ie_connProbGC2E,ie_connProbGC2I,scores] = load_initial_evidence_randomNet(netDir)

%ie_meanWeightE = [];
%ie_meanWeightI = [];
%ie_meanWeightOB = [];
%ie_meanWeightGC = [];
%ie_connProbE2E = [];
%ie_connProbE2I = [];
%ie_connProbI2E = [];
%ie_connProbI2I = [];
ie_connProbOB2E = [];
ie_connProbOB2I = [];
ie_connProbGC2E = [];
ie_connProbGC2I = [];
scores = [];
files = dir(netDir);
count = 0;
for i=1:length(files)
    if (isfolder([netDir '/' files(i).name]) && ~isempty(str2num(files(i).name)))
        count=count+1;
        np = load([netDir '/' files(i).name '/netParams.mat']); np=np.netParams;
        score = load([netDir '/' files(i).name '/score.mat']); score=score.score;
        %ie_meanWeightE(count) = np.meanWeightE;
        %ie_meanWeightI(count) = np.meanWeightI;
        %ie_meanWeightOB(count) = np.meanWeightOB;
        %ie_meanWeightGC(count) = np.meanWeightGC;
        %ie_connProbE2E(count) = np.connProbE2E;
        %ie_connProbE2I(count) = np.connProbE2I;
        %ie_connProbI2E(count) = np.connProbI2E;
        %ie_connProbI2I(count) = np.connProbI2I;
        ie_connProbOB2E(count) = np.connProbOB2E;
        ie_connProbOB2I(count) = np.connProbOB2I;
        ie_connProbGC2E(count) = np.connProbGC2E;
        ie_connProbGC2I(count) = np.connProbGC2I;
        scores(count) = score;
    end
end
end

