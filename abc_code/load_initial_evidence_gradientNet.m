function [ie_maxConnProbOB2E,ie_maxConnProbOB2I,ie_maxConnProbGC2E,ie_maxConnProbGC2I,...
          ie_sigmaOB2E,ie_sigmaOB2I,ie_sigmaGC2E,ie_sigmaGC2I,...
          ie_maxConnProbE2E,ie_maxConnProbE2I,ie_maxConnProbI2E,ie_maxConnProbI2I,...
          ie_sigmaE2E,ie_sigmaE2I,ie_sigmaI2E,ie_sigmaI2I,ie_Iwt_mult,scores] = load_initial_evidence_gradientNet(netDir)

ie_maxConnProbOB2E = [];
ie_maxConnProbOB2I = [];
ie_maxConnProbGC2E = [];
ie_maxConnProbGC2I = [];
ie_sigmaOB2E = [];
ie_sigmaOB2I = [];
ie_sigmaGC2E = [];
ie_sigmaGC2I = [];
ie_maxConnProbE2E = [];
ie_maxConnProbE2I = [];
ie_maxConnProbI2E = [];
ie_maxConnProbI2I = [];
ie_sigmaE2E = [];
ie_sigmaE2I = [];
ie_sigmaI2E = [];
ie_sigmaI2I = [];
ie_Iwt_mult = [];
scores = [];
files = dir(netDir);
count = 0;
for i=1:length(files)
    if (isfolder([netDir '/' files(i).name]) && ~isempty(str2num(files(i).name)))
        count=count+1;
        np = load([netDir '/' files(i).name '/netParams.mat']); np=np.netParams;
        score = load([netDir '/' files(i).name '/score.mat']); score=score.score;
        ie_maxConnProbOB2E(count) = np.maxConnProbOB2E;
        ie_maxConnProbOB2I(count) = np.maxConnProbOB2I;
        ie_maxConnProbGC2E(count) = np.maxConnProbGC2E;
        ie_maxConnProbGC2I(count) = np.maxConnProbGC2I;
        ie_sigmaOB2E(count) = np.sigmaOB2E/1e-6;
        ie_sigmaOB2I(count) = np.sigmaOB2I/1e-6;
        ie_sigmaGC2E(count) = np.sigmaGC2E/1e-6;
        ie_sigmaGC2I(count) = np.sigmaGC2I/1e-6;
        ie_maxConnProbE2E(count) = np.maxConnProbE2E;
        ie_maxConnProbE2I(count) = np.maxConnProbE2I;
        ie_maxConnProbI2E(count) = np.maxConnProbI2E;
        ie_maxConnProbI2I(count) = np.maxConnProbI2I;
        ie_sigmaE2E(count) = np.sigmaE2E;
        ie_sigmaE2I(count) = np.sigmaE2I;
        ie_sigmaI2E(count) = np.sigmaI2E;
        ie_sigmaI2I(count) = np.sigmaI2I;
        ie_Iwt_mult(count) = np.Iwt_mult;
        scores(count) = score;
    end
end
end

