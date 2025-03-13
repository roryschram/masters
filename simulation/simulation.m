clc; clear; close all;

% Define radar system parameters
fc = 10e9; % Carrier frequency (10 GHz)
c = 3e8;   % Speed of light (m/s)
lambda = c / fc; % Wavelength
pulseWidth = 1e-6; % Pulse width (1 microsecond)
prf = 1e3; % Pulse repetition frequency
txPower = 1e3; % Transmitted power (1 kW)

% Create a radar waveform (simple rectangular pulse)
waveform = phased.RectangularWaveform('PulseWidth', pulseWidth, 'PRF', prf);

% Define radar transmitter
transmitter = phased.Transmitter('PeakPower', txPower, 'Gain', 40);

% Define propagation medium (free space)
propagation = phased.FreeSpace('OperatingFrequency', fc, ...
    'TwoWayPropagation', false, 'SampleRate', 1/pulseWidth);

% Define the corner reflector (RCS of a trihedral reflector)
cornerReflector = phased.RadarTarget('MeanRCS', 10, 'OperatingFrequency', fc);

% Define receiver with noise
receiver = phased.ReceiverPreamp('Gain', 40, 'NoiseFigure', 10);

% Define radar and target positions
radarPos = [0; 0; 0]; % Radar at origin
targetPos = [100; 0; 0]; % Target at 100m on x-axis
radarVel = [0; 0; 0]; % Radar stationary
targetVel = [0; 0; 0]; % Reflector stationary

% Generate pulse
txSignal = waveform();

% Transmit the signal
txSignalAmp = transmitter(txSignal);

% Propagate to the target
rxSignalPropagated = propagation(txSignalAmp, radarPos, targetPos, radarVel, targetVel);

% Reflect off the corner reflector
rxSignalReflected = cornerReflector(rxSignalPropagated);

% Propagate back to radar
rxSignalReceived = propagation(rxSignalReflected, targetPos, radarPos, targetVel, radarVel);

% Receive the signal
rxFinal = receiver(rxSignalReceived);

% Plot transmitted and received signals
t = (0:length(txSignal)-1) / waveform.SampleRate;

figure;
subplot(2,1,1);
plot(t * 1e6, abs(txSignal));
title('Transmitted Pulse');
xlabel('Time (μs)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t * 1e6, abs(rxFinal));
title('Received Echo from Corner Reflector');
xlabel('Time (μs)');
ylabel('Amplitude');

sgtitle('Radar Signal Simulation with Corner Reflector');
