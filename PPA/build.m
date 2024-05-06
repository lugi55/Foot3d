clc
clear


addpath('../Global/PPABuilder/')

load('Mesh/Aligned/align.mat')

[ssmV,PCcum,MeanPCA,Eval,Modes,PPAmodes,PPCcum,MeanPPC,Model] = PPABuilder([align.X;align.Y;align.Z],2,0.9999);

plotPPSmode(1,Model,ssmV,MeanPCA,Eval,align.F,0,0.95);