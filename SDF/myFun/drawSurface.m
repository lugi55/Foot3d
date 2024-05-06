



function drawSurface(data,res)

    boundingBox = data.boundingBox*1.1;

    x_grid = linspace(boundingBox(1,1),boundingBox(1,2),res);
    y_grid = linspace(boundingBox(2,1),boundingBox(2,2),res);
    z_grid = linspace(boundingBox(3,1),boundingBox(3,2),res);
    [X_grid,Y_grid,Z_grid]=meshgrid(x_grid,y_grid,z_grid);
    S = predict(data.net,dlarray([X_grid(:),Y_grid(:),Z_grid(:)]',"CB"));
    S = reshape(extractdata(S),size(X_grid));
    [faces,verts]= isosurface(X_grid,Y_grid,Z_grid,S,0);
   

    surfaceMeshShow(surfaceMesh(verts,faces),'ColorMap','summer')
end