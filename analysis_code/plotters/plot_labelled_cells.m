function [meanONresp,meanOFFresp] = plot_labelled_cells(datadir,thresh)
p=load([datadir '/p.mat']); p=p.p;
on=load([datadir '/on_responses_spikes.mat']); on=on.on_responses;
off=load([datadir '/off_responses_spikes.mat']); off=off.off_responses;
onb=load([datadir '/on_baselines_spikes.mat']); onb=onb.on_baselines;
offb=load([datadir '/off_baselines_spikes.mat']); offb=offb.off_baselines;
[W,sortX] = get_weight_matrix(datadir,'GC','E');
[W2,sortX2] = get_weight_matrix(datadir,'OB','E');
W=W(sortX,:);
W2=W2(sortX2,:);
Wsum=sum(W,2,'omitnan');
W2sum=sum(W2,2,'omitnan');
gradSlope=p.gradSlope;
xs=0:.001:100; xs=xs./max(xs);
xs2=0:.001:100;
wGradient = exp(-gradSlope*xs);
wGradient2 = exp(gradSlope*(xs - 1));
x=p.xcoordsE;
y=p.ycoordsE;
[~,sortX]=sort(x);
for i=1:p.ntrials
    onResp(:,i) = on{1}{1}{i} - onb{1}{1}{i};
    offResp(:,i) = off{1}{1}{i} - offb{1}{1}{i};
    %onResp(:,i) = onb{1}{1}{i};
    %offResp(:,i) = offb{1}{1}{i};
    %onResp(:,i) = on{1}{1}{i}./onb{1}{1}{i};
    %offResp(:,i) = off{1}{1}{i}./offb{1}{1}{i};
end
meanONresp = mean(onResp,2);
meanOFFresp = mean(offResp,2);
[onWcorr,p1] = corr(meanONresp(sortX),Wsum);
[offW2corr,p2] = corr(meanOFFresp(sortX2),W2sum);
figure;
subplot(1,2,1)
scatter(meanONresp(sortX),Wsum); title(['\rho = ' num2str(onWcorr) ' p-val = ' num2str(p1)])
subplot(1,2,2)
scatter(meanOFFresp(sortX2),W2sum); title(['\rho = ' num2str(offW2corr) ' p-val = ' num2str(p2)])

rdif=meanONresp-meanOFFresp;
rdif=rdif(sortX);
for i=1:40
    rdifbinned(i)=sum(rdif((i-1)*20+1:i*20));
    Wsumbinned(i)=sum(Wsum((i-1)*20+1:i*20));
    W2sumbinned(i)=sum(W2sum((i-1)*20+1:i*20));
end
figure;
hold on; plot(rdifbinned,'k'); ylabel('\Delta FR (GC ON - GC OFF)')
xlabel('Cell IDs (x-sorted)')
yyaxis right
ylabel('Sum of GC/OB inputs')
plot(Wsumbinned,'r'); plot(W2sumbinned,'b')

figure;
hold on; plot(rdif,'k'); ylabel('\Delta FR (GC ON - GC OFF)')
xlabel('Cell IDs (x-sorted)')
yyaxis right
ylabel('Sum of GC/OB inputs')
plot(Wsum,'r'); plot(W2sum,'b')
respDif = meanOFFresp - meanONresp;
respDif(abs(respDif) < 8) = 0;
posCells=respDif>0;
negCells=respDif<0;
onTag = abs(meanONresp) > thresh;
offTag = abs(meanOFFresp) > thresh;
bothTag = (onTag+offTag)==2;
noTag = (onTag+offTag)==0;
tags(onTag) = 1;
tags(offTag) = 2;
tags(bothTag) = 3;
tags(noTag) = 4;

cmap = [1 0 0;
        0 0 1;
        1 0 1];
figure;
scatter(x(tags==4),y(tags==4),60,'k')
hold on;
scatter(x(tags < 4),y(tags < 4),60,cmap(tags(tags < 4),:),'filled')
hold on;
yyaxis right
plot(xs2,wGradient,'--r','linew',2); plot(xs2,wGradient2,'--b','linew',2)
ylabel('Fraction of max weight','fontsize',20,'fontweight','bold','color','k')
yyaxis left
xlabel('X coordinate','fontsize',20,'fontweight','bold')
ylabel('Y coordinate','fontsize',20,'fontweight','bold')

figure;
scatter(x(posCells),y(posCells),20,cmap(2,:),'filled')
hold on;
scatter(x(negCells),y(negCells),20,cmap(1,:),'filled')
yyaxis right
plot(xs2,wGradient,'r','linestyle','-','linew',2); plot(xs2,wGradient2,'b','linestyle','-','linew',2)
ylabel('Fraction of max weight')
yyaxis left
xlabel('X coordinate')
ylabel('Y coordinate')
end

