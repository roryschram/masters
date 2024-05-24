function SurvDataJam = DVBT2_jammer( RefData, SurvData, jam, DVBT2, C, RCF, TxToRefRxDistance_m, plotFigures )
    fprintf('Inserting jamming signal..\n\n')
    
    % Create surveillance vector
    CompleteJamSignal = zeros(length(SurvData),1);
    
%     Ncarriers = DVBT2.C_PS; % Total number of active carriers within a symbol
%     Npilots = length(DVBT2.SPLoc); % Total number of scattered pilots (SP) within a symbol
       
    % Insert jamming signal into surveillance channel
    for i = 1:length(jam)
        % Reset pilot vector
        Pilots = zeros(length(DVBT2.PilotMap),1);
    
        ShiftRange = jam(i).delayRange - TxToRefRxDistance_m;
        ShiftAmount = ceil((ShiftRange/C)*RCF.m_Fs_Hz);

        delay = zeros(1,ShiftAmount);
        td = 0:1/RCF.m_Fs_Hz:(length(SurvData)-1)/RCF.m_Fs_Hz;
        
        % Add pilots to it where required
        Pilots((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(jam(i).SymbolStart-1)*(DVBT2.symbol)+(jam(i).SymbolStart-1)*(DVBT2.guard)):(DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(jam(i).SymbolEnd-1)*(DVBT2.symbol)+(jam(i).SymbolEnd-1)*(DVBT2.guard)+DVBT2.symbol-1)) = ...
            DVBT2.PilotMap((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(jam(i).SymbolStart-1)*(DVBT2.symbol)+(jam(i).SymbolStart-1)*(DVBT2.guard)):(DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(jam(i).SymbolEnd-1)*(DVBT2.symbol)+(jam(i).SymbolEnd-1)*(DVBT2.guard)+DVBT2.symbol-1));
        
        % Add delay and Doppler shift to create jamming signal
        JamSignal = (([delay Pilots(1:end-length(delay)).']).*exp(1i*2*pi*jam(i).fd*td)).';
        
        % Add jamming signal to surveillance signal 
        CompleteJamSignal = CompleteJamSignal + JamSignal;
    end
    
    % Output
    SurvDataJam = CompleteJamSignal;
    
    if plotFigures == 1
        
        samples = max(size(SurvData)); % Determine the number of samples
        T = RCF.m_Fs_Hz/(samples-1); % Bin size
        bins = ((RCF.m_Fc_Hz-RCF.m_Fs_Hz/2):T:(RCF.m_Fc_Hz+RCF.m_Fs_Hz/2)).'; % Vector containing each bin in frequency steps
        
        DataSymbols = DVBT2.nSymbols-1; % Select how many sumbols you want to look at (60 QAM symbols per Frame)
        for i = 1:DataSymbols
            demod_pilots(:,i) = abs(fftshift(fft(CompleteJamSignal((DVBT2.P1Length + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard)) : (DVBT2.P1Length + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + DVBT2.symbol-1)))));
        end
        
        figure()
        imagesc(demod_pilots)
        colormap jet
        title('Complete Jammer Pilot Map')
        xlabel('Time [OFDM Symbol]')
        ylabel('Frequency [Carrier Number]')
        
        figure()
        surf(demod_pilots)
        colormap jet
        title('Complete Jammer Pilot Map')
        xlabel('Time [OFDM Symbol]')
        ylabel('Frequency [Carrier Number]')
        
        PilotMap(DVBT2.DataPoints, DataSymbols) = 0;
        for x = 1:DataSymbols
            PilotMap(1:DVBT2.DataPoints, x) = demod_pilots((15*1024 - DVBT2.DataPoints/2 + 1):(15*1024 + DVBT2.DataPoints/2), x);
        end

        % Plot Complete Pilot Map
        figure()
        imagesc((PilotMap))
        colormap jet
        title('Part of Jammer Pilot Map')
        xlabel('Time [OFDM Symbol]')
        ylabel('Frequency [Carrier Number]')
        % colorbar 
        figure()
        surf((PilotMap)) % Replace with symbols to plot full map
        title('Part of Jammer Pilot Map')
        xlabel('Time [OFDM Symbol]')
        ylabel('Frequency [Carrier Number]')
    
        figure()
        subplot(2,1,1)
        plot(bins,abs(20*log10(fftshift(fft(RefData))))-max(abs(20*log10(fftshift(fft(RefData))))))
        xlim([(RCF.m_Fc_Hz-RCF.m_Fs_Hz/2) (RCF.m_Fc_Hz+RCF.m_Fs_Hz/2)])
        xlabel('Frequency [MHz]')
        ylabel('Normalised Power [dB]')
        title('Demod Reference Channel Data')

        subplot(2,1,2)
        plot(bins,abs(20*log10(fftshift(fft(SurvDataJam))))-max(abs(20*log10(fftshift(fft(SurvDataJam))))))
        xlim([(RCF.m_Fc_Hz-RCF.m_Fs_Hz/2) (RCF.m_Fc_Hz+RCF.m_Fs_Hz/2)])
        xlabel('Frequency [MHz]')
        ylabel('Normalised Power [dB]')
        title('Surveillance Channel With Target')
    end
end

