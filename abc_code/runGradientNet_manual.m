function score = runGradientNet_manual(maxConnProbOB2E,maxConnProbOB2I,maxConnProbGC2E,maxConnProbGC2I,...
                                       sigmaOB2E,sigmaOB2I,sigmaGC2E,sigmaGC2I,GC2Edir,GC2Idir,Iwt_mult,...
                                       maxConnProbE2E,maxConnProbE2I,maxConnProbI2E,maxConnProbI2I,...
                                       sigmaE2E,sigmaE2I,sigmaI2E,sigmaI2I,netDir,recompile)
% Inputs
% Note: All sigma parameters are in meters. Recommend values between 1e-6
% and 1e-3 for all sigma parameters
% 1. maxConnProbOB2E - max possible connection probability between
%                      olfactory inputs and the excitatory group
% 2. maxConnProbOB2I - max possible connection probability between
%                      olfactory inputs and the inhibitory group
% 3. maxConnProbGC2E - max possible connection probability between GC
%                      inputs and the excitatory group
% 4. maxConnProbGC2I - max possible connection probability between GC
%                      inputs and the inhibitory group
% 5. sigmaOB2E       - length scale over which the connection probability
%                      between OB and the excitatory group decreases (for
%                      gradient connection). Gives standard deviation of
%                      half-gaussian.
% 6. sigmaOB2I       - length scale over which the connection probability
%                      between OB and the inhibitory group decreases (for
%                      gradient connection). Gives standard deviation of
%                      half-gaussian.
% 7. sigmaGC2E       - length scale over which the connection probability
%                      between GC and the excitatory group decreases (for
%                      gradient connection). Gives standard deviation of
%                      half-gaussian.
% 8. sigmaGC2I       - length scale over which the connection probability
%                      between GC and the inhibitory group decreases (for 
%                      gradient connection). Gives standard deviation of 
%                      half-gaussian.
% 9. GC2Edir         - specifies direction of gradient of connection
%                      probability for GC --> E connection. Values > 0
%                      indicate it is in the same direction as the OB --> E
%                      connection. Values < 0 indicate the opposite
%                      direction.
% 10. GC2Idir        - specifies direction of gradient of connection
%                      probability for GC --> I connection. Values > 0
%                      indicate it is in the same direction as the OB --> E
%                      connection. Values < 0 indicate the opposite
%                      direction.
% 11. Iwt_mult       - Multiplier of inhibitory synaptic strengths relative
%                      to excitatory synapses.
% 12. maxConnProbE2E - max possible connection probability between
%                      excitatory neurons (E --> E).
% 13. maxConnProbE2I - max possible connection probability between
%                      excitatory neurons and inhibitory neurons (E --> I).
% 14. maxConnProbI2E - max possible connection probability between
%                      inhibitory neurons and excitatory neurons (I --> E).
% 15. maxConnProbI2I - max possible connection probability between
%                      inhibitory neurons (I --> I).
% 16. sigmaE2E       - length scale over which the connection probability
%                      between excitatory neurons decreases. Gives standard
%                      deviation of half-gaussian
% 16. sigmaE2I       - length scale over which the connection probability
%                      between excitatory neurons and inhibitory neurons 
%                      decreases. Gives standard deviation of half-gaussian
% 16. sigmaI2E       - length scale over which the connection probability
%                      between inhibitory and excitatory neurons decreases.
%                      Gives standard deviation of half-gaussian
% 16. sigmaI2I       - length scale over which the connection probability
%                      between inhibitory neurons decreases. Gives standard
%                      deviation of half-gaussian
% 17. netDir         - path to folder where spikes and parameters are to be
%                      saved
% 18. recompile      - boolean (0 or 1) value for whether or not to
%                      recompile the required mex functions
randState = rng;
addpath(genpath('~/phd/easySim')); % change to path containing easySim directory. not required if easySim is already on the MATLAB path

