function [accuracy] = knn_cross_comparison(Xtr,Xtst,classes)
KNN = fitcknn(Xtr,classes);
[predictions] = KNN.predict(Xtst);
accuracy = sum(predictions == classes')/length(classes);
end

