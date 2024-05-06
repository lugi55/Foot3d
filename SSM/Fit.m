
clc
clear
close all

addpath("Fun/")
addpath("../Global/SSMbuilder/")
load("Mesh/Aligned/align.mat")
temp = load("Mesh/Template/F.mat");

[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);
F = align.F;

[P,~] = readObj("Mesh/Raw/0003-A.obj");
V = SSM(ssmV,MEAN,0);
[tform,~,~] = pcregistericp(pointCloud(P),pointCloud(V),"Metric","pointToPlane");
P = P(P(:,3)<0.04,:);
P = P(P(:,1)>-0.12,:);
P = P(1:15:end,:);



Z = dlarray(zeros(30,1));
for i = 1:300
    if ismember(i,1:10:100)
        V = SSM(ssmV,MEAN,Z.extractdata);
        [~,Preg,e] = pcregistericp(pointCloud(P),pointCloud(V),"Metric","pointToPlane","InitialTransform",tform);
        P = Preg.Location;
    end
    
    [rmse,grad,d] = dlfeval(@myFun,Z,ssmV,MEAN,P);
    Z = Z-grad*40000;

    scatter(i,log10(rmse.extractdata),'r.')
    hold on
    grid on
    pause(0.01)


    % ax1 = axes();
    % ax = axes();
    % scatter3(ax1,P(:,1),P(:,2),P(:,3),5,d,'filled');
    % daspect(ax1,[1 1 1])
    % %axis(ax1,"vis3d")
    % visu(ax,Z.extractdata,ssmV,MEAN,align.F)
    % ax.Children(2).FaceAlpha =  0.45;
    % view(ax,[155 40])
    % xlim(ax,[-0.1006    0.1368]*1.3);
    % ylim(ax,[-0.0734    0.0651]*1.3);
    % zlim(ax,[-0.0835    0.0743]*1.3);
    % linkprop([ax,ax1],{'XLim','YLim','ZLim','CameraUpVector','CameraPosition','CameraTarget'});
    % clim(ax1,[0,2e-05])
    % exportgraphics(gcf,'a.gif','Append',true)
    % clf
end

% V = SSM(ssmV,MEAN,Z.extractdata);
% dist = point2trimesh('Faces',F,'Vertices',V,'QueryPoints',P,'Algorithm','linear');
% fprintf('mean dist:  %.2e\n',mean(abs(dist)))

% V = SSM(ssmV,MEAN,Z.extractdata);
% idx = knnsearch(V,P);
% for k = 1:30
%  ssmV_reshape = reshape(ssmV(:,k),[length(MEAN)/3,3]);
%  w(k) = mean(vecnorm(ssmV_reshape(idx,:),2,2))/mean(vecnorm(ssmV_reshape(:,:),2,2))
% end


% fig = figure;
% ax = axes(fig);
% scatter3(ax,P(:,1),P(:,2),P(:,3),5,'filled');
% hold(ax,"on")
% visu(ax,Z.extractdata,ssmV,MEAN,align.F)
% ax.Children(2).FaceAlpha =  0.5;
% view(ax,-25,80)
% exportgraphics(gcf,'half1.png','Resolution',300)


function [rmse,grad,d] = myFun(Z,ssmV,MEAN,P)
    V = SSM(ssmV,MEAN,Z);
    [idx] = knnsearch(V.extractdata,P);
    d = vecnorm(P-V(idx,:),2,2).^2;
    d = d.extractdata;
    rmse =  mean(vecnorm(P-V(idx,:),2,2).^2);
    grad = dlgradient(rmse,Z);
end



