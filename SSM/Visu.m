
clc
clear
close all

addpath("Fun/")
addpath("../Global/SSMbuilder/")
load("Mesh/Aligned/align.mat")


[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);


for i = 1:30
    ax = axes();
    visu(ax,0,ssmV,MEAN,align.F)
    V = reshape(ssmV(:,i),[length(MEAN)/3,3]);
    set(ax.Children(2),'FaceColor','flat',...
        'FaceVertexCData', vecnorm(V,2,2));
    view(ax,140,40)
    text(0.1,0.9,['PCA Nr.:     ',num2str(i)],'Units','normalized')
    text(0.1,0.85,['Mean Diff.: ',sprintf('%0.2e',mean(vecnorm(V,2,2)))],'Units','normalized')
    pause(0.1)
    exportgraphics(gcf,'a.gif','Append',true)
    clf
end