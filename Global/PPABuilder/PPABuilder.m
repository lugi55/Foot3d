function [ssmV,PCcum,MeanPCA,Eval,Modes,PPAmodes,PPCcum,MeanPPC,Model] = PPABuilder(RR,order,variance)

% INPUT

% RR:  aligned en corresponding training data ([x;y;z] * nr samples)
% order: polynomial degree of data relationships
% variance: amount of data variance to be modeled (range 0-1)

% OUTPUT

%   ssmV : the shape vectors, an M x N Matrix
%   Eval : Eigen values of the data
%   Evec : Eigen vectors of the data
%   MEAN : Mean shape vector
%   PCcum: cumulative variance explained by the SSM vectors
%   Modes: The shapemodes of the trainingdata within the shape mode%
%   PPAmodes : The polynomial responses of the PPA model
%   PPCcum: cumulative variance explained by the PPA model
%   MeanPPC: projected mean in pca components
%   Model: PPA model with calculated polynomial coefficients

%EXAMPLE: type Example or runexample2 in Command window and run
% Data for the example to illustrate PPA versus PCA in nonrigid conditions is obtained from the jumping jacks data set of the dyna model : http://dyna.is.tue.mpg.de/


%PCA BASIS
%define PCA components
[ssmV,Eval,Evec,MeanPCA,PCcum]=PCAData(RR);
%define dimensionality of PPA model to described desired variance
dimension=min(find(PCcum>variance));
%define variance
residuals=(RR-repmat(MeanPCA,1,size(RR,2)));
VarOriginal = var(residuals,1,'all');

%definition of pca shape loadings 
[p,q]=size(RR);
ssmV(:,q)=[];
PI=pinv(ssmV);

for i = 1:q    
Scaling=[RR(:,i)]-MeanPCA;
Modes(i,:)=PI*Scaling;
end

%select Modes of interest and weight them acording to the eigenvalues
[wmodes]=WeightedModes(Eval,Modes);
PCAmodes=wmodes(:,1:dimension);

%PPA EXTENSION
%define projections
PPAmodes=PCAmodes;
for k=1:dimension
    V=vandermonde(PPAmodes(:,1),order);
    Model(k).coeff=pinv(V)*PPAmodes(:,2:end);
    Model(1).PPCModes(:,k)=PPAmodes(:,1);
    PredictedTail=V*Model(k).coeff;
    PPAmodes=PPAmodes(:,2:end)-PredictedTail;      
end
MeanPPC=inversePPA(zeros(1,dimension),Eval,Model,dimension);
MeanPPC=MeanPCA+ssmV(:,1:dimension)*MeanPPC';

for k=1:dimension
 PPAmodes=  Model(1).PPCModes; 
 PPAmodestemp=zeros(size(PPAmodes));
 PPAmodestemp(:,1:k)=PPAmodes(:,1:k);
orig=inversePPA(PPAmodestemp,Eval,Model,dimension);
    for i=1:size(Modes,1)
        pcloadings=orig(i,:);
        ResTemp(i,:)=MeanPCA+ssmV(:,1:dimension)*pcloadings';
    end
    RRnew=RR-ResTemp';
    Var(1,k)=(VarOriginal-var(RRnew,1,'all'))/VarOriginal;

end
PPCcum=Var';
end

