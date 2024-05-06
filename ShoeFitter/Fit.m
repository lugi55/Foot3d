clc
clear all
close all

%% Load and Build Data
addpath("Fun/")
addpath("Algorithmen/")
addpath("../Global/SSMbuilder/")
Folder = 'Scans/0001/';
load([Folder,'pt.mat'])
load("trainData/Aligned/align.mat")
load("trainData/templateData/toesIdx.mat")
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);


% GM
[ptAligned,Z] = GM_3DOF(ssmV,MEAN,align.F,toesIdx,pt,1,1);
fig2 = figure();
ax2 = axes(fig2);
myPlot(ax2,ptAligned,Z.extractdata,ssmV,MEAN,align.F)


% Z = Z.extractdata;
% save([Folder,'alignPt.mat'],"pt")
% save([Folder,'Z.mat'],"Z")


%% Plot end result
function myPlot(ax,pt,Z,ssmV,MEAN,F)
    for i=1:length(pt)
        scatter3(ax,pt{i}(:,1),pt{i}(:,2),pt{i}(:,3),2,"filled")
        hold(ax,"on")
    end
    visu(ax,Z,ssmV,MEAN,F)
    ax.Children(2).FaceAlpha = 0.2;
    axis(ax,"equal")
    grid(ax,"on")
    xlabel(ax,"x")
    ylabel(ax,"y")
    zlabel(ax,"z")
end








