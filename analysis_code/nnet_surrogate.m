function [] = nnet_surrogate(f,lb,ub,options)
if (length(options.InitialPoints.Fval)==0)
    net=feedforwardnet;
    scorelb=f(lb);
    scoreub=f(ub);
    X = [lb ub];
    y = [scorelb scoreub];
    net=train(net,X,y);
else
    X=options.initialPoints.X';
    y=options.initialPoints.Fval;
    net=feedforwardnet;
    net=train(net,X,y);
end

for i=1:options.MaxFunctionEvaluations
   p2eval = (ub' - lb').*rand(length(lb),10000) + lb';
   for j=1:size(p2eval,2)
       for k=1:size(X,2)
           Q=[X(:,k) p2eval(:,j)];
           d = dist(Q);
           merits(k) = d(1,2);
       end
       meritScores(j) = mean(merits);
   end
   p2evalExp=net(p2eval);
   [~,scoreInds] = sort(p2evalExp);
   [~,meritInds] = sort(meritScores);
   for i=1:size(p2eval,2)
       totalScores(i) = find(scoreInds==i) + find(meritInds==i);
   end
   [~,sortedTotalScoreInds] = sort(totalScores);
   p = p2eval(:,sortedTotalScoreInds(1));
   score = f(p);
   X = [X p];
   y = [y score];
   net=train(net,X,y);
end
end