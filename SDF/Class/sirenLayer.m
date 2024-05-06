classdef sirenLayer < nnet.layer.Layer

    properties
        Weights
        Bias
    end
     
    methods
        function layer = sirenLayer(numInputs,numOutputs,first)
            layer.Type = 'custom';
            layer.Weights = unifrnd(-sqrt(6)/numInputs,sqrt(6)/numInputs,[numOutputs, numInputs]);
            if first
                layer.Weights = layer.Weights*30;
            end
            layer.Bias = zeros(numOutputs, 1);
        end

        function Z = predict(layer,X)
            Z = sin(layer.Weights*X+layer.Bias);
        end
    end
end