netParams.maxConnProbOB2E = maxConnProbOB2E;
netParams.maxConnProbOB2I = maxConnProbOB2I;
netParams.maxConnProbGC2E = maxConnProbGC2E;
netParams.maxConnProbGC2I = maxConnProbGC2I;
netParams.sigmaOB2E = sigmaOB2E;
netParams.sigmaOB2I = sigmaOB2I;
netParams.sigmaGC2E = sigmaGC2E;
netParams.sigmaGC2I = sigmaGC2I;
netParams.Iwt_mult = Iwt_mult;
netParams.meanWeightE = 1.785e-8; % from calculation for 1mV EPSP
netParams.meanWeightI = netParams.meanWeightE*netParams.Iwt_mult;
netParams.maxConnProbE2E = maxConnProbE2E; % (Levy & Reyes, 2012)
netParams.maxConnProbE2I = maxConnProbE2I;  % (Levy & Reyes, 2012)
netParams.maxConnProbI2E = maxConnProbI2E;  % (Levy & Reyes, 2012)
netParams.maxConnProbI2I = maxConnProbI2I; % (Galaretta & Hestrin, 2002)
netParams.sigmaE2E = sigmaE2E; % (Levy & Reyes, 2012)
netParams.sigmaE2I = sigmaE2I; % (Levy & Reyes, 2012)
netParams.sigmaI2E = sigmaI2E; % (Levy & Reyes, 2012)
netParams.sigmaI2I = sigmaI2I; % (guess)
netParams.GC2Edir = GC2Edir;
netParams.GC2Idir = GC2Idir;
netParams.xmin = 0;
netParams.xmax = 1e-3;
netParams.ymin = 0;
netParams.ymax = 1e-3;
drange = 0:1e-6:1e-3;

fE2E = @(D) (sqrt(2)/(netParams.sigmaE2E*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaE2E^2)));
fE2I = @(D) (sqrt(2)/(netParams.sigmaE2I*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaE2I^2)));
fI2E = @(D) (sqrt(2)/(netParams.sigmaI2E*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaI2E^2)));
fI2I = @(D) (sqrt(2)/(netParams.sigmaI2I*sqrt(pi)))*(exp((-D.^2)./(2*netParams.sigmaI2I^2)));
fOB2E = @(x) (sqrt(2)/(netParams.sigmaOB2E*sqrt(pi)))*(exp((-x.^2)./(2*netParams.sigmaOB2E^2)));
fOB2I = @(x) (sqrt(2)/(netParams.sigmaOB2I*sqrt(pi)))*(exp((-x.^2)./(2*netParams.sigmaOB2I^2)));
if (netParams.GC2Edir > 0)
    fGC2E = @(x) (sqrt(2)/(netParams.sigmaGC2E*sqrt(pi)))*(exp((-x.^2)./(2*netParams.sigmaGC2E^2)));
else
    fGC2E = @(x) (sqrt(2)/(netParams.sigmaGC2E*sqrt(pi)))*(exp((-((netParams.xmax - x).^2)./(2*netParams.sigmaGC2E^2))));
end
if (netParams.GC2Idir > 0)
    fGC2I = @(x) (sqrt(2)/(netParams.sigmaGC2I*sqrt(pi)))*(exp((-x.^2)./(2*netParams.sigmaGC2I^2)));
else
    fGC2I = @(x) (sqrt(2)/(netParams.sigmaGC2I*sqrt(pi)))*(exp((-((netParams.xmax - x).^2)./(2*netParams.sigmaGC2I^2))));
end

netParams.connProbFunctionE2E = @(D) netParams.maxConnProbE2E*fE2E(D)./max(fE2E(drange));
netParams.connProbFunctionE2I = @(D) netParams.maxConnProbE2I*fE2I(D)./max(fE2I(drange));
netParams.connProbFunctionI2E = @(D) netParams.maxConnProbI2E*fI2E(D)./max(fI2E(drange));
netParams.connProbFunctionI2I = @(D) netParams.maxConnProbI2I*fI2I(D)./max(fI2I(drange));
netParams.connProbFunctionOB2E = @(x) netParams.maxConnProbOB2E*fOB2E(x)./max(fOB2E(drange));
netParams.connProbFunctionOB2I = @(x) netParams.maxConnProbOB2I*fOB2I(x)./max(fOB2I(drange));
netParams.connProbFunctionGC2E = @(x) netParams.maxConnProbGC2E*fGC2E(x)./max(fGC2E(drange));
netParams.connProbFunctionGC2I = @(x) netParams.maxConnProbGC2I*fGC2I(x)./max(fGC2I(drange));
netParams.gaussWeightFunctionE = @(D) lognrnd(log(netParams.meanWeightE)-.5,1,size(D)); % (citation: Koulakov)
netParams.gaussWeightFunctionI = @(D) lognrnd(log(netParams.meanWeightI)-.5,1,size(D)); % (citation: Koulakov)
netParams.gradientWeightFunction = @(D) lognrnd(log(netParams.meanWeightE)-.5,1,size(D)); % (citation: Koulakov)

