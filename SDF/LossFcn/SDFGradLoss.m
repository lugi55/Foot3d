



function [loss,gradients] = SDFGradLoss(net,X,T,N)
    Y = predict(net,X);
    netNormals = dlgradient(sum(Y,'all'),X,'EnableHigherDerivatives',true);    
    loss1 = l2loss(N,netNormals);
    loss2 = l2loss(Y,T);
    loss = loss2+1e-6*loss1;
    gradients = dlgradient(loss,net.Learnables);
end




