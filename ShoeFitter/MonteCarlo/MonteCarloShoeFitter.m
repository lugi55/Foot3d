clc
clear all
close all


%% Load and Build Data
addpath("../Fun/")
addpath("../../Global/SSMbuilder/")
addpath("../../Global/WD40andTape-MatlabRenderer-2.1.0.0/")
addpath("../Algorithmen/")
load("../trainData/Aligned/align.mat")
load("../trainData/templateData/toesIdx.mat")
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);
%pyenv('Version','C:/miniconda3/envs/pyMat/python.exe')
pyenv("Version","~/miniconda3/envs/pyMat/bin/python")
py.sys.setdlopenflags(int32(bitor(int64(py.os.RTLD_LAZY), int64(py.os.RTLD_DEEPBIND))));
rng(1)

folder = 'unknown';

list = dir([folder,'/*_debug']);

for iter = 1:length(list)

    folderName = list(iter).name;
    mesh = readSurfaceMesh(append(folder,'/',folderName,'/foot_mesh_smoothed_1.ply'));
    mesh.transform(rigidtform3d(rotx(90),[0 0 0]))
    mesh.removeVertices(find(mesh.Vertices(:,3)>=0.09)')
    mesh.simplify("TargetNumFaces",2e4);
    
    standartDeviation = repmat(linspace(0,1e-2,11)',20,1);
    for n = 1:length(standartDeviation) 
        [pt] = getScansShoefitter(mesh,standartDeviation(n),false);
        for i=1:length(pt)
            tformGitter{i} = rigidtform3d(rotz(randn*2),[(rand(1,2)-0.5)*0.01,0]);
            ptGitter{i} = pctransform(pointCloud(pt{i}),tformGitter{i}).Location;
        end



        ptGM = GM_3DOF(ssmV,MEAN,align.F,[],ptGitter,false,false);
        eGM(n) = mean(myMetric(pt,ptGM));

        ptICP = pairwiseICP_3DOF(ptGitter);
        eICP(n) = mean(myMetric(pt,ptICP));

    
        %myPlot(ptGM)
        %exportgraphics(gca,'testAnimated.gif','Append',true);
        %cla(gca)

        fid = fopen('info/info.txt', 'a+');
        fprintf(fid, [int2str(n),'/',int2str(length(standartDeviation)),'    ',int2str(iter),'/', int2str(length(list)),'\n']);
        fclose(fid);
    end
    
    result.standartDeviation = standartDeviation;
    result.eGM = eGM;
    result.eICP = eICP;
    save(append(folder,'/',folderName,'/result.mat'),"result")
end



%% Help Functions

% Calculate Error
function e = myMetric(pt,ptGitter)
    ptGlobal = vertcat(pt{:});
    ptGitterGlobal = vertcat(ptGitter{:});
    tformGlobal = estgeotform2d(ptGlobal(:,1:2),ptGitterGlobal(:,1:2),'rigid');
    for i = 1:length(ptGitter)
        ptGitter{i} = ptGitter{i}*rotz(tformGlobal.RotationAngle)-[tformGlobal.Translation,0];
        e(i) = mean(vecnorm(ptGitter{i}-pt{i},2,2));
    end
end

% Plot Pointcloud and Surface
function myPlot(pt)
    for i=1:length(pt)
        scatter3(pt{i}(:,1),pt{i}(:,2),pt{i}(:,3),2,"filled")
        hold("on")
    end
    view(-180,90)
    axis("equal")
    axis("off")
end