simParams.nOdors = 5;
simParams.nTrials = 10;
simParams.fracGlomeruliPerOdor = .1;
simParams.nGlomeruli = 100;
simParams.randState = randState;

if (~exist(netDir,'dir'))
    mkdir(netDir)
end

net = AEVLIFnetwork();

net.addGroup('E',800,'excitatory',1,'std_noise',700e-12,'depressed_synapses',true,'xmax',1e-3,'ymax',1e-3)
net.addGroup('I',200,'inhibitory',1,'std_noise',700e-12,'depressed_synapses',true,'xmax',1e-3,'ymax',1e-3)

% Predefined parameters
maxWeight = 10e-7;

% Set parameters for E --> E connection
gaussConnParamsE2E.connProbFunction = netParams.connProbFunctionE2E;
gaussConnParamsE2E.weightFunction= netParams.gaussWeightFunctionE;
gaussConnParamsE2E.useWrap = true;

% Set parameters for E --> I connection
gaussConnParamsE2I.connProbFunction = netParams.connProbFunctionE2I;
gaussConnParamsE2I.weightFunction = netParams.gaussWeightFunctionE;
gaussConnParamsE2I.useWrap = true;

% Set parameters for I --> E connection
gaussConnParamsI2E.connProbFunction = netParams.connProbFunctionE2I;
gaussConnParamsI2E.weightFunction = netParams.gaussWeightFunctionI;
gaussConnParamsI2E.useWrap = true;

% Set parameters for I --> I connection
gaussConnParamsI2I.connProbFunction = netParams.connProbFunctionI2I;
gaussConnParamsI2I.weightFunction = netParams.gaussWeightFunctionI;
gaussConnParamsI2I.useWrap = true;

% add connections to network object
net.connect(1,1,'gaussian',gaussConnParamsE2E);
net.connect(1,2,'gaussian',gaussConnParamsE2I);
net.connect(2,1,'gaussian',gaussConnParamsI2E);
net.connect(2,2,'gaussian',gaussConnParamsI2I);

% Add GC input via a Poisson spike generator
net.addSpikeGenerator('GC',500,'excitatory',10)

% Add olfactory bulb inputs to E and I groups
gradientConnParamsOB2E.connProbFunction = netParams.connProbFunctionOB2E;
gradientConnParamsOB2E.weightFunction = netParams.gradientWeightFunction;
gradientConnParamsOB2I.connProbFunction = netParams.connProbFunctionOB2I;
gradientConnParamsOB2I.weightFunction = netParams.gradientWeightFunction;
for i=1:simParams.nGlomeruli
    net.addSpikeGenerator(['OB' num2str(i)],100,'excitatory',0);
    net.connect(-(i+1),1,'gradient',gradientConnParamsOB2E);
    net.connect(-(i+1),2,'gradient',gradientConnParamsOB2I);
end

% Assign glomeruli to odors
for i=1:simParams.nOdors
    draw = randperm(simParams.nGlomeruli)+1;
    glomeruliByOdor(i,:) = draw(1:(simParams.nGlomeruli*simParams.fracGlomeruliPerOdor));
end

% Connect the GC input to E group
gradientConnParamsGC2E.connProbFunction = netParams.connProbFunctionGC2E;
gradientConnParamsGC2E.weightFunction = netParams.gradientWeightFunction;
gradientConnParamsGC2I.connProbFunction = netParams.connProbFunctionGC2I;
gradientConnParamsGC2I.weightFunction = netParams.gradientWeightFunction;
net.connect(-1,1,'gradient',gradientConnParamsGC2E);
net.connect(-1,2,'gradient',gradientConnParamsGC2I);

% use GPU
useGpu = 0;

