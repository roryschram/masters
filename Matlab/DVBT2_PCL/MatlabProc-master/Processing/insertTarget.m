function SurvDataTarget = insertTarget(RefData, SurvData, target, C, RCF, TxToRefRxDistance_m)
    fprintf('Inserting targets..\n\n')
	SurvDataTarget = SurvData;
	
	for i = 1:length(target)
		ShiftRange = target(i).delayRange - TxToRefRxDistance_m;
		ShiftAmount = ceil((ShiftRange/C)*RCF.m_Fs_Hz);

		A = (10^(target(i).SNR/20))*rms(SurvData);
		delay = zeros(1,ShiftAmount);
		td = 0:1/RCF.m_Fs_Hz:(length(SurvData)-1)/RCF.m_Fs_Hz;
		
		TargetSignal = (([delay A*RefData(1:end-length(delay)).']).*exp(1i*2*pi*target(i).fd*td)).';
        SurvDataTarget = SurvDataTarget + TargetSignal;
    end
end