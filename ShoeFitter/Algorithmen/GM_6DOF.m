
function [ptGitter,Z] = GM_6DOF(ssmV,MEAN,F,ignoreIdx,ptGitter,outlierFlag,plotFlag)

    oldRmse = 1;
    Z = dlarray(zeros(50,1));
    for i = 1:250
        ptGitter = myICP(ssmV,MEAN,F,Z,ignoreIdx,ptGitter,outlierFlag);
        [Z,rmseDist] = mySGDupdate(Z,ssmV,MEAN,F,ignoreIdx,ptGitter);
        deltaDist = oldRmse-mean(rmseDist.extractdata);
        if plotFlag
            GMPlot(gca,i,(rmseDist.extractdata))
        end
        oldRmse = mean(rmseDist.extractdata);
        disp(['iter: ',int2str(i),'  rmse Dist: ',sprintf('%0.3e',mean(rmseDist,"all")),'  delta Dist: ',sprintf('%0.3e',deltaDist)])
        if(deltaDist<2e-7) 
            break; 
        end
    end
end

%% Help Functions


% Display Info
function GMPlot(ax,iter,rmseDist)
    col = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880];
    scatter(ax,iter,rmseDist,20,col(1:length(rmseDist),:),'filled')
    hold(ax,'on')
    grid(ax,"on")
    xlabel(ax,"iter")
    ylabel(ax,"rmse")
    pause(0.001)
end


% Custom 2D-ICP  
function pt = myICP(ssmV,MEAN,F,Z,ignoreIdx,pt,outlierFlag)
    V = SSM(ssmV,MEAN,Z);
    surface = surfaceMesh(V.extractdata,F);
    computeNormals(surface,"vertex");
    
    for i=1:length(pt)
        [N(i),d,pt{i}] = myICPsub(surface,pt{i},ignoreIdx);
        if outlierFlag
            [~,bw] = rmoutliers(d);
            pt{i}(bw,:) = [];
            [N(i),d,pt{i}] = myICPsub(surface,pt{i},ignoreIdx);
        end
    end
    disp(['ICP exit after ',int2str(N),' Steps'])
end

%Sub ICP
function [n,d,pt] = myICPsub(surface,pt,ignoreIdx)
    oldD = 1;
    for n=1:100
        [idx,d] = knnsearch(surface.Vertices,pt,'NSMethod','kdtree');

        ptBuf = pt(~ismember(idx,ignoreIdx),:);
        idx(ismember(idx,ignoreIdx)) = [];

        vecDir = surface.Vertices(idx,:)-ptBuf;
        dotProduct = dot(vecDir,surface.VertexNormals(idx,:),2);
        normalPoint = surface.Vertices(idx,:)+dotProduct.*vecDir;

        %Point2Point
        %tform = estgeotform2d(surface.Vertices(idx,1:2),pt(:,1:2),'rigid'); 

        %Point2Plane
        tform = estgeotform3d(normalPoint,ptBuf,'rigid');  
        
        pt = pt*tform.R-tform.Translation;
        if oldD-mean(d) < 1e-9
            break
        end
        oldD = mean(d);
    end
end


% SGD Update with mean Gradient
function [Z,rmseDist] = mySGDupdate(Z,ssmV,MEAN,F,ignoreIdx,pt)
    for i=1:length(pt)
        [rmseDist(i),grad(:,i),~] = dlfeval(@myFun,Z,ssmV,MEAN,F,ignoreIdx,pt{i});
    end
    Z = Z-mean(grad,2)*300;
end

% Automatic Differentiation for latent Space
function [rmseDist,grad,dist] = myFun(Z,ssmV,MEAN,F,ignoreIdx,P)
    V = SSM(ssmV,MEAN,Z);  
    %surface = surfaceMesh(V.extractdata,F);
    %computeNormals(surface,"vertex");
    [idx] = knnsearch(V.extractdata,P);
    %distN = dot(P-V(idx,:),surface.VertexNormals(idx,:),2);

    PBuf = P(~ismember(idx,ignoreIdx),:);
    idx(ismember(idx,ignoreIdx)) = [];

    dist = vecnorm((PBuf-V(idx,:)),2,2);
    rmseDist = sqrt(mean(dist.^2));
    grad = dlgradient(rmseDist,Z)';
    dist = dist.extractdata;
end
