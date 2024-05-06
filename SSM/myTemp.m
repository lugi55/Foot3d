
clc
clear all
close all

zs = load("Zs.mat");
zg = load("Zg.mat");

figure
hold on
grid on
xticks(1:30)
scatter(1:30,zs.Z.extractdata,36,'filled')
scatter(1:30,zg.Z.extractdata,36,'filled')

legend('z_1','z_2')
xlabel('PCA Component')
ylabel('\sigma')



