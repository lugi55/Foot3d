


function [loss,gradients] = SDFLoss(net,X,T,N)
    Y = forward(net,X);
    loss = mean((Y-T).^2,'all');
    gradients = dlgradient(loss,net.Learnables);
end