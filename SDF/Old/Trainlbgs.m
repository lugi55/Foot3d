clc
clear

name = 'ReluSDFGrad';
obj = 'Cube';
Fcn = @SDFGradLoss;


addpath('myFun/')
addpath('LossFcn/')
addpath("Class/")


near = load(['./sdf-explorer-samples/samples/near/',obj,'.mat']);
random = load(['./sdf-explorer-samples/samples/rand/',obj,'.mat']);
surface = load(['./sdf-explorer-samples/samples/surface/',obj,'.mat']);

position = [near.position;random.position;surface.position];
distance = [near.distance;random.distance;surface.distance];
normals = [near.gradient;random.gradient;surface.gradient];
buf = rmmissing([position,distance,normals]);
position = buf(:,1:3)';
distance = buf(:,4)';
normals = buf(:,5:7)';

[~,center,scale] = normalize(distance,'range',[-1,1]);

layers = [
    featureInputLayer(3);
    fullyConnectedLayer(128);
    leakyReluLayer();
    fullyConnectedLayer(128);
    leakyReluLayer();
    fullyConnectedLayer(128);
    leakyReluLayer();
    fullyConnectedLayer(128);
    leakyReluLayer();
    fullyConnectedLayer(1);
    tanhLayer();
    functionLayer(@(X) X*scale+center)
];

net = dlnetwork(layers);


solverState = lbfgsState;
oldLoss = 1;
lossArray = ones(1,20);
diffLossArray = ones(1,20);

X = gpuArray(dlarray(position(:,1:100:end),"CB"));
N = dlarray(normals(:,1:100:end),"CB");
T = dlarray(distance(1:100:end),"CB");

%choose LossFcn
lossFcn = @(net) dlfeval(Fcn,net,X,T,N);

for iter = 1:1e4
    [net,solverState] = lbfgsupdate(net,lossFcn,solverState);
    newLoss = solverState.Loss;
    step = solverState.StepNorm;

    diffLossArray = [oldLoss-newLoss,diffLossArray(1:end-1)];
    lossArray = [newLoss,lossArray(1:end-1)];
    oldLoss = newLoss;

    if mod(iter,10)==0
        fprintf('iter: %i \t loss: %.2e \t diffLoss %.2e \t stepSize: %.2e\n',iter,mean(lossArray),mean(diffLossArray),step);
    end
    
    if mean(diffLossArray)<1e-11
        break
    end
end

%Struct for Saving
data.net = net;
data.obj = obj;
data.iter = iter;
data.lossFcn = Fcn;
data.batchSize = length(T);
data.loss = newLoss;
save(['Data/',obj,'/',name,'.mat'],'data');






