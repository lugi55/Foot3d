
clc
clear


Fcn = @SDFGradLoss;
miniBatchSize = 1e3;

addpath('myFun/')
addpath('LossFcn/')

data = load('Foot3D\matFiles\0003_SDF.mat');



layers = [
    featureInputLayer(3);
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(128);
    reluLayer();
    fullyConnectedLayer(1);
    tanhLayer();
];

net = dlnetwork(layers);

lossHist = [];
averageGrad = [];
averageSqGrad = [];
iteration = 1;
numIterationsPerEpoch = floor(length(data.sdf)./miniBatchSize);

for epoch = 1:500
    randIdx = randperm(length(data.sdf));
    data.points = data.points(randIdx,:);
    data.sdf = data.sdf(randIdx);
    data.grad = data.grad(randIdx,:);

    for i = 1:numIterationsPerEpoch
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        [loss,grad] = dlfeval(Fcn,net,gpuArray(dlarray(data.points(idx,:)',"CB")),dlarray(data.sdf(idx),"CB"),dlarray(data.grad(idx,:)',"CB"));
        [net,vel] = adamupdate(net,grad,averageGrad,averageSqGrad,iteration);
        iteration = iteration+1;
    end
    
    if mod(epoch,1)==0
        fprintf('epoch: %i \t loss: %.2e \n',epoch,loss);
        lossHist = [lossHist,loss];
    end
end


%Struct for Saving
data.net = net;
data.epoch = epoch;
data.lossFcn = Fcn;
data.lossHist = lossHist;



