clc
clear

addpath("../../Fun/")
addpath("../../../Global/Fun")
addpath("../../../Global/SSMbuilder")
load("../../../ShoeFitter/trainData/Aligned/align.mat")
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X(:,1:10),align.Y(:,1:10),align.Z(:,1:10));


listdir = dir("../../MonteCarloTwoScanData/*");
listdir = listdir([listdir.isdir]);
listdir = listdir(3:end);


for iter = 1:length(listdir)
    close all
    pt1 = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt1.ply']);
    pt2 = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt2.ply']);
    pt1GT = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt1GT.ply']);
    pt2GT = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt2GT.ply']);
    text = fileread([listdir(iter).folder,'/',listdir(iter).name,'/data.json']);
    data = jsondecode(text);
    

    [ptGM, Z] = GM_6DOF(ssmV,MEAN,align.F,[],{pt1.Location,pt2.Location},false,false);
    
    e = myMetric_6DOF({pt1GT.Location,pt2GT.Location},ptGM);
    data.eGM10 = e;
    data.Z10 = Z.extractdata;
    jsonStr = jsonencode(data);
    fileID = fopen([listdir(iter).folder,'/',listdir(iter).name,'/data.json'], 'w+');
    fprintf(fileID, '%s', jsonStr);
    fclose(fileID);
    
    if 0
        figure()
        subplot(1,3,1)
        myPlotPC({pt1GT.Location,pt2GT.Location})
        subplot(1,3,2)
        myPlotPC({pt1.Location,pt2.Location})
        subplot(1,3,3)
        myPlotPC(ptGM)
    end
end



