import numpy as np
import scipy.stats
import matplotlib
import matplotlib.pyplot as plt

import logging
logging.basicConfig(level=logging.INFO)

import elfi
import matlab.engine
import pickle
from pathlib import Path

def simulator(maxConnProbOB2E, maxConnProbOB2I, maxConnProbGC2E, maxConnProbGC2I, sigmaOB2PC, sigmaGC2PC, batch_size=1,random_state=None):
    
    score = eng.runGradientNetCPU(matlab.double([maxConnProbOB2E.tolist()]), matlab.double([maxConnProbOB2I.tolist()]), matlab.double([maxConnProbGC2E.tolist()]), matlab.double([maxConnProbGC2I.tolist()]), matlab.double([sigmaOB2PC.tolist()]), matlab.double([sigmaGC2PC.tolist()]))

    return score

def score_network(score):
        return score

def main():
    global eng
    datadir = Path('/home/ben/phd/stfp/abc_results/gradientNet')

    eng = matlab.engine.start_matlab()

    eng.addpath(eng.genpath('~/phd/stfp/abc_code'))
    eng.addpath(eng.genpath('~/phd/easySim'))



    maxConnProbOB2E_prior = elfi.Prior('uniform',0,1)
    maxConnProbOB2I_prior = elfi.Prior('uniform',0,1)
    maxConnProbGC2E_prior = elfi.Prior('uniform',0,1)
    maxConnProbGC2I_prior = elfi.Prior('uniform',0,1)
    sigmaOB2PC_prior      = elfi.Prior('uniform',1e-6,1000e-6)
    sigmaGC2PC_prior      = elfi.Prior('uniform',1e-6,1000e-6)

    sim = elfi.Simulator(simulator,maxConnProbOB2E_prior,maxConnProbOB2I_prior,maxConnProbGC2E_prior,maxConnProbGC2I_prior,sigmaOB2PC_prior,sigmaGC2PC_prior,observed=0)

    S = elfi.Summary(score_network, sim)

    d = elfi.Distance('euclidean',S)

    #log_d = elfi.Operation(np.log, d)


    pool = elfi.OutputPool(['connProbOB2E_prior','connProbOB2I_prior','connProbGC2E_prior','connProbGC2I_prior','sigmaOB2PC_prior','sigmaGC2PC_prior','S','d'])

    ie_maxConnProbOB2E,ie_maxConnProbOB2I,ie_maxConnProbGC2E,ie_maxConnProbGC2I,ie_sigmaOB2PC,ie_sigmaGC2PC,ie_scores = eng.load_initial_evidence_randomNet('/home/ben/phd/stfp/abc_results/gradientNet',nargout=7)

    ie_maxConnProbOB2E  = np.asarray(ie_maxConnProbOB2E)
    ie_maxConnProbOB2I  = np.asarray(ie_maxConnProbOB2I)
    ie_maxConnProbGC2E  = np.asarray(ie_maxConnProbGC2E)
    ie_maxConnProbGC2I  = np.asarray(ie_maxConnProbGC2I)
    ie_sigmaOB2PC       = np.asarray(ie_sigmaOB2PC)
    ie_sigmaGC2PC       = np.asarray(ie_sigmaGC2PC)
    ie_scores       = np.asarray(ie_scores)

    #ie_log_scores = np.log(ie_scores)

    if not ie_maxConnProbOB2E.any():
        ie = 10
        print('0 prior runs detected')
    else:
        ie = {'maxConnProbOB2E_prior': ie_maxConnProbOB2E,
              'maxConnProbOB2I_prior': ie_maxConnProbOB2I,
              'maxConnProbGC2E_prior': ie_maxConnProbGC2E,
              'maxConnProbGC2I_prior': ie_maxConnProbGC2I,
              'sigmaOB2PC_prior': ie_sigmaOB2PC,
              'sigmaGC2PC_prior': ie_sigmaGC2PC,
              'd': ie_scores}
        print(str(ie_maxConnProbOB2E.size) + ' prior runs detected... using as initial evidence')

    bolfi = elfi.BOLFI(d, batch_size=1, initial_evidence=ie, update_interval=1,
            bounds={'maxConnProbOB2E_prior':(0,1),'maxConnProbOB2I_prior':(0,1),'maxConnProbGC2E_prior':(0,1),'maxConnProbGC2I_prior':(0,1)},'sigmaOB2PC_prior':(1e-6,1000e-6),'sigmaGC2PC_prior':(1e-6,1000e-6),acq_noise_var=[0,0,0,0,0,0,0,0,0,0],pool=pool)


    posterior = bolfi.fit(n_evidence=100)

    with open(datadir / 'bolfi_result.pkl','wb') as fname:
        pickle.dump(bolfi,fname)

    bolfi.plot_state()
    bolfi.plot_discrepancy()
    plt.show(block=True)
    
if __name__ == '__main__':
    main()
