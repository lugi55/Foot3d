

addpath("../myFun/")

[V_fixed,F_fixed] = readObj('meshFiles/0003-A.obj');





% showPointCloud(pointCloud(V_fixed))
% hold on
% showPointCloud(movingReg)

listDir = dir("meshFiles/*.obj");

for i = 1:length(listDir)

    [V_moving,F_moving] = readObj(['meshFiles/',listDir(i).name]);
    [~,movingReg] = pcregistericp(pointCloud(V_moving),pointCloud(V_fixed));
    movingMesh = surfaceMesh(movingReg.Location,F_moving);
    simplify(movingMesh,SimplificationMethod="quadric-decimation");
    V = movingMesh.Vertices;
    F = movingMesh.Faces;



    randIdx = randi(length(F),1e4,1);
    [data.p,data.sdf,data.normals] = drawPoint(V(F(randIdx,1),:),V(F(randIdx,2),:),V(F(randIdx,3),:));
    save(['SDF/',listDir(i).name(1:end-4),'.mat'],'data')
end

function [p,sdf,normalVector] = drawPoint(x1,x2,x3)
    r1 = rand(length(x1),1);
    r2 = rand(length(x1),1) .* (1-r1);
    r3 = 1-r1-r2;
    p = r1.*x1+r2.*x2+r3.*x3;

    v1 = x2-x1;
    v2 = x3-x1;
    normalVector = cross(v1,v2);
    if find(vecnorm(normalVector,2,2)==0)
        a=0;
    end
    normalVector = normalVector./vecnorm(normalVector,2,2);
    sdf = randn(length(x1),1)*0.005;
    p = p+normalVector.*sdf;
end

% scatter3(data.p(:,1),data.p(:,2),data.p(:,3),5,data.sdf,'filled')
% quiver3(data.p(:,1),data.p(:,2),data.p(:,3),data.normals(:,1),data.normals(:,2),data.normals(:,3))
% axis equal