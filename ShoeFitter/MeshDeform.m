clc
clear
close all


addpath("../Global/nonrigidICP/")
addpath("../Global/Remesher/")
addpath("../Global/Fun/")
addpath("Fun/")

addpath(genpath("Fun/nicp/icp"))
addpath(genpath("Fun/nicp/geom3d-2019.09.26"))
addpath(genpath("Fun/nicp/toolbox_graph/"))
addpath(genpath('Fun/nicp/toolbox_graph/toolbox_graph/'));


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
templateMesh.computeNormals("vertex")


X = [];
Y = [];
Z = [];
 

dir1 = dir("trainData/Data/ShoeFitter/*/foot_mesh_smoothed_1.ply");
dir2 = dir("trainData/Data/FeetStl/*/*_R.stl");
dir3 = dir("trainData/Data/FeetStl/*/*_R.stl");
listDir = [dir1;dir2;dir3];

for i = 1:length(listDir)
     disp([listDir(i).name])

     if endsWith(listDir(i).name, '.ply')
         targetMesh = readSurfaceMesh([listDir(i).folder,'/',listDir(i).name]);
         targetMesh = surfaceMesh([targetMesh.Vertices(:,1),-targetMesh.Vertices(:,3),targetMesh.Vertices(:,2)],targetMesh.Faces);
         targetMesh.computeNormals("vertex")

     elseif endsWith(listDir(i).name, '_L.stl')
        [F,V] = stlread([listDir(i).folder,'/',listDir(i).name]);
        offset = max(V(:,2))/2;
        targetMesh = surfaceMesh([V(:,2)-offset,V(:,1),V(:,3)]*1e-3,F);
        targetMesh.computeNormals("vertex")

     elseif endsWith(listDir(i).name, '_R.stl')
        [F,V] = stlread([listDir(i).folder,'/',listDir(i).name]);
        offset = max(V(:,2))/2;        
        targetMesh = surfaceMesh([V(:,2)-offset,V(:,1)*-1,V(:,3)]*1e-3,F);
        targetMesh.computeNormals("vertex")
     else
         error('wrong data format')
     end


     [V,F] = remesher(targetMesh.Vertices,targetMesh.Faces,0.005,2);
     targetMesh = surfaceMesh(V,F);


     [Vertecies,~,~] = nonrigidICPv2(targetMesh.Vertices,templateMesh.Vertices, double(targetMesh.Faces),double(templateMesh.Faces),50,1);

     X = [X,Vertecies(:,1)];
     Y = [Y,Vertecies(:,2)];
     Z = [Z,Vertecies(:,3)];
end


align.X = X;
align.Y = Y;
align.Z = Z;
align.F = templateMesh.Faces;


save('trainData/Aligned/align2.mat','align')



