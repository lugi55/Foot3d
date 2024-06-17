% Plot Pointcloud and Surface
function myPlotPC(pt)
    for i=1:length(pt)
        scatter3(pt{i}(:,1),pt{i}(:,2),pt{i}(:,3),2,"filled")
        hold("on")
    end
    view(-180,90)
    axis("equal")
    axis("off")
    pause(0.02);
end