function [y] = shifted_sigmoid(a,b,c,d,x0,x)
y = a./(b + exp(-c*(x - x0))) - d;
end

