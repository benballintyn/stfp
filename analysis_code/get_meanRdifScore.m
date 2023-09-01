function [score] = get_meanRdifScore(rdifs)
edges = -100:1:101;
[n,edges]=histcounts(rdifs,edges,'Normalization','pdf');
x=-100:1:100;
correctDist=normpdf(x,0,2);
score = KLDiv(n,correctDist);
end

