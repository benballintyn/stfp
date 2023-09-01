function [] = plot_param_slice(datadir,netName,param1,param2)
surrInfo=load(['simulation_code/surrogate_info_' netName '.mat']); surrInfo=surrInfo.surrogate_info;
paramNames = surrInfo.params2vary; nParams=length(paramNames);
paramStrs = get_param_strs(paramNames);
pvar = load_all_variable_params(datadir,netName);
[scores,sub_scores] = load_scores(datadir,'no','spikes');
X = (pvar - mean(pvar,1))./std(pvar,[],1);
if (size(X,1) > length(scores))
    X = X(1:end-1,:);
    pvar = pvar(1:end-1,:);
end
LM=fitlm(X,scores','interactions');

coeffPvals=LM.Coefficients.pValue;
coeffPvals=coeffPvals(2:end); % get rid of intercept value
pvals1D=coeffPvals(1:nParams);
pvals2D=ones(nParams);
pvals2D=triu(pvals2D);
pvals2D(logical(eye(size(pvals2D))))=0;
inds2D=find(pvals2D' == 1);
coeffs2D = zeros(nParams);
for i=(nParams+1):length(coeffPvals)
    pvals2D(inds2D(i-nParams)) = coeffPvals(i);
    coeffs2D(inds2D(i-nParams)) = LM.Coefficients.Estimate(i);
end
pvals2D=pvals2D';
coeffs2D=coeffs2D';

val1min=surrInfo.lower_bounds(param1);
val1max=surrInfo.upper_bounds(param1);
val2min=surrInfo.lower_bounds(param2);
val2max=surrInfo.upper_bounds(param2);
xgv=val1min:(val1max-val1min)/1000:val1max;
ygv=val2min:(val2max-val2min)/1000:val2max;
[Xq,Yq]=meshgrid(xgv,ygv);
F=scatteredInterpolant(pvar(:,param1),pvar(:,param2),scores');
figure;
imagesc([xgv(1) xgv(end)],[ygv(1) ygv(end)],F(Xq,Yq)); colormap(jet); h=colorbar(); ylabel(h,'Score','fontsize',20,'fontweight','bold')
hold on; scatter(pvar(:,param1),pvar(:,param2),'k','filled')
caxis([0 max(scores)])
set(gca,'ydir','normal','fontsize',15)
title([paramStrs{param1} ' vs. ' paramStrs{param2} ' Interaction P-value = ' num2str(pvals2D(param1,param2))])
xlabel(paramStrs{param1},'fontsize',25,'fontweight','bold')
ylabel(paramStrs{param2},'fontsize',25,'fontweight','bold')
set(gcf,'Position',[10 10 1200 1000])
end

