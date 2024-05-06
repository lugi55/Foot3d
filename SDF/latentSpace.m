clc
clear

addpath("Class/")
addpath("myFun/")
addpath("LossFcn/")
listDir = dir('Foot3D/SDF/*.mat');

for i=1:length(listDir)
    sdfData{i} = load(['Foot3D/SDF/',listDir(i).name]);
    p{i} = (dlarray(sdfData{i}.data.p',"CB"));
    sdf{i} = (dlarray(sdfData{i}.data.sdf',"CB"));
    normals{i} = (dlarray(sdfData{i}.data.normals',"CB"));
end

layers = [
    featureInputLayer(3);
    latentVectorLayer([0;0;0]);
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(64);
    reluLayer();
    fullyConnectedLayer(1);
    ];
net = dlnetwork(layers);

Z = randn(3,length(listDir))*0;

solverState = lbfgsState( ...
    HistorySize=3, ...
    InitialInverseHessianFactor=1.1);

for n = 1:1000
    for i=1:length(listDir)
        net.Learnables{1,3}{1} = gpuArray(dlarray(single(Z(:,i))));
        [net,solverstate] = lbfgsupdate(net,lossFcn,solverState);
        

        %[loss(i),grad{i}] = dlfeval(@SDFCosLoss,net,p{i},sdf{i},normals{i});

        %[net,~] = sgdmupdate(net,grad{i},[],0.1);
        %Z(:,i) = net.Learnables{1,3}{1};
    end
    %gradM = meanGrad(grad);
    
    % scatter(n,Z(1,1))
    % hold on
    % pause(0.01);
    % scatter(n,mean(loss.extractdata),'b')
    % hold on
    % pause(0.01)
    % grid on
    % 
    % [net] = adamupdate(net,gradM,[]);
end

lossFcn = @(net) dlfeval(@SDFCosLoss,net,p{i},sdf{i},normals{i});

function gradOut = meanGrad(gradIn)
    for i=2:numel(gradIn)
        for j= 1:numel(gradIn{i}.Value)
            gradIn{1}.Value{j} = gradIn{1}.Value{j} + gradIn{i}.Value{j};
        end
    end
    for j= 1:numel(gradIn{i}.Value)
        gradIn{1}.Value{j} = gradIn{1}.Value{j} / numel(gradIn);
    end
    gradOut = gradIn{1};
end

