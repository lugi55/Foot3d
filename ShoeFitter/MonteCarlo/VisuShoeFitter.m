
figure
hold on

standartDeviation = [];
eGM = [];
eICP = [];

list = dir('known/*_debug/resultToes.mat');
for iter = 1%:length(list)
    load([list(iter).folder,'/',list(iter).name])
    standartDeviation = [standartDeviation,result.standartDeviation'];
    eGM = [eGM,result.eGM];
    eICP = [eICP,result.eICP];
end


myErrorPlot(standartDeviation,eICP,[0.9290, 0.6940, 0.1250],'yellow')
myErrorPlot(standartDeviation,eGM,[0 0.4470 0.7410],'blue')
lgd = legend('\sigma = 1','\sigma = 2','\sigma = 3','Sample','Mean','\sigma = 1','\sigma = 2','\sigma = 3','Sample','Mean','Location','northwest');
lgd.NumColumns = 2;
title(lgd,'ICP               GM(known)')

function myErrorPlot(standartDeviation,e,color,colorString)
    stdList = unique(standartDeviation);
    stdList = sort(stdList);
    for i = 1:length(stdList)
        eMean(i) = mean(e(standartDeviation==stdList(i)));
        eStd(i) = std(e(standartDeviation==stdList(i)));
    end
    
    patch([stdList,flip(stdList)],[eMean+1*eStd,flip(eMean-1*eStd)],color,'FaceAlpha',0.4,'EdgeColor','none')
    patch([stdList,flip(stdList)],[eMean+2*eStd,flip(eMean-2*eStd)],color,'FaceAlpha',0.3,'EdgeColor','none')
    patch([stdList,flip(stdList)],[eMean+3*eStd,flip(eMean-3*eStd)],color,'FaceAlpha',0.2,'EdgeColor','none')
    scatter(standartDeviation,e,10,color)
    plot(stdList,eMean,'LineWidth',2,'Color',colorString)
    hold on
    grid on
    xlabel('std [m]')
    ylabel('error [m]')
    ylim([0,0.02])
end