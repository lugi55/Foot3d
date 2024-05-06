
clc
clear
close all

addpath("Fun/")
addpath("../Global/SSMbuilder/")
load("Mesh/Aligned/align.mat")
temp = load("Mesh/Template/F.mat");
[P,~] = readObj("Mesh/Raw/0005-A.obj");

color = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];

P1 = P(P(:,3)<0.04,:);
P1 = P1(P1(:,1)<-0.01,:);
P1 = P1(1:15:end,:);

P2 = P(P(:,3)<0.04,:);
P2 = P2(P2(:,1)>0.01,:);
P2 = P2(1:15:end,:);

P3 = P(P(:,3)<0.04,:);
P3 = P3(P3(:,2)<0,:);
P3 = P3(1:15:end,:);

Pcell = {P1,P2,P3};

[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);
F = align.F;

Z = dlarray(zeros(30,1));
for i = 1:500
    if ismember(i,1:10:100)
        V = SSM(ssmV,MEAN,Z.extractdata);
        for n=1:length(Pcell)
            [~,Preg,~] = pcregistericp(pointCloud(Pcell{n}),pointCloud(V),"Metric","pointToPlane");
            Pcell{n} = Preg.Location;
        end
    end
    
    for n=1:length(Pcell)
        [rmse(n),grad(:,n),~] = dlfeval(@myFun,Z,ssmV,MEAN,Pcell{n});
    end

    Z = Z-mean(grad,2)*40000;

    for n=1:length(Pcell)
        hold on
        grid on
        scatter(i,log10(rmse(n).extractdata),'filled','MarkerFaceColor',color(n,:))
    end
    pause(0.01)


    % fig = figure;
    % ax = axes(fig);
    % hold(ax,"on")
    % for n=1:length(Pcell)
    %     scatter3(ax,Pcell{n}(:,1),Pcell{n}(:,2),Pcell{n}(:,3),5,'filled');
    % end
    % visu(ax,Z.extractdata,ssmV,MEAN,align.F)
    % ax.Children(2).FaceAlpha =  0.5;
    % view(ax,-25,80)
    % pause(0.3)
    % exportgraphics(gcf,'a.gif','Append',true)
    % clf
end

% V = SSM(ssmV,MEAN,Z.extractdata);
% dist = point2trimesh('Faces',F,'Vertices',V,'QueryPoints',P,'Algorithm','linear');
% fprintf('mean dist:  %.2e\n',mean(abs(dist)))

fig = figure;
ax = axes(fig);
hold(ax,"on")
for n=1:length(Pcell)
    scatter3(ax,Pcell{n}(:,1),Pcell{n}(:,2),Pcell{n}(:,3),5,'filled');
end
%visu(ax,Z.extractdata,ssmV,MEAN,align.F)
%ax.Children(2).FaceAlpha =  0.5;
view(ax,-25,80)
%exportgraphics(gcf,'half1.png','Resolution',300)



function [rmse,grad,d] = myFun(Z,ssmV,MEAN,P)
    V = SSM(ssmV,MEAN,Z);
    [idx] = knnsearch(V.extractdata,P);
    d = vecnorm(P-V(idx,:),2,2).^2;
    d = d.extractdata;
    rmse =  mean(vecnorm(P-V(idx,:),2,2).^2);
    grad = dlgradient(rmse,Z);
end



