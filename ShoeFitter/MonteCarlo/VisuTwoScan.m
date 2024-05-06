
load("result0.mat")

overlap = result.overlap;
eICP = result.eICP;
eGM = result.eGM;


myErrorPlot(overlap,eICP,[0 0.4470 0.7410],'blue')

function myErrorPlot(overlap,e,color,colorString)

    edgeList = 0:0.1:1;
    idx = discretize(overlap,edgeList);
    for i = 1:10
        pd = fitdist(e(idx==i)','Lognormal')
        mode(i) = exp(pd.mu-pd.sigma^2)
        
        fzero(@(x)pd.cdf(x)-(pd.cdf(mode(i))+0.34),0)
        fzero(@(x)pd.cdf(x)-(pd.cdf(mode(i))-0.34),0)
        overlapList(i) = edgeList(i);
    end

    hold on
    %patch([overlapList,flip(overlapList)],[eMean+1*eStd,flip(eMean-1*eStd)],color,'FaceAlpha',0.4,'EdgeColor','none')
    %patch([overlapList,flip(overlapList)],[eMean+2*eStd,flip(eMean-2*eStd)],color,'FaceAlpha',0.3,'EdgeColor','none')
    %patch([overlapList,flip(overlapList)],[eMean+3*eStd,flip(eMean-3*eStd)],color,'FaceAlpha',0.2,'EdgeColor','none')
    scatter(overlap,(e),10,color)
    plot(overlapList,(mode),'LineWidth',2,'Color',colorString)
    hold on
    grid on
    xlabel('std [m]')
    ylabel('error [m]')

end