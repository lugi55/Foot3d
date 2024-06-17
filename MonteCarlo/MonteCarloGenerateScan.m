clc
clear all
close all


%% Load and Build Data
list = dir('./unknown/*_debug');
addpath("Fun/")
addpath("../Global/WD40andTape-MatlabRenderer-2.1.0.0/")
addpath("../Global/Fun/")

iter = 0;


for n = 1:length(list)    
    folderName = list(n).name;
    mesh = readSurfaceMesh(append('unknown/',folderName,'/foot_mesh_smoothed_1.ply'));
    mesh.transform(rigidtform3d(rotx(90),[0 0 0]))
    mesh.removeVertices(find(mesh.Vertices(:,3)>=0.1)')
    mesh.simplify("TargetNumFaces",1e4);

    for m = 1:200
        iter = iter+1;

        noise = rand()*1e-2;
        randStartYaw = rand*360;
        randOffsetYaw = randStartYaw+rand*180;
        [pt,overlap] = getScans([randStartYaw randOffsetYaw],mesh,noise,false);
        for i=1:length(pt)
            tformGitter{i} = rigidtform3d(rotz(2*randn)*rotx(2*randn)*roty(2*randn),[randn*5e-3,randn*5e-3,randn*5e-3]);
            %tformGitter{i} = rigidtform3d(rotz(randn*2),[(rand(1,2)-0.5)*0.01,0]);
            ptGitter{i} = pctransform(pointCloud(pt{i}),tformGitter{i}).Location;
        end
        

        mkdir(['./MonteCarloTwoScanData/',int2str(iter)]);

        pt1 = pointCloud(ptGitter{1});
        pt2 = pointCloud(ptGitter{2});
        pt1GT = pointCloud(pt{1});
        pt2GT = pointCloud(pt{2});

        pcwrite(pt1,['./MonteCarloTwoScanData/',int2str(iter),'/pt1.ply'],PLYFormat="binary");
        pcwrite(pt2,['./MonteCarloTwoScanData/',int2str(iter),'/pt2.ply'],PLYFormat="binary");
        pcwrite(pt1GT,['./MonteCarloTwoScanData/',int2str(iter),'/pt1GT.ply'],PLYFormat="binary");
        pcwrite(pt2GT,['./MonteCarloTwoScanData/',int2str(iter),'/pt2GT.ply'],PLYFormat="binary");

        metadata.overlap = overlap;
        metadata.noise = noise;
        metadata.Transfrom1 = tformGitter{1}.A;
        metadata.Transform2 = tformGitter{2}.A;
        metadata.FeetID = folderName;
        jsonStr = jsonencode(metadata);

        fileID = fopen(['./MonteCarloTwoScanData/',int2str(iter),'/data.json'], 'w');
        fprintf(fileID, '%s', jsonStr);
        fclose(fileID);

        % myPlot(pt)
    end
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







