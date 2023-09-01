function [X,scores] = LM_param_analysis(datadir,netName,pthresh)
surrInfo=load(['simulation_code/surrogate_info_' netName '.mat']); surrInfo=surrInfo.surrogate_info;
paramNames = surrInfo.params2vary; nParams=length(paramNames);
paramStrs = get_param_strs(paramNames);
pvar = load_all_variable_params(datadir,netName);
[scores,sub_scores] = load_scores(datadir,'no','spikes');
X = (pvar - mean(pvar,1))./std(pvar,[],1);
if (size(X,1) == length(scores)+1)
    X=X(1:end-1,:);
    pvar=pvar(1:end-1,:);
end
LM=fitlm(X,scores,'interactions');
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
for i=1:size(pvals2D,1)
    for j=(i+1):size(pvals2D,2)
        if (pvals2D(i,j) < pthresh)
            disp(['Interaction between ' paramNames{i} ' and ' paramNames{j} ' is significant'])
            disp(['Pval = ' num2str(pvals2D(i,j)) ' Coefficient = ' num2str(coeffs2D(i,j))])
            val1min=surrInfo.lower_bounds(i);
            val1max=surrInfo.upper_bounds(i);
            val2min=surrInfo.lower_bounds(j);
            val2max=surrInfo.upper_bounds(j);
            xgv=val1min:(val1max-val1min)/2000:val1max;
            ygv=val2min:(val2max-val2min)/2000:val2max;
            [Xq,Yq]=meshgrid(xgv,ygv);
            %Vq=interp2(pvar(:,i),pvar(:,j),scores,Xq,Yq);
            F=scatteredInterpolant(pvar(:,i),pvar(:,j),scores');
            figure;
            imagesc([xgv(1) xgv(end)],[ygv(1) ygv(end)],F(Xq,Yq)); colormap(jet); h=colorbar(); ylabel(h,'Score','fontsize',15,'fontweight','bold')
            hold on; scatter(pvar(:,i),pvar(:,j),'k','filled')
            caxis([0 max(scores)])
            %set(gca,'ydir','normal','xtick',1:100:size(Xq,2),'ytick',1:100:size(Xq,1),'xticklabels',num2str(xgv(1:100:end)),'yticklabels',num2str(ygv(1:100:end)))
            set(gca,'ydir','normal')
            title([paramStrs{i} ' vs. ' paramStrs{j} ' Interaction P-value = ' num2str(pvals2D(i,j))])
            xlabel(paramStrs{i},'fontsize',15,'fontweight','bold')
            ylabel(paramStrs{j},'fontsize',15,'fontweight','bold')
            set(gcf,'Position',[10 10 1200 1000])
        end
    end
end
end

