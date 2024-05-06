
clc
clear


addpath("../Global/SSMbuilder/")
load("Mesh/Aligned/align.mat")
temp = load("Mesh/Template/F.mat");

[V,F] = readObj("Mesh/Raw/0022-A.obj");
mesh = surfaceMesh(V,F);
mesh.removeDefects("unreferenced-vertices");
F = mesh.Faces;
V = mesh.Vertices;

surfaceMeshShow(surfaceMesh(V,F),'Wireframe',true);
pause(1);


[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);
%plotshapemode(1,ssmV,MEAN,align.F)

[RMSerror,ReallignedV,transform,SSMfit,EstimatedModes]=SSMfitter(MEAN,double(align.F),ssmV,V,double(F),5);
Vt = V*transform.T+transform.c;

fig = figure;
ax = axes(fig);
visu(ax,EstimatedModes,ssmV,MEAN,align.F)
hold(ax,"on")
scatter3(ax,Vt(:,1),Vt(:,2),Vt(:,3),'r.')
ax.Children(3).FaceAlpha = 0.5;

