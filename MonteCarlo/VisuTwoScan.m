
clc
clear all
%close all

listdir = dir("MonteCarloTwoScanData/*");
listdir = listdir([listdir.isdir]);
listdir = listdir(3:end);

text = fileread([listdir(1).folder,'/',listdir(1).name,'/data.json']);
data = jsondecode(text);
keys = fieldnames(data);
disp(keys)


modes = ["eGM","eGM10"];%"eICP","eBBR_softBD","eBBR_softBBS","eBBR_F","eBBR_N"];
for modeIter = 1:length(modes)
    e = [];
    overlap = [];
    noise = [];
    for iter = 1:length(listdir)
        text = fileread([listdir(iter).folder,'/',listdir(iter).name,'/data.json']);
        data = jsondecode(text);
        try
            e(end+1) = data.(modes(modeIter));
            overlap(end+1) = data.overlap;
            noise(end+1) = data.noise;
        end
    end
    plotResult(overlap,noise,e,modes(modeIter).replace('_','-'))
    %plotComparison(overlap,e,modes(modeIter).replace('_','-'))
end




function plotComparison(overlap,e,name)

    %scatter(overlap,e*1e3,10,'filled','DisplayName',name)
    %hold on

    f = fit(overlap',e'*1e3,'smoothingspline','SmoothingParam',0.9);
    plot(0:0.01:1,f(0:0.01:1),"LineWidth",1,'DisplayName',name)
    hold on

    %set(gca,'yscale','log')
    legend
    xlabel('overlap')
    ylabel('e [mm]')
    grid on
end

function plotResult(overlap,noise,e,name)
    figure()
    f = fit(overlap',e'*1e3,'smoothingspline','SmoothingParam',0.9);
    plot(0:0.01:1,f(0:0.01:1),"LineWidth",1,'DisplayName',name)
    hold on
    scatter(flip(overlap(:)),flip(e(:))*1e3,10,flip(noise)*1e3,'filled')
    xlabel('overlap')
    ylabel('e [mm]')
    grid on
    hold on
    colorbar
    hcb = colorbar;
    hcb.Title.String = "noise [mm]";
    title(name)

    % figure()
    % scatter(flip(overlap(:)),flip(e(:)),10,flip(noise)*1e3,'filled')
    % xlabel('overlap')
    % ylabel('e [m]')
    % grid on
    % colorbar
    % hcb = colorbar;
    % hcb.Title.String = "noise [mm]";
    % title(name)
    % set(gca,'yscale','log')
end





