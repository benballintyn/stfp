function [accuracy,MODEL] = naive_bayes_prediction(Xtr,Xtst,classes)
nclasses = max(classes);
badCells = [];
ncells=size(Xtr,2);
for i=1:nclasses
    classInds = find(classes == i);
    cellVars = var(Xtr(classInds,:));
    badCells = [badCells find(cellVars == 0)];
end
disp(['Bayes Classifier: # of bad cells = ' num2str(length(unique(badCells)))])
good_inds = setdiff(1:ncells,unique(badCells));
imagesc(Xtr)
MODEL = fitcnb(Xtr(:,good_inds),classes);
predictedClasses = predict(MODEL,Xtst(:,good_inds));
accuracy = sum(predictedClasses == classes)/length(classes);
end

