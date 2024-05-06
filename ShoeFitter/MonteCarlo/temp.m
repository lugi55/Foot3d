
clc
clear all
close all


%% Load and Build Data
addpath("../Fun/")
addpath("../SSMbuilder/")
addpath("../../Global/WD40andTape-MatlabRenderer-2.1.0.0/")
addpath("../../Global/Fun/")
addpath("../Algorithmen/")
load("../trainData/Aligned/align.mat")
load("../trainData/templateData/toesIdx.mat")


mesh = readSurfaceMesh('unknown\0ab6c475-4b73-4083-b163-cc760a08afc7_debug\foot_mesh_smoothed_1.ply');
mesh.transform(rigidtform3d(rotx(90),[0 0 0]))
mesh.removeVertices(find(mesh.Vertices(:,3)>=0.1)')
mesh.simplify("TargetNumFaces",1e4);

for n = 1:10
    standartDeviation = 1e-3;
    randStartYaw = rand*360;
    randOffsetYaw = randStartYaw+rand*180;
    [~,overlap] = getScans([randStartYaw randOffsetYaw],mesh,standartDeviation,true);
end











