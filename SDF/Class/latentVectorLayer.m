classdef latentVectorLayer < nnet.layer.Layer & nnet.layer.Acceleratable 

    properties (Learnable)
        latentVector
    end
    
    methods
        function layer = latentVectorLayer(latentVector)
            layer.latentVector = latentVector;
        end

        function Z = predict(layer, X)
            Z = [X;layer.latentVector*ones(1,size(X,2))];
        end

    end
end

