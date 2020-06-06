function [frcdf] = getFRcdf(vals,minFR,maxFR)
vals(vals>maxFR) = maxFR;
vals(vals<minFR) = minFR;
frcdf = zeros(1,(maxFR-minFR));
nvals = length(vals);
frrange = minFR:maxFR;
count = 1;
for i=frrange
    frcdf(count) = length(find(vals < i))/nvals;
    count = count+1;
end
end

