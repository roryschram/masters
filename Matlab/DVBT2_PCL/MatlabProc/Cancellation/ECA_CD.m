function Z = ECA_CD(RefSymbolData, SurvSymbolData, proc, DVBT2)
	%%
    fprintf('Performing ECA-CD cancellation\n')
	tic
    Z(DVBT2.nSymbols-1, DVBT2.EndCarrier-DVBT2.StartCarrier + 1) = 0;
    % Doppler shift matrix for clutter suppression
    T = 1/(DVBT2.Fs*10^(6));
    Ts = (DVBT2.EndCarrier-DVBT2.StartCarrier)*T;
    D = exp(1j*2*pi*proc.cancellationMaxDoppler_Hz*(1:DVBT2.nSymbols-1)*Ts)';  
    D = diag(D);
    for k = 1:(DVBT2.EndCarrier - DVBT2.StartCarrier + 1)
        % Get carrier amplitudes
        Q_k = RefSymbolData(:,k); 
        X_k = [D'*Q_k, Q_k, D*Q_k];
        Y_k = SurvSymbolData(:,k);
        % Apply least squares regression
        Z_k = (eye(DVBT2.nSymbols-1) - X_k*(X_k' * X_k)^(-1)*X_k')*Y_k;
        Z(:, k) = Z_k;
    end
    fprintf('\n')
	toc
end