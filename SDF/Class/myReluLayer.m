classdef myReluLayer < nnet.layer.Layer 

    properties
        Weights
        Bias
    end
    
    methods
        function layer = myReluLayer(numInputs,numOutputs)
            layer.Type = 'custom';
            layer.Weights = randn(numOutputs, numInputs);
            layer.Bias = randn(numOutputs, 1);
        end


        function Z = predict(layer, X)
            Z = layer.Weights * X + layer.Bias;
            Z = max(0, Z);
        end

    end
end
