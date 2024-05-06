clc
clear
close all


addpath("../Global/nonrigidICP/")
addpath("../Global/Remesher/")
addpath("Fun/")


% templateMesh = readSurfaceMesh('trainData/2b0ce86e-b246-46e2-8748-6e5278e732f0_debug/foot_mesh_smoothed_2.ply');
% templateMesh.removeVertices(find(templateMesh.Vertices(:,2)'>0.108))
% [V,F] = remesher(templateMesh.Vertices,templateMesh.Faces,0.005,2);
% templateMesh = surfaceMesh(V,F);
% surfaceMeshShow(templateMesh)
% writeSurfaceMesh(templateMesh,'templateMesh.ply')


% trisurf(templateMesh.Faces,templateMesh.Vertices(:,1),templateMesh.Vertices(:,2),templateMesh.Vertices(:,3),"FaceColor",'magenta','FaceAlpha',0.5)
% axis equal
% xlabel("x")
% ylabel("y")
% zlabel("z")


% figure
% trisurf(templateMesh.Faces,templateMesh.Vertices(:,1),templateMesh.Vertices(:,2),templateMesh.Vertices(:,3),"FaceColor",'magenta','FaceAlpha',0.5)
% hold on
% trisurf(targetMesh.Faces,targetMesh.Vertices(:,1),targetMesh.Vertices(:,2),targetMesh.Vertices(:,3),"FaceColor",'yellow','FaceAlpha',0.5)
% axis equal

templateMesh = readSurfaceMesh("trainData/templateData/templateMesh.ply");

X = [];
Y = [];
Z = [];
 
listDir = dir("trainData/Data/*_debug");


for i = 1:length(listDir)
     disp([listDir(i).name])
     targetMesh = readSurfaceMesh(['trainData/Data/',listDir(i).name,'/foot_mesh_smoothed_1.ply']);
     targetMesh = surfaceMesh([targetMesh.Vertices(:,1),-targetMesh.Vertices(:,3),targetMesh.Vertices(:,2)],targetMesh.Faces);

     [V,F] = remesher(targetMesh.Vertices,targetMesh.Faces,0.005,2);
     targetMesh = surfaceMesh(V,F);

     [Vertecies,~,~] = nonrigidICPv2(targetMesh.Vertices,templateMesh.Vertices, targetMesh.Faces,templateMesh.Faces,40,1);

     X = [X,Vertecies(:,1)];
     Y = [Y,Vertecies(:,2)];
     Z = [Z,Vertecies(:,3)];
end


align.X = X;
align.Y = Y;
align.Z = Z;
align.F = templateMesh.Faces;


save('trainData/Aligned/align.mat','align')




