
function [ptGitter,Z,outlierIdx] = GM_3DOF(ssmV,MEAN,F,ignoreIdx,ptGitter,outlierFlag,plotFlag)

    rmseRingBuffer = 10:-1:1;
    Z = dlarray(zeros(120,1));
    for i = 1:200

        [ptGitter,outlierIdx] = myICP(ssmV,MEAN,F,Z,ignoreIdx,ptGitter,outlierFlag);
        [Z,rmseDist] = mySGDupdate(Z,ssmV,MEAN,F,ignoreIdx,ptGitter,outlierIdx);
        if plotFlag
            GMPlot(gca,i,(rmseDist.extractdata))
        end
        rmseRingBuffer = [rmseRingBuffer(2:end),mean(rmseDist.extractdata)];
        disp(['iter: ',int2str(i),'  rmse Dist: ',sprintf('%0.3e',mean(rmseDist.extractdata)),'  delta Dist: ',sprintf('%0.3e',mean(-gradient(rmseRingBuffer)))])
        if(mean(-gradient(rmseRingBuffer))<5e-7) 
            break; 
        end
    end
end

%% Help Functions


% Display Info
function GMPlot(ax,iter,rmseDist)
    scatter(ax,iter,rmseDist,20,[0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880],'filled')
    hold(ax,'on')
    grid(ax,"on")
    xlabel(ax,"iter")
    ylabel(ax,"rmse")
    pause(0.001)
end


% Custom 2D-ICP  
function [pt,outlierIdx] = myICP(ssmV,MEAN,F,Z,ignoreIdx,pt,outlierFlag)
    V = SSM(ssmV,MEAN,Z);
    surface = surfaceMesh(V.extractdata,F);
    computeNormals(surface,"vertex");
    for i=1:length(pt)
        [N(i),d,pt{i}] = myICPsub(surface,pt{i},ignoreIdx,zeros(length(pt{i}),1));
        if outlierFlag
            [~,outlierIdx{i}] = rmoutliers(d);
            [N(i),d,pt{i}] = myICPsub(surface,pt{i},ignoreIdx,outlierIdx{i});
        else
            outlierIdx{i} = zeros(length(pt{i}),1);
        end
    end
    disp(['ICP exit after ',int2str(N),' Steps'])
end

function [n,d,pt] = myICPsub(surface,pt,ignoreIdx,outlierIdx)
    oldD = 1;
    for n=1:100
        ptBuf = pt(~outlierIdx,:);
        [idx,d] = knnsearch(surface.Vertices,ptBuf,'NSMethod','kdtree');
        ptBuf(ismember(idx,ignoreIdx),:) = [];
        idx(ismember(idx,ignoreIdx)) = [];

        tform = estgeotform2d(surface.Vertices(idx,1:2),ptBuf(:,1:2),'rigid'); 

        pt = pt*rotz(tform.RotationAngle)-[tform.Translation,0];
        if oldD-mean(d) < 1e-9
            break
        end
        oldD = mean(d);
    end
end

% SGD Update with mean Gradient
function [Z,rmseDist] = mySGDupdate(Z,ssmV,MEAN,F,ignoreIdx,pt,outlierIdx)
    for i=1:length(pt)
        [rmseDist(i),grad(:,i),~] = dlfeval(@myFun,Z,ssmV,MEAN,F,ignoreIdx,pt{i}(~outlierIdx{i},:));
    end
    Z = Z-mean(grad,2)*500;
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
