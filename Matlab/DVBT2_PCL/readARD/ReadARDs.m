addpath('.\Classes')
addpath('D:\RadarData\Results\ARDs')
clear; clc; close all;

% User defined
plot_all = 1; % Plot 3D function 1/0
ARD_File = 'EQPilots_Guard1_Surv==UnchangedRef_21.ard';

% Colormap key
% 1 = jet
% 3 = winter
% 3 = hsv
% 4 = hot
% 5 = parula
% 6 = autum
% 7 = summer
% 8 = spring
% 9 = gray
colourMap = 0;

% Plot 2D function
figure();
oARD2 = cARD;
oARD2.readFromFile(ARD_File);
% Can use (km or m) (m/s or Hz)
oARD2.plot2D('m','Hz',0,-60);

% Plot 3D function
if plot_all == 1
    figure();
    oARD2 = cARD;
    oARD2.readFromFile(ARD_File);
    % x units, y units, z units, colormap
    oARD2.plot3D('km','Hz',0,-100,colourMap);
end