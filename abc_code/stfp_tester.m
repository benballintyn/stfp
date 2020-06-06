% stfp_tester
connProbOB2E = 0; connProbOB2I = 0; connProbGC2E = 0; connProbGC2I = 0;
% Inputs
% Parameters
% 1. meanWeightE2E
% 2. stdWeightE2E
% 3. meanWeightE2I
% 4. stdWeightE2I
% 5. meanWeightI2E
% 6. stdWeightI2E
% 7. meanWeightI2I
% 8. stdWeightI2I
addpath(genpath('~/phd/easySim'))

netParams.connProbOB2E = connProbOB2E;
netParams.connProbOB2I = connProbOB2I;
netParams.connProbGC2E = connProbGC2E;
netParams.connProbGC2I = connProbGC2I;
netParams.meanWeight = 1.785e-8; % from calculation for 1mV EPSP
netParams.maxConnProbE2E = .15; % (Levy & Reyes, 2012)
netParams.maxConnProbE2I = .5;  % (Levy & Reyes, 2012)
netParams.maxConnProbI2E = .5;  % (Levy & Reyes, 2012)
netParams.maxConnProbI2I = 1; % (Galaretta & Hestrin, 2002)
netParams.sigmaE2E = 100e-6; % (Levy & Reyes, 2012)
netParams.sigmaE2I = 100e-6; % (Levy & Reyes, 2012)
netParams.sigmaI2E = 100e-6; % (Levy & Reyes, 2012)
netParams.sigmaI2I = 100e-6; % (guess)
netParams.xmin = 0;
netParams.xmax = 1e-3;
netParams.ymin = 0;
netParams.ymax = 1e-3;
drange = 0:1e-6:1e-3;

fE2E = @(D) (sqrt(2)/(netParams.sigmaE2E*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaE2E^2)));
fE2I = @(D) (sqrt(2)/(netParams.sigmaE2I*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaE2I^2)));
fI2E = @(D) (sqrt(2)/(netParams.sigmaI2E*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaI2E^2)));
fI2I = @(D) (sqrt(2)/(netParams.sigmaI2I*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaI2I^2)));
netParams.connProbFunctionE2E = @(D) netParams.maxConnProbE2E*fE2E(D)./max(fE2E(drange));
netParams.connProbFunctionE2I = @(D) netParams.maxConnProbE2I*fE2I(D)./max(fE2I(drange));
netParams.connProbFunctionI2E = @(D) netParams.maxConnProbI2E*fI2E(D)./max(fI2E(drange));
netParams.connProbFunctionI2I = @(D) netParams.maxConnProbI2I*fI2I(D)./max(fI2I(drange));

netParams.gaussWeightFunction = @(D) lognrnd(log(netParams.meanWeight)-.5,1,size(D)); % (citation: Koulakov)

fprintf('connProbOB2E: %1$f\n connProbOB2I: %2$f\n connProbGC2E: %3$f\n connProbGC2I: %4$f\n',connProbOB2E,connProbOB2I,connProbGC2E,connProbGC2I)

simParams.nOdors = 5;
simParams.nTrials = 10;
simParams.fracGlomeruliPerOdor = .1;
simParams.nGlomeruli = 100;

if (~exist('~/phd/stfp/abc_results/randomNet','dir'))
    mkdir('~/phd/stfp/abc_results/randomNet')
end
if (exist('~/phd/stfp/abc_results/randomNet/runNum.mat','file'))
    runNum = load(['~/phd/stfp/abc_results/randomNet/runNum.mat']); runNum=runNum.runNum;
    runNum = runNum+1;
    save('~/phd/stfp/abc_results/randomNet/runNum.mat','runNum','-mat')
else
    runNum = 1;
    save('~/phd/stfp/abc_results/randomNet/runNum.mat','runNum','-mat')
end
datadir = ['~/phd/stfp/abc_results/randomNet/' num2str(runNum)];

if (~exist(datadir,'dir'))
    mkdir(datadir)
end

net = AEVLIFnetwork();

net.addGroup('E',800,'excitatory',1,'std_noise',700e-12,'depressed_synapses',true,'xmax',1e-3,'ymax',1e-3)
net.addGroup('I',200,'inhibitory',1,'std_noise',700e-12,'depressed_synapses',true,'xmax',1e-3,'ymax',1e-3)

% Predefined parameters
maxWeight = 10e-7;

% Set parameters for E --> E connection
weightRange = 1e-12:1e-12:maxWeight;
px = lognpdf(weightRange,log(netParams.meanWeight)-.5,1);
lognWeightDist = weightDistribution(weightRange, px);
gaussConnParamsE2E.connProbFunction = netParams.connProbFunctionE2E;
gaussConnParamsE2E.weightFunction= netParams.gaussWeightFunction;
gaussConnParamsE2E.useWrap = true;

% Set parameters for E --> I connection
gaussConnParamsE2I.connProbFunction = netParams.connProbFunctionE2I;
gaussConnParamsE2I.weightFunction = netParams.gaussWeightFunction;
gaussConnParamsE2I.useWrap = true;

