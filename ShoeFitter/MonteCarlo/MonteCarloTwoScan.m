clc
clear all
close all


%% Load and Build Data
addpath("../Fun/")
addpath("../../Global/SSMbuilder/")
addpath("../../Global/WD40andTape-MatlabRenderer-2.1.0.0/")
addpath("../../Global/Fun/")
addpath("../Algorithmen/")
load("../trainData/Aligned/align.mat")
load("../trainData/templateData/toesIdx.mat")
list = dir("unknown/*_debug");

%pyenv('Version','C:/miniconda3/envs/pyMat/python.exe')
pyenv("Version","~/miniconda3/envs/pyMat/bin/python")
py.sys.setdlopenflags(int32(bitor(int64(py.os.RTLD_LAZY), int64(py.os.RTLD_DEEPBIND))));
[ssmV,Eval,Evec,MEAN,PCcum,Modes]=SSMbuilder(align.X,align.Y,align.Z);


for standartDeviation = 0:2.5e-3:1e-2
    overlap = [];
    eICP = [];
    eGM = [];

    for n = 1:length(list)    
        folderName = list(n).name;
        mesh = readSurfaceMesh(append('unknown/',folderName,'/foot_mesh_smoothed_1.ply'));
        mesh.transform(rigidtform3d(rotx(90),[0 0 0]))
        mesh.removeVertices(find(mesh.Vertices(:,3)>=0.1)')
        mesh.simplify("TargetNumFaces",1e4);
    
        for m = 1:200
            randStartYaw = rand*360;
            randOffsetYaw = randStartYaw+rand*180;
            [pt,overlap(end+1)] = getScans([randStartYaw randOffsetYaw],mesh,standartDeviation,false);
            for i=1:length(pt)
                tformGitter{i} = rigidtform3d(rotz(randn*2)*rotx(randn*2)*roty(randn*2),[randn*1e-2,randn*1e-2,randn*1e-2]);
                %tformGitter{i} = rigidtform3d(rotz(randn*2),[(rand(1,2)-0.5)*0.01,0]);
                ptGitter{i} = pctransform(pointCloud(pt{i}),tformGitter{i}).Location;
            end
            
            ptGM = GM_6DOF(ssmV,MEAN,align.F,[],ptGitter,0,0);
            eGM(end+1) = mean(myMetric_6DOF(pt,ptGM));
            
            ptICP = pairwiseICP_6DOF(ptGitter);
            eICP(end+1) = mean(myMetric_6DOF(pt,ptICP));
    
    
            % scatter(overlap(end),eGM(end),'red')
            % hold on
            % scatter(overlap(end),eICP(end),'blue')
            % pause(0.01)       
            % figure('Name','GM')
            % myPlot(ptGM)
            % figure('Name','ICP')
            % myPlot(ptICP)
        end
    end
    
    result.eICP = eICP;
    result.eGM = eGM;
    result.overlap = overlap;
    save(['result',int2str(standartDeviation*1e4),'.mat'],"result")
end


    


%% Help Functions

% Calculate Error
function e = myMetric_3DOF(pt,ptGitter)
    ptGlobal = vertcat(pt{:});
    ptGitterGlobal = vertcat(ptGitter{:});
    tformGlobal = estgeotform2d(ptGlobal(:,1:2),ptGitterGlobal(:,1:2),'rigid');
    for i = 1:length(ptGitter)
        ptGitter{i} = ptGitter{i}*rotz(tformGlobal.RotationAngle)-[tformGlobal.Translation,0];
        e(i) = mean(vecnorm(ptGitter{i}-pt{i},2,2));
    end
end

function e = myMetric_6DOF(pt,ptGitter)
    ptGlobal = vertcat(pt{:});
    ptGitterGlobal = vertcat(ptGitter{:});
    tformGlobal = estgeotform3d(ptGlobal,ptGitterGlobal,'rigid');
    for i = 1:length(ptGitter)
        ptGitter{i} = ptGitter{i}*tformGlobal.R-tformGlobal.Translation;
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






