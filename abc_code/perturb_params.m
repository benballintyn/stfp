% test_around_net
exampleNetDir = '~/phd/stfp/manual_runs/15';
np = load([exampleNetDir '/netParams.mat']); np=np.netParams;

savedir = '~/phd/stfp/perturb_params';
if (~exist(savedir,'dir'))
    mkdir(savedir)
end
for i=1:50
    netDir = [savedir '/' num2str(i)];
    maxConnProbOB2E = min(1,max(0,np.maxConnProbOB2E + normrnd(0,.02)));
    maxConnProbOB2I = min(1,max(0,np.maxConnProbOB2I + normrnd(0,.02)));
    maxConnProbGC2E = min(1,max(0,np.maxConnProbGC2E + normrnd(0,.02)));
    maxConnProbGC2I = min(1,max(0,np.maxConnProbGC2I + normrnd(0,.02)));
    sigmaOB2E = min(1e-3,max(1e-6,np.sigmaOB2E + normrnd(0,25e-6)));
    sigmaOB2I = min(1e-3,max(1e-6,np.sigmaOB2I + normrnd(0,25e-6)));
    sigmaGC2E = min(1e-3,max(1e-6,np.sigmaGC2E + normrnd(0,25e-6)));
    sigmaGC2I = min(1e-3,max(1e-6,np.sigmaGC2I + normrnd(0,25e-6)));
    GC2Edir = -1;
    GC2Idir = 1;
    Iwt_mult = max(1,np.Iwt_mult + normrnd(0,1));
    maxConnProbE2E = min(1,max(0,np.maxConnProbE2E + normrnd(0,.02)));
    maxConnProbE2I = min(1,max(0,np.maxConnProbE2I + normrnd(0,.02)));
    maxConnProbI2E = min(1,max(0,np.maxConnProbI2E + normrnd(0,.02)));
    maxConnProbI2I = min(1,max(0,np.maxConnProbI2I + normrnd(0,.02)));
    sigmaE2E = min(1e-3,max(1e-6,np.sigmaE2E + normrnd(0,25e-6)));
    sigmaE2I = min(1e-3,max(1e-6,np.sigmaE2I + normrnd(0,25e-6)));
    sigmaI2E = min(1e-3,max(1e-6,np.sigmaI2E + normrnd(0,25e-6)));
    sigmaI2I = min(1e-3,max(1e-6,np.sigmaI2I + normrnd(0,25e-6)));
    score = runGradientNet_manual(maxConnProbOB2E,maxConnProbOB2I,maxConnProbGC2E,maxConnProbGC2I,...
                                       sigmaOB2E,sigmaOB2I,sigmaGC2E,sigmaGC2I,GC2Edir,GC2Idir,Iwt_mult,...
                                       maxConnProbE2E,maxConnProbE2I,maxConnProbI2E,maxConnProbI2I,...
                                       sigmaE2E,sigmaE2I,sigmaI2E,sigmaI2I,netDir,'no');
end