% Set parameters for I --> E connection
gaussConnParamsI2E.connProbFunction = netParams.connProbFunctionE2I;
gaussConnParamsI2E.weightFunction = netParams.gaussWeightFunction;
gaussConnParamsI2E.useWrap = true;

% Set parameters for I --> I connection
gaussConnParamsI2I.connProbFunction = netParams.connProbFunctionI2I;
gaussConnParamsI2I.weightFunction = netParams.gaussWeightFunction;
gaussConnParamsI2I.useWrap = true;

% add connections to network object
net.connect(1,1,'gaussian',gaussConnParamsE2E);
net.connect(1,2,'gaussian',gaussConnParamsE2I);
net.connect(2,1,'gaussian',gaussConnParamsI2E);
net.connect(2,2,'gaussian',gaussConnParamsI2I);

% Add GC input via a Poisson spike generator
net.addSpikeGenerator('GC',500,'excitatory',10)

% Add olfactory bulb inputs to E and I groups
randomConnParamsOB2E.connProb = connProbOB2E;
randomConnParamsOB2E.weightDistribution = lognWeightDist;
randomConnParamsOB2I.connProb = connProbOB2I;
randomConnParamsOB2I.weightDistribution = lognWeightDist;
for i=1:simParams.nGlomeruli
    net.addSpikeGenerator(['OB' num2str(i)],100,'excitatory',0);
    net.connect(-(i+1),1,'random',randomConnParamsOB2E);
    net.connect(-(i+1),2,'random',randomConnParamsOB2I);
end

% Assign glomeruli to odors
for i=1:simParams.nOdors
    draw = randperm(simParams.nGlomeruli)+1;
    glomeruliByOdor(i,:) = draw(1:(simParams.nGlomeruli*simParams.fracGlomeruliPerOdor));
end

% Connect the GC input to E group
randomConnParamsGC2E.connProb = connProbGC2E;
randomConnParamsGC2E.weightDistribution = lognWeightDist;
randomConnParamsGC2I.connProb = connProbGC2I;
randomConnParamsGC2I.weightDistribution = lognWeightDist;
net.connect(-1,1,'random',randomConnParamsGC2E);
net.connect(-1,2,'random',randomConnParamsGC2I);

% use GPU
useGpu = 0;

% Initialize the network variables
[V,Vreset,Cm,Gl,El,Vth,Vth0,Vth_max,tau_ref,dth,p0,GsynE,GsynI,VsynE,VsynI,tau_synE,tau_synI,...
          Iapp,std_noise,GsynMax,Isra,tau_sra,a,b,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
          ecells,icells,spikeGenProbs,cells2record,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
          tau_plus,tau_x,tau_minus,tau_y,is_plastic,C,dt] = ...
          setupNet(net,useGpu);

%%
% Compile the CUDA code to run the network
if (runNum == 1)
    compileSimulator(net,useGpu,length(cells2record));
end
%%
% set plasticity type even though it is not being used
plasticity_type='';

% explicitly set dt
if (useGpu)
    dt = single(1e-4);
else
    dt = 1e-4;
end

% Add to sim params
simParams.dt = dt;
if (useGpu)
    simParams.cells2record = gather(cells2record);
else
    simParams.cells2record = cells2record;
end
simParams.baseline_duration = 1/dt;
simParams.stim_duration = 1/dt;
simParams.poststim_duration = 1/dt;
simParams.stim_amplitude = 10;

% Run through 5 odor stimuli for 10 trials each, recording responses
for i=1:simParams.nOdors
    % Run nTrials with GC input ON
    for j=1:simParams.nTrials
        % Reinitialize the network variables
        [V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2,Iapp] = resetVars(net,useGpu);
        
        % Reset spike generator probabilities
        newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,1,10*dt);
        % Run 1 second of baseline activity
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCON.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
        
        % Run 1 second of activity with odor input
        newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCON.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
        
        % Run 1 additional second without odor input
        newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCON.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
    end
    
    % run nTrials with GC input Off
    [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,1,0); % Silence GC
    for j=1:simParams.nTrials
        % Reinitialize the network variables
        [V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2,Iapp] = resetVars(net,useGpu);
        
        % Reset spike generator probabilities
        newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        % Run 1 second of baseline activity
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCOFF.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
        
        % Run 1 second of activity with odor input
        newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCOFF.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
        
        % Run 1 additional second without odor input
        newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        [spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([datadir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCOFF.bin'],'W');
        [GsynMax,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbs,cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
    end
end
fclose('all')
save([datadir '/net.mat'],'net','-mat')
save([datadir '/GsynMax.mat'],'GsynMax','-mat')
save([datadir '/netParams.mat'],'netParams','-mat')
save([datadir '/simParams.mat'],'simParams','-mat')

score = scoreNet(datadir);
save([datadir '/score.mat'],'score','-mat')

