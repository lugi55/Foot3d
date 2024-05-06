

function [points,depthMap,Cam] = getScansShoefitter(mesh,Noise,plotFlag) 

    Yaw=[240 300 0 60 120]+(rand(1,5)-0.5)*20;
    
    
    for i = 1:length(Yaw)
        r = rand*0.2+0.35;
        x = cosd(Yaw(i))*r;
        y = sind(Yaw(i))*r;
        z = rand*0.2;
        Cam{i} = makeCam(x,y,z,[0,0,0.05]+randn(1,3)*0.01,randn*5);
        [depthMap{i},points{i}] = runCam(Cam{i},mesh,Noise);

    end


    if plotFlag
       myPlot(mesh,Cam,depthMap,length(Yaw));
    end
end

function myPlot(mesh,Cam,depthMap,numberScans)
    fig = figure;
    tl = tiledlayout( fig, 3,5, TileSpacing="compact", Padding="tight" );
    axS = nexttile(tl,[3,3]);
    h = patch( axS, Faces=mesh.Faces, Vertices=mesh.Vertices, FaceColor=[0.7,0.7,0.7], EdgeColor="none" );
    material( h, "dull" )
    lightangle( axS, -7.5, 60 )
    for i = 1:numberScans
        Cam{i}.plotcamera(axS, 0.05)
        Cam{i}.plotframe(axS, 0.05, "")
    end
    set( axS, "DataAspectRatio", [ 1 1 1 ], "XTick", [], "YTick", [], "ZTick", [], "Box", "on" )
    axis(axS,"equal")
    xlim(axS,[-0.5,0.5])
    ylim(axS,[-0.5,0.5])
    zlim(axS,[-0.1,0.25])
    view(axS,30,30)

    for i = 1:numberScans
        ax(i) = nexttile(tl);
        h(i) = imagesc( ax(i), [] );
        set( ax(i), "Colormap", flipud( gray ) )
        set( h(i), "CData", depthMap{i} )
    end
    set(ax, "DataAspectRatio", [ 1 1 1 ], "XTick", [], "YTick", [], "ZTick", [])
end


function Cam = makeCam(x,y,z,focusPt,Roll)
    Theta = atan2d(x-focusPt(1),y-focusPt(2));
    Phi = atan2d(z-focusPt(3),sqrt((x-focusPt(1))^2+(y-focusPt(2))^2));
    PROJECTION_MATRIX = ProjectionMatrix( deg2rad(70), 1, 0.01 );
    IMAGE_SIZE = [ 200, 200];
    TRANSLATION = [x,y,z];
    ROTATION = rotz(Roll)*rotx(Phi-90)*rotz(Theta-180);
    Cam = Camera( PROJECTION_MATRIX, IMAGE_SIZE, TRANSLATION, ROTATION );
end



function [depthMap,points] = runCam(Cam,mesh,Noise)
    [ verticesImg, facesImg, idsImg ] = world2image( Cam, mesh.Vertices, mesh.Faces );
    near = Cam.projectionMatrix.decompose.near;
    directions = raycast( Cam, verticesImg(:,1:2), false );
    vertices = Cam.t + directions .* ( verticesImg(:,3) ./ near );
    [ I, depthMap ] = rasterize(Cam.imageSize, verticesImg, facesImg, idsImg');

    rays = raycast(Cam);
    rays = rays((~isnan(I(:))),:);
    rays = rays./vecnorm(rays,2,2);
    [flag, dist, ~] = TriangleRayIntersection(Cam.t, rays, vertices(facesImg(:,1),:), vertices(facesImg(:,2),:), vertices(facesImg(:,3),:));

    dist = dist(:)+randn(size(dist(:)))*Noise;
    points = rays.*dist(:);
    points = points( ~any( isnan( points ) | isinf( points ), 2 ),: );
    points = points(flag,:)+Cam.t;
end

