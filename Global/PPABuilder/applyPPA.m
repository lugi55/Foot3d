function [PPAmodes] = applyPPA(pcas,Eval,Model,dimension)

%function to derive nonlinear respondings from fitted pca components. 
%INPUT
%pcas gauusian distributed PC loadings (normalized by eigenvalue)
%Eval Eigenvalues of PCA model
%Model: PPA model
%dimension: nr of pc/ppa components

%OUTPUT
% PPA loadings

[pcas]=WeightedModes(Eval,pcas);
PPAmodes=zeros(size(pcas,1),dimension);
order=size(Model(1).coeff,1)-1;
for k=1:(dimension)
    PPAmodes(:,k)=pcas(:,k);
    V=vandermonde(pcas(:,k),order);
    PredictedTail=V*Model(k).coeff;
    pcas(:,k+1:end)=pcas(:,k+1:end)-PredictedTail;      
end
end