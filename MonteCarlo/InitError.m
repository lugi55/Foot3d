
addpath("Fun\")

listdir = dir("MonteCarloTwoScanData/*");
listdir = listdir([listdir.isdir]);
listdir = listdir(3:end);

e = [];
for iter = 1:length(listdir)

    pt1 = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt1.ply']);
    pt2 = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt2.ply']);
    pt1GT = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt1GT.ply']);
    pt2GT = pcread([listdir(iter).folder,'/',listdir(iter).name,'/pt2GT.ply']);
    text = fileread([listdir(iter).folder,'/',listdir(iter).name,'/data.json']);
    data = jsondecode(text);
    e(end+1) = myMetric_6DOF({pt1GT.Location,pt2GT.Location},{pt1.Location ,pt2.Location});


end