clc
clear all
close all


%% Load and Build Data
addpath("../Fun/")
addpath("../../Global/Fun/")
addpath("../../Global/altmany-export_fig-3.45.0.0/")
addpath("../../Global/SSMbuilder/")
Folder = '../Scans/0007/';
load([Folder,'alignPt.mat'])
load([Folder,'Z.mat'])
load("../trainData/Aligned/align.mat")
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);


fig = figure;
ax = axes(fig);

for i=1:length(pt)
    scatter3(ax,pt{i}(:,1),pt{i}(:,2),pt{i}(:,3),5,"filled")
    hold(ax,"on")
end
% visu(ax,Z,ssmV,MEAN,align.F)
% ax.Children(2).FaceAlpha = 0;
axis(ax,"equal")
axis(ax,"off")


view(ax,0,30)
gif('test1.gif','DelayTime',1/4,'resolution',150,'overwrite',true)
for yaw = 5:5:355
    view(ax,yaw,30)
    gif
    disp([int2str(yaw),'/360'])
end

view(ax,0,90)
exportgraphics(ax,"top1.jpeg")




%%
% dirList = dir([Folder,'*/foot_pc_colored.ply']);
% ptCloud = pcread([dirList.folder,'/',dirList.name]);
% pt = ptCloud.Location;
% 
% 
% fig = figure;
% ax = axes(fig);
% scatter3(ax,pt(:,1),-pt(:,3),pt(:,2),0.7,"filled","CData",ptCloud.Color)
% 
% daspect(ax,[1 1 1])
% axis(ax,"vis3d")
% axis(ax,"off")
% startYaw = -120;
% view(ax,startYaw,30)
% 
% gif('test2.gif','DelayTime',1/4,'resolution',150,'overwrite',true)
% for yaw = startYaw+5:5:startYaw+355
%     view(ax,yaw,30)
%     gif
%     disp([int2str(yaw-startYaw),'/360'])
% end
% 
% view(ax,startYaw,90)
% exportgraphics(ax,"top2.jpeg")
