addpath('..\Classes')
addpath('D:\RadarData\IEEE Paper CAF\TwoTargets\DVBT5\ARDs')
clear; clc;% close all;

% User defined
plot_all = 1; % Plot 3D function 1/0

ARD_File = 'SimulatedTarget_test20_refNormalised_survTarget_survCancelled.ard';
% ARD_File = 'SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.ard';
% ARD_File = 'CANCELLED_SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.ard';

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
colourMap = 3;

% Plot 2D function
figure();
oARD2 = cARD;
oARD2.readFromFile(ARD_File);
% Can use (km or m) (m/s or Hz)
oARD2.plot2D('m','Hz',0,-100);

% Plot 3D function
if plot_all == 1
    figure();
    oARD2 = cARD;
    oARD2.readFromFile(ARD_File);
    % x units, y units, z units, colormap
    oARD2.plot3D('km','Hz',0,-100,colourMap);
end

% matlab2tikz('plot.tikz')