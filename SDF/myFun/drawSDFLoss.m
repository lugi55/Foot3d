




function loss = drawSDFLoss(obj,res)

    

    surface = load(['./sdf-explorer-samples/samples/surface/',obj.obj,'.mat']);
    net = obj.net;


    boundingBox = [max(surface.position);min(surface.position)]*1.2;
    x_grid = linspace(boundingBox(2,1),boundingBox(1,1),res);
    y_grid = linspace(boundingBox(2,2),boundingBox(1,2),res);
    z_grid = linspace(boundingBox(2,3),boundingBox(1,3),res);
    [X_grid,Y_grid,Z_grid]=meshgrid(x_grid,y_grid,z_grid);
    S = predict(net,dlarray([X_grid(:),Y_grid(:),Z_grid(:)]',"CB"));
    S = reshape(extractdata(S),size(X_grid));
    [faces,verts]= isosurface(X_grid,Y_grid,Z_grid,S,0);
    

    idx = knnsearch(surface.position,verts);
    dist = vecnorm(verts-surface.position(idx,:),2,2);
    loss = mean(dist);

    figure()
    trisurf(faces,verts(:,1),verts(:,2),verts(:,3),dist,'lineStyle','none')
    xlim(flip(boundingBox(:,1)))
    ylim(flip(boundingBox(:,2)))
    zlim(flip(boundingBox(:,3)))
    shading interp;
    axis("equal")
    colorbar
end