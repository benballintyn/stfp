function [accuracy] = knn_prediction(X,classes,nreps)
nObservations = size(X,1);
if (mod(nObservations,2) == 0)
    nxtr = nObservations/2;
else
    nxtr = ceil(nObservations/2);
end
for i=1:nreps
    draw = randperm(nObservations);
    Xtr = X(draw(1:nxtr),:);
    Xtst = X(draw(nxtr+1:end),:);
    newClasses = classes(draw);
    xtrclasses = newClasses(1:nxtr);
    xtstclasses = newClasses(nxtr+1:end);
    KNN = fitcknn(Xtr,xtrclasses);
    predictions = KNN.predict(Xtst);
    accuracy(i) = sum(predictions == xtstclasses')/length(xtstclasses);
end
end