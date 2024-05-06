function [error,Reallignedsource,transform]=rigidICP(target,source,flag,Indices_edgesS,Indices_edgesT)

% This function rotates, translates and scales a 3D pointcloud "source" of N*3 size (N points in N rows, 3 collumns for XYZ)
% to fit a similar shaped point cloud "target" again of N by 3 size
% 
% The output shows the minimized value of dissimilarity measure in "error", the transformed source data set and the 
% transformation, rotation, scaling and translation in transform.T, transform.b and transform.c such that
% Reallignedsource = b*source*T + c;


if flag==0
[Prealligned_source,Prealligned_target,transformtarget ]=Preall(target,source);
else
    Prealligned_source=source;
    Prealligned_target=target;
end

disp('error')
errortemp(1,:)=100000;
index=2;
[errortemp(index,:),Reallignedsourcetemp]=ICPmanu_allign2(Prealligned_target,Prealligned_source,Indices_edgesS,Indices_edgesT);

while (errortemp(index-1,:)-errortemp(index,:))>0.000001
    [errortemp(index+1,:),Reallignedsourcetemp]=ICPmanu_allign2(Prealligned_target,Reallignedsourcetemp,Indices_edgesS,Indices_edgesT);
    index=index+1;
    d=errortemp(index,:)

    %plot of the meshes
    % h=trisurf(sourceF,Reallignedsourcetemp(:,1),Reallignedsourcetemp(:,2),Reallignedsourcetemp(:,3),0.3,'Edgecolor','none');
    % hold
    % light
    % lighting phong;
    % set(gca, 'visible', 'off')
    % set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);
    % trisurf(targetF,target(:,1),target(:,2),target(:,3),'Facecolor','m','Edgecolor','none');
    % alpha(0.6)
    % pause(0.1)
    % view([155 25])
    % exportgraphics(gcf,'c.gif','Append',true);
    % clf();
end

error=errortemp(index,:);

if flag==0
Reallignedsource=Reallignedsourcetemp*transformtarget.T+repmat(transformtarget.c(1,1:3),length(Reallignedsourcetemp(:,1)),1);
[d,Reallignedsource,transform] = procrustes(Reallignedsource,source);
else
   [d,Reallignedsource,transform] = procrustes(Reallignedsourcetemp,source);
end
