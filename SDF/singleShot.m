

clc
clear

addpath("myFun/")
addpath("LossFcn/")

layers = [
    featureInputLayer(3);
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(1);
];
net = dlnetwork(layers);

sdfData = load("Foot3D/SDF/0003-A.mat");
data = trainAdam(net,sdfData.data.p,sdfData.data.sdf,sdfData.data.normals,@SDFCosLoss,1e4,5000);
drawSurface(data,50)

