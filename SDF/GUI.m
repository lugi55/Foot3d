clc
clear
close all

%Mouse3D

data.Zdim = 3;
data.net = net

fig = uifigure("AutoResizeChildren",0);
p = uipanel(fig,"Units","normalized","Position",[0 0 0.3 1],"AutoResizeChildren",0);
pfig =  uipanel(fig,"Units","normalized","Position",[0.3 0 0.7 1],"AutoResizeChildren",0);
ax = axes(pfig);

for i = 1:data.Zdim
data.S{i}.freqSlider = uicontrol(p,'Style', 'slider', 'Min', -3, 'Max', 3, 'Value', 0, ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.05*(data.Zdim+1-i), 0.8, 0.04], ...
    'Callback', @updatePlot, ...
    'String',int2str(i));
end
p.Scrollable = "on";



data.ax = ax;
guidata(fig,data)

update(data)
view(data.ax,[145 55])


function update(data)
    V = get(data.ax, 'View');
    for i = 1:data.Zdim
       data.Z(i) = data.S{i}.freqSlider.Value;
    end
    visu(data.ax,data.Z)
    view(data.ax,V)
    rotate3d(data.ax,'on')
end

function updatePlot(src,~)
    data = guidata(src);
    update(data)
end

visu(ax,Z,net)



