function [PCAmodes] = inversePPA(ppcs,Eval,Model,dimension)

%transformation van ppa to pca
% INPUT
% ppcs : PPA loadings
% Eval : eigenvalues of pca model
% Model PPA model
% Dimension: nr of components

% OUTPUT
% PCA loadings (normalized by eigenvalue)


PCAmodes=zeros(size(ppcs,1),dimension);



for k=1:(size(ppcs,2))
    V=vandermonde(ppcs(:,k),size(Model(1).coeff,1)-1);
    PredictedTail=V*Model(k).coeff;
    PCAmodes(:,k+1:end)=PCAmodes(:,k+1:end)+PredictedTail;    
    PCAmodes(:,k)=PCAmodes(:,k)+ppcs(:,k);
end
[PCAmodes]=UnWeightedModes(Eval,PCAmodes);
end