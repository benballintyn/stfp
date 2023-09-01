function [frs] = convert_spikes2fr(p,spks,window,downsampleFactor)
%window=window/p.dt;
%w = gausswin(window);
alpha=1/window;
tau=-1000:1:1000;
w=(alpha^2)*tau.*exp(-alpha*tau); %alpha function
w(w<0) = 0;
maxT = p.trial_time/p.dt;
frs = zeros(length(spks),maxT);
for i=1:length(spks)
    spikes=zeros(1,maxT); spikes(spks{i}) = 1;
    frs(i,:) = conv(spikes,w,'same');
end
frs = downsample(frs',downsampleFactor);
frs = frs./p.dt;
end

