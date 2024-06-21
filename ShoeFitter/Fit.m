clc
clear all
close all

%% Load and Build Data
addpath("Fun/")
addpath("../Global/SSMbuilder/")
Folder = 'Scans/0013/';
load([Folder,'pt.mat'])
load("trainData/Aligned/align2.mat")
load("trainData/templateData/toesIdx.mat")
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);

% GM
[ptAligned,Z,outlierIdx] = GM_3DOF(ssmV,MEAN,align.F,[],pt,1,1);
fig2 = figure();
ax2 = axes(fig2);
myPlot(ax2,ptAligned,outlierIdx,Z.extractdata,ssmV,MEAN,align.F)


%% Create PointCloud of Foot
ColMap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880];
Color = [];
for i = 1:length(ptAligned)
    colElement = ones(size(ptAligned{i})).*ColMap(i,:);
    colElement(outlierIdx{i},:) = ones(size(colElement(outlierIdx{i},:)))*0.2;
    Color = [Color;colElement];
end

ptCloud = pointCloud(vertcat(ptAligned{:}),'Color',Color);
GM = SSM(ssmV,MEAN,Z.extractdata);

%% Create Full PointCloud
load([Folder,'ptFull.mat'])
for i = 1:length(ptFull)
    tform = estgeotform3d(pt{i},ptAligned{i},'rigid');
    ptFull{i} = pctransform(pointCloud(ptFull{i}),tform);
    inIdx = findPointsInROI(ptFull{i},[-0.2 0.2 -0.2 0.2 -0.2 0.4]);
    ptFull{i} = select(ptFull{i},inIdx);
end

ColMap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880];
Color = [];
for i = 1:length(ptFull)
    colElement = ones(size(ptFull{i}.Location)).*ColMap(i,:);
    Color = [Color;colElement];
end
ptCloudFull = pointCloud(pccat([ptFull{:}]).Location,'Color',Color);


%% reflect if left Foot
if(contains(Folder,'l'))
    ptCloud = pointCloud(ptCloud.Location.*[1 -1 1],'Color',Color);
    ptCloudFull = pointCloud(ptCloudFull.Location.*[1 -1 1],'Color',Color);
    GM = GM .* [1 -1 1];
    align.F = [align.F(:,2),align.F(:,1),align.F(:,3)];
end

GMMesh = surfaceMesh(GM,align.F);
pcwrite(ptCloud,[Folder,'pcFoot.ply']);
pcwrite(ptCloudFull,[Folder,'pcFootFull.ply']);
writeSurfaceMesh(GMMesh,[Folder,'GMMesh.ply'])


%% Plot end result
function myPlot(ax,pt,outlierIdx,Z,ssmV,MEAN,F)
    for i=1:length(pt)
        scatter3(ax,pt{i}(~outlierIdx{i},1),pt{i}(~outlierIdx{i},2),pt{i}(~outlierIdx{i},3),2,"filled")
        hold(ax,"on")
    end
    for i=1:length(pt)
        scatter3(ax,pt{i}(outlierIdx{i},1),pt{i}(outlierIdx{i},2),pt{i}(outlierIdx{i},3),2,"filled","CData",[0.1,0.1,0.1])
    end
    visu(ax,Z,ssmV,MEAN,F)
    ax.Children(2).FaceAlpha = 0.2;
    axis(ax,"equal")
    grid(ax,"on")
    xlabel(ax,"x")
    ylabel(ax,"y")
    zlabel(ax,"z")
end








