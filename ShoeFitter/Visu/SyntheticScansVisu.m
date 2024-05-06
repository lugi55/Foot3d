
clc
clear all
close all

%% Load and Build Data
addpath("../Fun/")
addpath("../../Global/WD40andTape-MatlabRenderer-2.1.0.0")
mesh = readSurfaceMesh("../trainData/05f3da88-3d48-40b3-abf1-e043fb4ec337_debug/foot_mesh_smoothed_1.ply");
mesh.transform(rigidtform3d(rotx(90),[0 0 0]))
mesh.removeVertices(find(mesh.Vertices(:,3)>=0.1)')
mesh.simplify("TargetNumFaces",4e3);


for i=1:15
    numberScans = 6;
    [pt,depthMap,Cam] = getScansShoefitter(mesh,1e-3,true);
    exportgraphics(gcf,'testAnimated.gif','Append',true);
    close all
end




%Triplor
% numberScans = 5;
% [pt,depthMap,Cam] = getScans(numberScans,mesh,10e-3,false);

%[ f, ax, h ] = setupfig( Cam, mesh.Faces, mesh.Vertices );
% set( h(2), "CData", depthMap{1} )
% scatter3(ax(3),pt{1}(:,1),pt{1}(:,2),pt{1}(:,3),'.')
% axis(ax(3),"equal")





%% Helper functions.


function [ f, ax, h ] = setupfig( Cam, faces, vertices )
%SETUPFIG Create the figure, axes, and plots for the example.
    f = figure( Color="w" );
    tl = tiledlayout( f, 1, 3, TileSpacing="compact", Padding="tight" );

    ax(1) = nexttile( tl);
    h(1) = patch( ax(1), Faces=faces, Vertices=vertices, FaceColor=[0.7,0.7,0.7], EdgeColor="none" );
    material( h(1), "dull" )
    lightangle( ax(1), -7.5, 60 )
    for i = 1:length(Cam)
        Cam{i}.plotcamera( ax(1), 0.05 )
        Cam{i}.plotframe( ax(1), 0.05, "" )
    end
    view(ax(1),35,35)
    xlim(ax(1),[-0.45 0.45])
    ylim(ax(1),[-0.45 0.45])
    zlim(ax(1),[-0.1 0.3])

    
    ax(2) = nexttile( tl );
    h(2) = imagesc( ax(2), [] );
    set( ax(2), "Colormap", flipud( gray ) )

    ax(3) = nexttile( tl );
    
    set( ax, "DataAspectRatio", [ 1 1 1 ], ...
        "XTick", [], "YTick", [], "ZTick", [], "Box", "on" )
    set( ax(2), "XLim", [ 1 Cam{1}.imageSize(1) ], ...
        "YLim", [ 1 Cam{1}.imageSize(2) ]  )
end


