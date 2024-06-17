clc
clear


offset = [0.07      ,0;
          0         ,-0.04;
          -0.07     ,-0.04;
          -0.07     ,0.04;
          0         ,0.04];

Folder = 'Scans/0016l/';
listDir = dir([Folder,'*Yaw.ply']);

for i=1:length(listDir)
    ptCloud = pcread([Folder,listDir(i).name]);
    [model,inIdx,outIdx] = pcfitplane(ptCloud,0.005,[-1,0,0],'Confidence',99.9);
    tform = normalRotation(model,[0;0;1]);
    ptCloud = pctransform(ptCloud,tform);
    ptCloud = pointCloud(ptCloud.Location + [0,0,model.Parameters(4)]);
    ptCloud = select(ptCloud,outIdx);
    ptCloud = select(ptCloud,ptCloud.Location(:,3)<0.09);
    ptCloud = pcdenoise(ptCloud);
    label = pcsegdist(ptCloud,0.004);
    ptCloud = select(ptCloud,label==mode(label));
    ptMean = mean(ptCloud.Location(),1);
    ptCloud = pointCloud(ptCloud.Location - [ptMean(1:2),0]);
    ptCloud = pointCloud(ptCloud.Location*rotz(180+str2double(listDir(i).name(1:3))));
    ptCloud = pointCloud(ptCloud.Location + [offset(i,:),0]);
    if(contains(Folder,'l'))
        ptCloud = pointCloud(ptCloud.Location.*[1 -1 1]); %Left to Right Foot
    end
    scatter3(ptCloud.Location(:,1),ptCloud.Location(:,2),ptCloud.Location(:,3),'.')
    xlabel("x")
    ylabel("y")
    zlabel("z")
    axis equal
    hold on

    pt{i} = double(ptCloud.Location);

end

save([Folder,'pt.mat'],'pt')





