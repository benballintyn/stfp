function [frs] = get_BAKS_frs(p,spks,downSampleFactor)
tvec=p.dt:(p.dt*downSampleFactor):p.trial_time;
a=4;
for i=1:length(spks) 
    b = length(spks{i})^(4/5);
    fr = BAKS(spks{i}*p.dt,tvec',a,b);
    frs(:,i) = fr;
end
end

