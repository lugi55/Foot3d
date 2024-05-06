
function data = trainAdamLatent(net,points,sdf,normals,Fcn,miniBatchSize,epochMax)


addpath('myFun/')
addpath('LossFcn/')
addpath("Class/")

averageGrad = [];
averageSqGrad = [];
iteration = 1;
numIterationsPerEpoch = floor(length(sdf)./miniBatchSize);
fprintf('miniBatchSize: %i \t numIterationsPerEpoch: %i \n',miniBatchSize,numIterationsPerEpoch);


for epoch = 1:epochMax
    randIdx = randperm(length(sdf));
    points = points(randIdx,:);
    sdf = sdf(randIdx);
    normals = normals(randIdx,:);

    for i = 1:numIterationsPerEpoch
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        [loss,grad] = dlfeval(Fcn,net,gpuArray(dlarray(points(idx,:)',"CB")),dlarray(sdf(idx)',"CB"),dlarray(normals(idx,:)',"CB"));
        [net,averageGrad,averageSqGrad] = adamupdate(net,grad,averageGrad,averageSqGrad,iteration);
        iteration = iteration+1;
        loss = loss.extractdata;
    end
    
    if mod(epoch,100)==0
        fprintf('epoch: %i \t loss %.2e \n',epoch,loss);
    end
end

boundingBox =  [min(points(:,1)),max(points(:,1));
                min(points(:,2)),max(points(:,2));
                min(points(:,3)),max(points(:,3))];

%Struct for Saving

data.net = net;
data.epoch = epoch;
data.lossFcn = Fcn;
data.miniBatchSize = miniBatchSize;
data.loss = loss;
data.boundingBox = boundingBox;
end