

function drawSlice(obj,res)

    surface = load(['./sdf-explorer-samples/samples/surface/',obj.obj,'.mat']);
    net = obj.net;


    boundingBox = [max(surface.position);min(surface.position)]*1.5;
    x_grid = linspace(boundingBox(2,1),boundingBox(1,1),res);
    y_grid = linspace(boundingBox(2,2),boundingBox(1,2),res);
    [X_grid,Y_grid]=meshgrid(x_grid,y_grid);
    S = predict(net,dlarray([X_grid(:),Y_grid(:),zeros(size(X_grid(:)))]',"CB"));
    S = reshape(extractdata(S),size(X_grid));
    figure()
    title('Slice')
    contour(x_grid,y_grid,S)
    hold on
    contour(x_grid,y_grid,S,[0 0],'black')
    colorbar
end