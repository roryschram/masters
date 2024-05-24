function DVBT2TimeDomain = Guardinsertion(TimeFrame,L1pre,P2,NFFT,Remod)
%Description: Guard interval insertion
% Inputs: TimeFrame - Frame in samples domain
%         L1pre - L1 pre parameters
%         P2 - P2 Parameters
%         NFFT - FFT Size
%         Remod - Remod Settings
% Output: DVBT2TimeDomain - Time Domain of frame where each symbol has guard interval
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

CPLength = round(L1pre.GI*NFFT);

DVBT2TimeDomain = zeros(NFFT+CPLength,P2.N_P2+L1pre.numdatasymbols);
if Remod.Guard == 1
    DVBT2TimeDomain(1:CPLength,:) = TimeFrame((NFFT-CPLength+1:NFFT),:);
end
DVBT2TimeDomain((CPLength+1):(CPLength+NFFT),:) = TimeFrame;

DVBT2TimeDomain = reshape(DVBT2TimeDomain,1,[]);


end