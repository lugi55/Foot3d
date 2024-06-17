function visu(ax,Z,ssmV,MEAN,Fdata)

    [p,~]=size(ssmV);
    s=p/3;
    
    PC=MEAN;
    for i=1:length(Z)
        PC=PC+Z(i)*ssmV(:,i);
    end
    
    PCplus(:,1)=PC(1:s,1);
    PCplus(:,2)=PC(s+1:2*s,1);
    PCplus(:,3)=PC(2*s+1:3*s,1);
    
    trisurf(Fdata,PCplus(:,1),PCplus(:,2),PCplus(:,3),'Edgecolor','none','FaceColor',[0.7, 0.7, 0.7],'Parent', ax);
    
    set(ax, 'visible', 'off')
    light(ax)
    lighting(ax,"phong")
    xlim(ax,[-0.1155    0.1670]*1.2);
    ylim(ax,[-0.0881    0.0754]*1.2);
    zlim(ax,[-0.1034    0.0909]*1.2);
    daspect(ax,[1 1 1])
    axis(ax,"vis3d")
    
    %axis(ax,"equal")
end
