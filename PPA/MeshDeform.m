clc
clear
close all


addpath("nonrigidICP/")
addpath("Remesher/")
addpath("Fun/")


templateV = load("Mesh/Template/V.mat");
templateF = load("Mesh/Template/F.mat");
[templateV.V, templateF.F, ~, ~] = remesher(templateV.V, templateF.F, 0.002, 5);
%surfaceMeshShow(surfaceMesh(templateV.V,templateF.F),'Wireframe',true)

X = [];
Y = [];
Z = [];

listDir = dir("Mesh/Raw/*.obj");
for i = 1:length(listDir)
    disp([listDir(i).name])
    [targetV, targetF] = readObj(['Mesh/Raw/',listDir(i).name]);
    targetF(find(any(targetF),2),:) = [];
    [targetV, targetF, ~, ~] = remesher(targetV, targetF, 0.002, 2);
    %surfaceMeshShow(surfaceMesh(targetV,targetF),'Wireframe',true)
    [Vertecies,~,~] = nonrigidICPv2(targetV,templateV.V, ...
                                                targetF,templateF.F,50,1);
    
    X = [X,Vertecies(:,1)];
    Y = [Y,Vertecies(:,2)];
    Z = [Z,Vertecies(:,3)];
end

align.X = X;
align.Y = Y;
align.Z = Z;
align.F = templateF.F.F;


%save('Mesh/Aligned/align.mat','align')

