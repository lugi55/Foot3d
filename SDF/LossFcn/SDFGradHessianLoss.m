

function [loss,gradients] = SDFGradHessianLoss(net,X,T,N)

    Y = predict(net,X);
    gradient = dlgradient(sum(Y,'all'),X,'EnableHigherDerivatives',true);


    dgx = dlgradient(sum(vecnorm(gradient),'all'),X,'EnableHigherDerivatives',true);

    lossSDF = l2loss(Y,T);
    lossGrad = l2loss(N,gradient);
    lossHessian = l2loss(zeros(size(vecnorm(hessian))),vecnorm(hessian));

    loss = lossSDF+0.001*lossGrad+0.001*lossHessian;
    gradients = dlgradient(loss,net.Learnables);
end


