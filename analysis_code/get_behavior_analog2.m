function [p1,p2,p3] = get_behavior_analog2(datadir,thresh,group2use,linNonLin,doplot)
p=load([datadir '/p.mat']); p=p.p;
onR = load([datadir '/on_responses_spikes.mat']); onR=onR.on_responses;
offR = load([datadir '/off_responses_spikes.mat']); offR=offR.off_responses;
onB = load([datadir '/on_baselines_spikes.mat']); onB=onB.on_baselines;
offB = load([datadir '/off_baselines_spikes.mat']); offB=offB.off_baselines;

count=0;
for i=1:p.nsmells
    for j=i+1:p.nsmells
        count=count+1;
        odors2use(count,:) = [i j];
    end
end

for i=1:size(odors2use,1)
    for k = 1:2
        for j=1:p.ntrials
            rsON{k}(j,:) = onR{group2use}{odors2use(i,k)}{j};
            rsOFF{k}(j,:) = offR{group2use}{odors2use(i,k)}{j};
            rDiffON{k}(j,:) = onR{group2use}{odors2use(i,k)}{j} - onB{group2use}{odors2use(i,k)}{j};
            rDiffOFF{k}(j,:) = offR{group2use}{odors2use(i,k)}{j} - offB{group2use}{odors2use(i,k)}{j};
        end
        meanRsON{k} = mean(rsON{k},1);
        meanRsOFF{k} = mean(rsOFF{k},1);
        meanRdiffON{k} = mean(rDiffON{k},1);
        meanRdiffOFF{k} = mean(rDiffOFF{k},1);
    end
    demTaggedON = meanRsON{1} > thresh;
    demTaggedOFF = meanRsOFF{1} > thresh;
    undemTaggedON = meanRsON{2} > thresh;
    undemTaggedOFF = meanRsOFF{2} > thresh;
    demDiffTaggedON = meanRdiffON{1} > thresh;
    demDiffTaggedOFF = meanRdiffOFF{1} > thresh;
    undemDiffTaggedON = meanRdiffON{2} > thresh;
    undemDiffTaggedOFF = meanRdiffOFF{2} > thresh;
    %{
    demOFFcorr = corr(demTaggedON',demTaggedOFF');
    undemONcorr = corr(demTaggedON',undemTaggedON');
    undemOFFcorr = corr(demTaggedON',undemTaggedOFF');
    %}
    %{
    demONdemONcorr     = corr(meanRdiffON{1}',meanRdiffON{1}');
    demONdemOFFcorr    = corr(meanRdiffON{1}',meanRdiffOFF{1}');
    demONundemONcorr   = corr(meanRdiffON{1}',meanRdiffON{2}');
    demONundemOFFcorr  = corr(meanRdiffON{1}',meanRdiffOFF{2}');
    demOFFdemONcorr    = corr(meanRdiffOFF{1}',meanRdiffON{1}');
    demOFFdemOFFcorr   = corr(meanRdiffOFF{1}',meanRdiffOFF{1}');
    demOFFundemONcorr  = corr(meanRdiffOFF{1}',meanRdiffON{2}');
    demOFFundemOFFcorr = corr(meanRdiffOFF{1}',meanRdiffOFF{2}');
    %}
    %
    demONdemONcorr     = corr(demTaggedON',demTaggedON');
    demONdemOFFcorr    = corr(demTaggedON',demTaggedOFF');
    demONundemONcorr   = corr(demTaggedON',undemTaggedON');
    demONundemOFFcorr  = corr(demTaggedON',undemTaggedOFF');
    demOFFdemONcorr    = corr(demTaggedOFF',demTaggedON');
    demOFFdemOFFcorr   = corr(demTaggedOFF',demTaggedOFF');
    demOFFundemONcorr  = corr(demTaggedOFF',undemTaggedON');
    demOFFundemOFFcorr = corr(demTaggedOFF',undemTaggedOFF');
    %}
    %{
    demONdemONcorr     = corr(demDiffTaggedON',demDiffTaggedON'); %works @thresh=0-10
    demONdemOFFcorr    = corr(demDiffTaggedON',demDiffTaggedOFF');
    demONundemONcorr   = corr(demDiffTaggedON',undemDiffTaggedON');
    demONundemOFFcorr  = corr(demDiffTaggedON',undemDiffTaggedOFF');
    demOFFdemONcorr    = corr(demDiffTaggedOFF',demDiffTaggedON');
    demOFFdemOFFcorr   = corr(demDiffTaggedOFF',demDiffTaggedOFF');
    demOFFundemONcorr  = corr(demDiffTaggedOFF',undemDiffTaggedON');
    demOFFundemOFFcorr = corr(demDiffTaggedOFF',undemDiffTaggedOFF');
    %}
    %{
    demONdemONcorr     = corr(demDiffTaggedON',meanRsON{1}');
    demONdemOFFcorr    = corr(demDiffTaggedON',meanRsOFF{1}');
    demONundemONcorr   = corr(demDiffTaggedON',meanRsON{2}');
    demONundemOFFcorr  = corr(demDiffTaggedON',meanRsOFF{2}');
    demOFFdemONcorr    = corr(demDiffTaggedOFF',meanRsON{1}');
    demOFFdemOFFcorr   = corr(demDiffTaggedOFF',meanRsOFF{1}');
    demOFFundemONcorr  = corr(demDiffTaggedOFF',meanRsON{2}');
    demOFFundemOFFcorr = corr(demDiffTaggedOFF',meanRsOFF{2}');
    %}
    %{
    demONdemONcorr     = corr(meanRsON{1}(demDiffTaggedON)',meanRsON{1}(demDiffTaggedON)');
    demONdemOFFcorr    = corr(meanRsON{1}(demDiffTaggedON)',meanRsOFF{1}(demDiffTaggedON)');
    demONundemONcorr   = corr(meanRsON{1}(demDiffTaggedON)',meanRsON{2}(demDiffTaggedON)');
    demONundemOFFcorr  = corr(meanRsON{1}(demDiffTaggedON)',meanRsOFF{2}(demDiffTaggedON)');
    demOFFdemONcorr    = corr(meanRsOFF{1}(demDiffTaggedOFF)',meanRsON{1}(demDiffTaggedOFF)');
    demOFFdemOFFcorr   = corr(meanRsOFF{1}(demDiffTaggedOFF)',meanRsOFF{1}(demDiffTaggedOFF)');
    demOFFundemONcorr  = corr(meanRsOFF{1}(demDiffTaggedOFF)',meanRsON{2}(demDiffTaggedOFF)');
    demOFFundemOFFcorr = corr(meanRsOFF{1}(demDiffTaggedOFF)',meanRsOFF{2}(demDiffTaggedOFF)');
    %}
    %{
    demONdemONcorr     = corr(demTaggedON',meanRsON{1}');
    demONdemOFFcorr    = corr(demTaggedON',meanRsOFF{1}');
    demONundemONcorr   = corr(demTaggedON',meanRsON{2}');
    demONundemOFFcorr  = corr(demTaggedON',meanRsOFF{2}');
    demOFFdemONcorr    = corr(demTaggedOFF',meanRsON{1}');
    demOFFdemOFFcorr   = corr(demTaggedOFF',meanRsOFF{1}');
    demOFFundemONcorr  = corr(demTaggedOFF',meanRsON{2}');
    demOFFundemOFFcorr = corr(demTaggedOFF',meanRsOFF{2}');
    %}
    %{
    demONdemONcorr     = corr(demTaggedON',meanRsON{1}');
    demONdemOFFcorr    = corr(demTaggedON',meanRsOFF{1}');
    demONundemONcorr   = corr(demTaggedON',meanRsON{2}');
    demONundemOFFcorr  = corr(demTaggedON',meanRsOFF{2}');
    demOFFdemONcorr    = corr(demTaggedOFF',meanRsON{1}');
    demOFFdemOFFcorr   = corr(demTaggedOFF',meanRsOFF{1}');
    demOFFundemONcorr  = corr(demTaggedOFF',meanRsON{2}');
    demOFFundemOFFcorr = corr(demTaggedOFF',meanRsOFF{2}');
    %}
    %{
    demONdemONcov      = cov([demTaggedON' meanRsON{1}']); demONdemONcov=demONdemONcov(1,2);
    demONdemOFFcov     = cov([demTaggedON' meanRsOFF{1}']); demONdemOFFcov = demONdemOFFcov(1,2);
    demONundemONcov    = cov([demTaggedON' meanRsON{2}']); demONundemONcov = demONundemONcov(1,2);
    demONundemOFFcov   = cov([demTaggedON' meanRsOFF{2}']); demONundemOFFcov = demONundemOFFcov(1,2);
    demOFFdemONcov     = cov([demTaggedOFF' meanRsON{1}']); demOFFdemONcov = demOFFdemONcov(1,2);
    demOFFdemOFFcov    = cov([demTaggedOFF' meanRsOFF{1}']); demOFFdemOFFcov = demOFFdemOFFcov(1,2);
    demOFFundemONcov   = cov([demTaggedOFF' meanRsON{2}']); demOFFundemONcov=demOFFundemONcov(1,2);
    demOFFundemOFFcov  = cov([demTaggedOFF' meanRsOFF{2}']); demOFFundemOFFcov=demOFFundemOFFcov(1,2);
    %}
    demONdemONcov      = cov([demDiffTaggedON' meanRsON{1}']); demONdemONcov=demONdemONcov(1,2);
    demONdemOFFcov     = cov([demDiffTaggedON' meanRsOFF{1}']); demONdemOFFcov = demONdemOFFcov(1,2);
    demONundemONcov    = cov([demDiffTaggedON' meanRsON{2}']); demONundemONcov = demONundemONcov(1,2);
    demONundemOFFcov   = cov([demDiffTaggedON' meanRsOFF{2}']); demONundemOFFcov = demONundemOFFcov(1,2);
    demOFFdemONcov     = cov([demDiffTaggedOFF' meanRsON{1}']); demOFFdemONcov = demOFFdemONcov(1,2);
    demOFFdemOFFcov    = cov([demDiffTaggedOFF' meanRsOFF{1}']); demOFFdemOFFcov = demOFFdemOFFcov(1,2);
    demOFFundemONcov   = cov([demDiffTaggedOFF' meanRsON{2}']); demOFFundemONcov=demOFFundemONcov(1,2);
    demOFFundemOFFcov  = cov([demDiffTaggedOFF' meanRsOFF{2}']); demOFFundemOFFcov=demOFFundemOFFcov(1,2);
    %{
    demONdemONcov      = cov([meanRsON{1}(demTaggedON)' meanRsON{1}(demTaggedON)']); demONdemONcov=demONdemONcov(1,2);
    demONdemOFFcov     = cov([meanRsON{1}(demTaggedON)' meanRsOFF{1}(demTaggedON)']); demONdemOFFcov = demONdemOFFcov(1,2);
    demONundemONcov    = cov([meanRsON{1}(demTaggedON)' meanRsON{2}(demTaggedON)']); demONundemONcov = demONundemONcov(1,2);
    demONundemOFFcov   = cov([meanRsON{1}(demTaggedON)' meanRsOFF{2}(demTaggedON)']); demONundemOFFcov = demONundemOFFcov(1,2);
    demOFFdemONcov     = cov([meanRsOFF{1}(demTaggedOFF)' meanRsON{1}(demTaggedOFF)']); demOFFdemONcov = demOFFdemONcov(1,2);
    demOFFdemOFFcov    = cov([meanRsOFF{1}(demTaggedOFF)' meanRsOFF{1}(demTaggedOFF)']); demOFFdemOFFcov = demOFFdemOFFcov(1,2);
    demOFFundemONcov   = cov([meanRsOFF{1}(demTaggedOFF)' meanRsON{2}(demTaggedOFF)']); demOFFundemONcov=demOFFundemONcov(1,2);
    demOFFundemOFFcov  = cov([meanRsOFF{1}(demTaggedOFF)' meanRsOFF{2}(demTaggedOFF)']); demOFFundemOFFcov=demOFFundemOFFcov(1,2);
    %}
    
    corrs = [demONdemONcorr demONdemOFFcorr demONundemONcorr demONundemOFFcorr ...
             demOFFdemONcorr demOFFdemOFFcorr demOFFundemONcorr demOFFundemOFFcorr];
    if (sum(isnan(corrs)) > 0)
        p1 = 0;
        p2 = 0;
        p3 = 1;
        return
    end
    switch linNonLin
        case 'linear'
            % ON->ON correlations
            alpha=.6/(demONdemONcorr - demONundemONcorr);
            y = demONdemONcorr - demONundemONcorr;
            undemEatenONONcorr(i) = (1 - alpha*y)/2;
            demEatenONONcorr(i) = 1 - undemEatenONONcorr(i);
            if (undemEatenONONcorr(i) > 1)
                undemEatenONONcorr(i) = 1;
                demEatenONONcorr(i) = 0;
            elseif (undemEatenONONcorr(i) < 0)
                undemEatenONONcorr(i) = 0;
                demEatenONONcorr(i) = 1;
            end
            % ON->ON covariances
            alpha2=.6/(demONdemONcov - demONundemONcov);
            y = demONdemONcov - demONundemONcov;
            undemEatenONONcov(i) = (1 - alpha2*y)/2;
            demEatenONONcov(i) = 1 - undemEatenONONcov(i);
            if (undemEatenONONcov(i) > 1)
                undemEatenONONcov(i) = 1;
                demEatenONONcov(i) = 0;
            elseif (undemEatenONONcov(i) < 0)
                undemEatenONONcov(i) = 0;
                demEatenONONcov(i) = 1;
            end
            
            % ON->OFF correlations
            %alpha=.6/(demONdemONcorr - demONundemONcorr)
            y = demONdemOFFcorr - demONundemOFFcorr;
            undemEatenONOFFcorr(i) = (1 - alpha*y)/2;
            demEatenONOFFcorr(i) = 1 - undemEatenONOFFcorr(i);
            if (undemEatenONOFFcorr(i) > 1)
                undemEatenONOFFcorr(i) = 1;
                demEatenONOFFcorr(i) = 0;
            elseif (undemEatenONOFFcorr(i) < 0)
                undemEatenONOFFcorr(i) = 0;
                demEatenONOFFcorr(i) = 1;
            end
            % ON->OFF covariances
            %alpha=.6/(demONdemONcov - demONundemONcov);
            y = demONdemOFFcov - demONundemOFFcov;
            undemEatenONOFFcov(i) = (1 - alpha2*y)/2;
            demEatenONOFFcov(i) = 1 - undemEatenONOFFcov(i);
            if (undemEatenONOFFcov(i) > 1)
                undemEatenONOFFcov(i) = 1;
                demEatenONOFFcov(i) = 0;
            elseif (undemEatenONOFFcov(i) < 0)
                undemEatenONOFFcov(i) = 0;
                demEatenONOFFcov(i) = 1;
            end

            % OFF->ON correlations
            %alpha=.6/(demOFFdemOFFcorr - demOFFundemOFFcorr);
            y = demOFFdemONcorr - demOFFundemONcorr;
            undemEatenOFFONcorr(i) = (1 - alpha*y)/2;
            demEatenOFFONcorr(i) = 1 - undemEatenOFFONcorr(i);
            if (undemEatenOFFONcorr(i) > 1)
                undemEatenOFFONcorr(i) = 1;
                demEatenOFFONcorr(i) = 0;
            elseif (undemEatenOFFONcorr(i) < 0)
                undemEatenOFFONcorr(i) = 0;
                demEatenOFFONcorr(i) = 1;
            end
            % OFF->ON covariances
            %alpha=.6/(demOFFdemOFFcov - demOFFundemOFFcov);
            y = demOFFdemONcov - demOFFundemONcov;
            undemEatenOFFONcov(i) = (1 - alpha2*y)/2;
            demEatenOFFONcov(i) = 1 - undemEatenOFFONcov(i);
            if (undemEatenOFFONcov(i) > 1)
                undemEatenOFFONcov(i) = 1;
                demEatenOFFONcov(i) = 0;
            elseif (undemEatenOFFONcov(i) < 0)
                undemEatenOFFONcov(i) = 0;
                demEatenOFFONcov(i) = 1;
            end

            % OFF->OFF correlations
            %alpha=.6/(demOFFdemOFFcorr - demOFFundemOFFcorr);
            y = demOFFdemOFFcorr - demOFFundemOFFcorr;
            undemEatenOFFOFFcorr(i) = (1 - alpha*y)/2;
            demEatenOFFOFFcorr(i) = 1 - undemEatenOFFOFFcorr(i);
            if (undemEatenOFFOFFcorr(i) > 1)
                undemEatenOFFOFFcorr(i) = 1;
                demEatenOFFOFFcorr(i) = 0;
            elseif (undemEatenOFFOFFcorr(i) < 0)
                undemEatenOFFOFFcorr(i) = 0;
                demEatenOFFOFFcorr(i) = 1;
            end
            % OFF->OFF covariances
            %alpha=.6/(demOFFdemOFFcov - demOFFundemOFFcov);
            y = demOFFdemOFFcov - demOFFundemOFFcov;
            undemEatenOFFOFFcov(i) = (1 - alpha2*y)/2;
            demEatenOFFOFFcov(i) = 1 - undemEatenOFFOFFcov(i);
            if (undemEatenOFFOFFcov(i) > 1)
                undemEatenOFFOFFcov(i) = 1;
                demEatenOFFOFFcov(i) = 0;
            elseif (undemEatenOFFOFFcov(i) < 0)
                undemEatenOFFOFFcov(i) = 0;
                demEatenOFFOFFcov(i) = 1;
            end
        case 'nonlinear'
            % ON->ON correlations
            alpha=-log(1/.6 - 1)/(demONdemONcorr-demONundemONcorr);
            y=demONdemONcorr-demONundemONcorr;
            demEatenONONcorr(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenONONcorr(i) = 1 - demEatenONONcorr(i);
            % ON->ON covariances
            alpha=-log(1/.6 - 1)/(demONdemONcov-demONundemONcov);
            y=demONdemONcov-demONundemONcov;
            demEatenONONcov(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenONONcov(i) = 1 - demEatenONONcov(i);
            
            % ON->OFF correlations
            y=demONdemOFFcorr-demONundemOFFcorr;
            demEatenONOFFcorr(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenONOFFcorr(i) = 1 - demEatenONOFFcorr(i);
            % ON->ON covariances
            y=demONdemOFFcov-demONundemOFFcov;
            demEatenONOFFcov(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenONOFFcov(i) = 1 - demEatenONOFFcov(i);
            
            % OFF->ON correlations
            alpha=-log(1/.6 - 1)/(demOFFdemOFFcorr-demOFFundemOFFcorr);
            y=demOFFdemONcorr-demOFFundemONcorr;
            demEatenOFFONcorr(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenOFFONcorr(i) = 1 - demEatenOFFONcorr(i);
            % OFF->ON covariances
            alpha=-log(1/.6 - 1)/(demOFFdemOFFcov-demOFFundemOFFcov);
            y=demOFFdemONcov-demOFFundemONcov;
            demEatenOFFONcov(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenOFFONcov(i) = 1 - demEatenOFFONcov(i);
            
            % OFF->OFF correlations
            y=demOFFdemOFFcorr-demOFFundemOFFcorr;
            demEatenOFFOFFcorr(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenOFFOFFcorr(i) = 1 - demEatenOFFOFFcorr(i);
            % OFF->OFF covariances
            y=demOFFdemOFFcov-demOFFundemOFFcov;
            demEatenOFFOFFcov(i) = .5 + .5/(1 + exp(-alpha*y));
            undemEatenOFFOFFcov(i) = 1 - demEatenOFFOFFcov(i);
    end
end
[h1,p1]=ttest2(demEatenONOFFcorr,undemEatenONOFFcorr);
[h2,p2]=ttest2(demEatenOFFONcorr,undemEatenOFFONcorr);
[h3,p3]=ttest2(demEatenOFFOFFcorr,undemEatenOFFOFFcorr,'tail','right');

undemEatenONONcorrstd = std(undemEatenONONcorr);
demEatenONONcorrstd = std(demEatenONONcorr);
undemEatenONOFFcorrstd = std(undemEatenONOFFcorr);
demEatenONOFFcorrstd = std(demEatenONOFFcorr);
undemEatenOFFONcorrstd = std(undemEatenOFFONcorr);
demEatenOFFONcorrstd = std(demEatenOFFONcorr);
undemEatenOFFOFFcorrstd = std(undemEatenOFFOFFcorr);
demEatenOFFOFFcorrstd = std(demEatenOFFOFFcorr);

undemEatenONONcovstd = std(undemEatenONONcov);
demEatenONONcovstd = std(demEatenONONcov);
undemEatenONOFFcovstd = std(undemEatenONOFFcov);
demEatenONOFFcovstd = std(demEatenONOFFcov);
undemEatenOFFONcovstd = std(undemEatenOFFONcov);
demEatenOFFONcovstd = std(demEatenOFFONcov);
undemEatenOFFOFFcovstd = std(undemEatenOFFOFFcov);
demEatenOFFOFFcovstd = std(demEatenOFFOFFcov);

undemEatenONONcorrmean = mean(undemEatenONONcorr);
demEatenONONcorrmean = mean(demEatenONONcorr);
undemEatenONOFFcorrmean = mean(undemEatenONOFFcorr);
demEatenONOFFcorrmean = mean(demEatenONOFFcorr);
undemEatenOFFONcorrmean = mean(undemEatenOFFONcorr);
demEatenOFFONcorrmean = mean(demEatenOFFONcorr);
undemEatenOFFOFFcorrmean = mean(undemEatenOFFOFFcorr);
demEatenOFFOFFcorrmean = mean(demEatenOFFOFFcorr);

undemEatenONONcovmean = mean(undemEatenONONcov);
demEatenONONcovmean = mean(demEatenONONcov);
undemEatenONOFFcovmean = mean(undemEatenONOFFcov);
demEatenONOFFcovmean = mean(demEatenONOFFcov);
undemEatenOFFONcovmean = mean(undemEatenOFFONcov);
demEatenOFFONcovmean = mean(demEatenOFFONcov);
undemEatenOFFOFFcovmean = mean(undemEatenOFFOFFcov);
demEatenOFFOFFcovmean = mean(demEatenOFFOFFcov);

switch doplot
    case 'yes'
        x = [1 2 3 4];
        y = [demEatenONONcorrmean undemEatenONONcorrmean; ...
             demEatenONOFFcorrmean undemEatenONOFFcorrmean; ...
             demEatenOFFONcorrmean undemEatenOFFONcorrmean; ...
             demEatenOFFOFFcorrmean undemEatenOFFOFFcorrmean;];

        stds = [demEatenONONcorrstd undemEatenONONcorrstd ...
                demEatenONOFFcorrstd undemEatenONOFFcorrstd ...
                demEatenOFFONcorrstd undemEatenOFFONcorrstd ...
                demEatenOFFOFFcorrstd undemEatenOFFOFFcorrstd];
        %y = [.8 .2; mean(demEatenONOFF) mean(undemEatenONOFF); ...
        %    mean(demEatenOFFON) mean(undemEatenOFFON); mean(demEatenOFFOFF) mean(undemEatenOFFOFF)];

        %stds = [0 0 demEatenONOFFstd undemEatenONOFFstd demEatenOFFONstd undemEatenOFFONstd ...
         %       demEatenOFFOFFstd undemEatenOFFOFFstd];
        figure;
        bar(x,y); hold on;
        x2([1 3 5 7]) = x-.15;
        x2([2 4 6 8]) = x+.15;
        y2=[y(1,:) y(2,:) y(3,:) y(4,:)];
        errorbar(x2,y2,stds,'LineStyle','none','color','k')
        legend({'Demonstrated','Undemonstrated'},'location','northeast');
        ylabel('Proportion food consumed','fontsize',15,'fontweight','bold')
        xticklabels={'\textbf{Control}', ...
                     '\textbf{\begin{tabular}{c} Train: GC ON \\ \ Test: GC OFF \end{tabular}}', ...
                     '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC ON \end{tabular}}', ...
                     '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC OFF \end{tabular}}'};
        set(gca,'TickLabelInterpreter','latex','xticklabels',xticklabels)
        set(gcf,'Position',[10 10 1500 1000])
        ylim([0 1])

        x = [1 2 3 4];
        ycov = [demEatenONONcovmean undemEatenONONcovmean; ...
             demEatenONOFFcovmean undemEatenONOFFcovmean; ...
             demEatenOFFONcovmean undemEatenOFFONcovmean; ...
             demEatenOFFOFFcovmean undemEatenOFFOFFcovmean;];

        stdscov = [demEatenONONcovstd undemEatenONONcovstd ...
                demEatenONOFFcovstd undemEatenONOFFcovstd ...
                demEatenOFFONcovstd undemEatenOFFONcovstd ...
                demEatenOFFOFFcovstd undemEatenOFFOFFcovstd];
        figure;
        bar(x,ycov); hold on;
        x2([1 3 5 7]) = x-.15;
        x2([2 4 6 8]) = x+.15;
        y2=[ycov(1,:) ycov(2,:) ycov(3,:) ycov(4,:)];
        errorbar(x2,y2,stdscov,'LineStyle','none','color','k')
        legend({'Demonstrated','Undemonstrated'},'location','northeast');
        ylabel('Proportion food consumed','fontsize',15,'fontweight','bold')
        xticklabels={'\textbf{Control}', ...
                     '\textbf{\begin{tabular}{c} Train: GC ON \\ \ Test: GC OFF \end{tabular}}', ...
                     '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC ON \end{tabular}}', ...
                     '\textbf{\begin{tabular}{c} Train: GC OFF \\ \ Test: GC OFF \end{tabular}}'};
        set(gca,'TickLabelInterpreter','latex','xticklabels',xticklabels)
        set(gcf,'Position',[10 10 1500 1000])
        ylim([0 1])
end
%{
demTaggedON = meanRsON{1} >= thresh;
demTaggedOFF = meanRsOFF{1} >= thresh;
undemTaggedON = meanRsON{2} >= thresh;
undemTaggedOFF = meanRsOFF{2} >= thresh;

demOFFcorr = corr(meanRsON{1}(tagged)',meanRsOFF{1}(tagged)');
undemONcorr = corr(meanRsON{1}(tagged)',meanRsON{2}(tagged)');
undemOFFcorr = corr(meanRsON{1}(tagged)',meanRsOFF{2}(tagged)');

demOFFcorr = corr(demTaggedON',demTaggedOFF');
undemONcorr = corr(demTaggedON',undemTaggedON');
undemOFFcorr = corr(demTaggedON',undemTaggedOFF');
%}
end

