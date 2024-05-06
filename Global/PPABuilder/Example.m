clc
clear


%reconstruct input data

%training data obtained from the Dyna public data set released by the Max
%Planck Institute
load EXAMPLE

for i=1:size(Modes,1)
        pcloadings=Modes(i,:);
        RR(i,:)=MeanPCA+ssmV*pcloadings';
end
RR=RR';

[ssmV,PCcum,MeanPCA,Eval,Modes,PPAmodes,PPCcum,MeanPPC,Model] = PPABuilder(RR,4,0.9999);
plotPPSmode(1,Model,ssmV,MeanPCA,Eval,F,1,0.95);