function [score] = bolfi_tester(m,s)
sample = normrnd(m,s,1,100);
sample_mean = mean(sample);
sample_std  = std(sample);
score = sqrt((sample_mean - 5)^2 + (sample_std - 1)^2);
end

