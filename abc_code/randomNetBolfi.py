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

def simulator(connProbOB2E, connProbOB2I, connProbGC2E, connProbGC2I,batch_size=1,random_state=None):
    
    score = eng.runRandomNetCPU(matlab.double([connProbOB2E.tolist()]), matlab.double([connProbOB2I.tolist()]), matlab.double([connProbGC2E.tolist()]), matlab.double([connProbGC2I.tolist()]))

    return score

def score_network(score):
        return score

def main():
    global eng
    datadir = Path('/home/ben/phd/stfp/abc_results/randomNet')

    eng = matlab.engine.start_matlab()

    eng.addpath(eng.genpath('~/phd/stfp/abc_code'))
    eng.addpath(eng.genpath('~/phd/easySim'))



    connProbOB2E_prior = elfi.Prior('uniform',0,.5)
    connProbOB2I_prior = elfi.Prior('uniform',0,.5)
    connProbGC2E_prior = elfi.Prior('uniform',0,.5)
    connProbGC2I_prior = elfi.Prior('uniform',0,.5)

    sim = elfi.Simulator(simulator,connProbOB2E_prior,connProbOB2I_prior,connProbGC2E_prior,connProbGC2I_prior,observed=0)

    S = elfi.Summary(score_network, sim)

    d = elfi.Distance('euclidean',S)

    #log_d = elfi.Operation(np.log, d)


    pool = elfi.OutputPool(['connProbOB2E_prior','connProbOB2I_prior','connProbGC2E_prior','connProbGC2I_prior','S','d','d'])

    ie_connProbOB2E,ie_connProbOB2I,ie_connProbGC2E,ie_connProbGC2I,ie_scores = eng.load_initial_evidence_randomNet('/home/ben/phd/stfp/abc_results/randomNet',nargout=5)

    ie_connProbOB2E  = np.asarray(ie_connProbOB2E)
    ie_connProbOB2I  = np.asarray(ie_connProbOB2I)
    ie_connProbGC2E  = np.asarray(ie_connProbGC2E)
    ie_connProbGC2I  = np.asarray(ie_connProbGC2I)
    ie_scores       = np.asarray(ie_scores)

    #ie_log_scores = np.log(ie_scores)

    if not ie_connProbOB2E.any():
        ie = 10
        print('0 prior runs detected')
    else:
        ie = {'connProbOB2E_prior': ie_connProbOB2E,
              'connProbOB2I_prior': ie_connProbOB2I,
              'connProbGC2E_prior': ie_connProbGC2E,
              'connProbGC2I_prior': ie_connProbGC2I,
              'd': ie_scores}
        print(str(ie_connProbOB2E.size) + ' prior runs detected... using as initial evidence')

    bolfi = elfi.BOLFI(d, batch_size=1, initial_evidence=ie, update_interval=1,
            bounds={'connProbOB2E_prior':(0,.5),'connProbOB2I_prior':(0,.5),'connProbGC2E_prior':(0,.5),'connProbGC2I_prior':(0,.5)},acq_noise_var=[0,0,0,0,0,0,0,0,0,0],pool=pool)


    posterior = bolfi.fit(n_evidence=100)

    with open(datadir / 'bolfi_result.pkl','wb') as fname:
        pickle.dump(bolfi,fname)

    bolfi.plot_state()
    bolfi.plot_discrepancy()
    plt.show(block=True)
    
if __name__ == '__main__':
    main()
