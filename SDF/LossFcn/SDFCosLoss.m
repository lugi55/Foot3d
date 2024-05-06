

function [loss,gradients] = SDFCosLoss(net,X,T,N)
    Y = predict(net,X);
    netNormals = dlgradient(sum(Y,'all'),X,'EnableHigherDerivatives',true);    
    loss1 = mean(1-dot(N,netNormals,1)./(vecnorm(N,2,1).*vecnorm(netNormals,2,1)),'all');

    loss2 = l2loss(Y,T);
    loss = loss2+1e-5*loss1;
    gradients = dlgradient(loss,net.Learnables);
end