% Initialize the network variables
[V,Vreset,Cm,Gl,El,Vth,Vth0,Vth_max,tau_ref,dth,p0,GsynE,GsynI,VsynE,VsynI,tau_synE,tau_synI,...
          Iapp,std_noise,GsynMax,Isra,tau_sra,a,b,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
          ecells,icells,spikeGenProbs,cells2record,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
          tau_plus,tau_x,tau_minus,tau_y,is_plastic,C,dt] = ...
          setupNet(net,useGpu);

% Compile the CUDA code to run the network
if (recompile)
    compileSimulator(net,useGpu,length(cells2record));
end

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
for i=1:simParams.nOdors
    newProbs = zeros(1,length(glomeruliByOdor(i,:)));
    spikeGenProbsON_baseline(:,i) = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
    spikeGenProbsON_baseline(:,i) = setSpikeGenProbs(net,spikeGenProbsON_baseline(:,i),1,10*dt);

    newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
    spikeGenProbsON_stim(:,i) = setSpikeGenProbs(net,spikeGenProbsON_baseline(:,i),glomeruliByOdor(i,:),newProbs);

    newProbs = zeros(1,length(glomeruliByOdor(i,:)));
    [tempspkprobs] = setSpikeGenProbs(net,spikeGenProbs,1,0); % Silence GC
    spikeGenProbsOFF_baseline(:,i) = setSpikeGenProbs(net,tempspkprobs,glomeruliByOdor(i,:),newProbs);

    newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
    spikeGenProbsOFF_stim(:,i) = setSpikeGenProbs(net,tempspkprobs,glomeruliByOdor(i,:),newProbs);
end

% Run through 5 odor stimuli for 10 trials each, recording responses
parfor i=1:simParams.nOdors
    % Run nTrials with GC input ON
    for j=1:simParams.nTrials
        % Reinitialize the network variables
        [V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2,Iapp] = resetVars(net,useGpu);

        % Reset spike generator probabilities
        %newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,1,10*dt);
        % Run 1 second of baseline activity
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCON.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsON_baseline(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);

        % Run 1 second of activity with odor input
        %newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCON.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsON_stim(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);

        % Run 1 additional second without odor input
        %newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCON.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsON_baseline(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
	      tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
    end

    % run nTrials with GC input Off
    %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,1,0); % Silence GC
    for j=1:simParams.nTrials
        % Reinitialize the network variables
        [V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2,Iapp] = resetVars(net,useGpu);

        % Reset spike generator probabilities
        %newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        % Run 1 second of baseline activity
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_baseline_GCOFF.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsOFF_baseline(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);

        % Run 1 second of activity with odor input
        %newProbs = ones(1,length(glomeruliByOdor(i,:)))*(simParams.stim_amplitude*dt);
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_stim_GCOFF.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsOFF_stim(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);

        % Run 1 additional second without odor input
        %newProbs = zeros(1,length(glomeruliByOdor(i,:)));
        %[spikeGenProbs] = setSpikeGenProbs(net,spikeGenProbs,glomeruliByOdor(i,:),newProbs);
        nT = double(1/dt);
        spkfid = fopen([netDir '/odor_' num2str(i) '_trial_' num2str(j) '_poststim_GCOFF.bin'],'W');
        [~,V,Vth,Isra,GsynE,GsynI,D,F,r1,r2,o1,o2] = runAEVLIFNetCPU_mex(V,Vreset,tau_ref,Vth,Vth0,Vth_max,...
              Isra,tau_sra,a,b,VsynE,VsynI,GsynE,GsynI,GsynMax,tau_D,tau_F,f_fac,D,F,has_facilitation,has_depression,...
              p0,tau_synE,tau_synI,Cm,Gl,El,dth,Iapp,std_noise,dt,ecells,icells,spikeGenProbsOFF_baseline(:,i),cells2record,...
              is_plastic,plasticity_type,C,r1,r2,o1,o2,A2plus,A3plus,A2minus,A3minus,...
              tau_plus,tau_x,tau_minus,tau_y,nT,spkfid,false);
        fclose(spkfid);
    end
end

fclose('all');
save([netDir '/net.mat'],'net','-mat')
save([netDir '/GsynMax.mat'],'GsynMax','-mat')
save([netDir '/netParams.mat'],'netParams','-mat')
save([netDir '/simParams.mat'],'simParams','-mat')

score = scoreNet(netDir);
save([netDir '/score.mat'],'score','-mat')
end

