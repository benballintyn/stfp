import numpy as np
import scipy.stats
import matplotlib
import matplotlib.pyplot as plt
import elfi
import matlab.engine
import pickle
from pathlib import Path

eng = matlab.engine.start_matlab()
eng.addpath(eng.genpath('~/phd/stfp/abc_code/testing'))

def simulator(m,s,batch_size=1,random_state=None):
    score = eng.bolfi_tester(matlab.double([m.tolist()]),matlab.double([s.tolist()]))
    return score

m_prior = elfi.Prior('uniform',0,10)
s_prior = elfi.Prior('uniform',0,10)

sim = elfi.Simulator(simulator,m_prior,s_prior,observed=0)

def get_score(score):
    return score

S = elfi.Summary(get_score, sim)

d = elfi.Distance('euclidean',S)

log_d = elfi.Operation(np.log, d)

ie = {'m_prior': np.asarray([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), 's_prior': np.asarray([1, 1, 1, 1, 1, 1, 1, 1, 1, 1]), 'log_d': np.asarray([2, 1.6, 1.2, .8, 0, .8, 1.2, 1.6, 2, 2.4])}

pool = elfi.OutputPool(['m_prior','s_prior','sim','S','d','log_d'])

bolfi = elfi.BOLFI(log_d, batch_size=1, initial_evidence=ie, update_interval=5, bounds={'m_prior':(0,20),'s_prior':(0,20)}, acq_noise_var=[0,0],pool=pool)

posterior = bolfi.fit(n_evidence=200)

savedir = Path('/home/ben/phd/stfp/abc_results/')
with open(savedir / 'test_save.pkl','wb') as fname:
    pickle.dump(bolfi,fname)

#bolfi.plot_state()
bolfi.plot_discrepancy()
plt.show(block=True)


