clc
clear
close all


addpath("../Global/nonrigidICP/")
addpath("../Global/Remesher/")
addpath("Fun/")


templateV = load("Mesh/Template/V.mat");
templateF = load("Mesh/Template/F.mat");
[templateV.V, templateF.F, ~, ~] = remesher(templateV.V, templateF.F, 0.002, 5);
%surfaceMeshShow(surfaceMesh(templateV.V,templateF.F),'Wireframe',true)

X = [];
Y = [];
Z = [];

listDir = dir("Mesh/Raw/*.obj");
for i = 2%2:length(listDir)
    disp([listDir(i).name])
    [targetV, targetF] = readObj(['Mesh/Raw/',listDir(i).name]);
    [targetV, targetF, ~, ~] = remesher(targetV, targetF, 0.002, 2);
    %surfaceMeshShow(surfaceMesh(targetV,targetF),'Wireframe',true)
    [Vertecies,~,~] = nonrigidICPv2(targetV,templateV.V, ...
                                                targetF,templateF.F,50,1);
    
    X = [X,Vertecies(:,1)];
    Y = [Y,Vertecies(:,2)];
    Z = [Z,Vertecies(:,3)];
end

data.X = X;
data.Y = Y;
data.Z = Z;
data.F = templateF;


%save('Mesh\Aligned\data.mat','data')

