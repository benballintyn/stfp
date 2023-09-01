function [] = plot_meanRdifs(rdifs,xAxisLabel,plotTitle)
figure;
histogram(rdifs);
xlabel(xAxisLabel,'fontsize',15,'fontweight','bold');
ylabel('# of cells','fontsize',15,'fontweight','bold')
title(plotTitle)
end

