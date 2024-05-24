function Finestart = P2FineTiming(Values,P2,DVBT2,P2start,p2start)
%Description: Fine Timing of DVBT signals
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: Values - IQ Data
%        P2 - P2 Parameters
%        DVBT2 - FFT Size and MISO/SISO
%        P2start - P2 start index (internal to function)
%        p2start - P2 start index (external to function)
%Outputs: Finestart - Fine timing estimate

%Process
%%
NFFT = DVBT2.nfft;

P2sym1 = fftshift(fft(Values(1:NFFT)));
P2sym1 = P2sym1(P2.C_LOC)*sqrt(27*P2.C_PS);
p2pilots = P2.P2PilotMap(1,:);
pilotloc = P2.P2PLoc;
Timingphase = zeros(1,length(pilotloc)); % Shows linear phase corresponding to symbol timing offset
for i = 1:length(pilotloc)-1
    k1 = pilotloc(i+1);
    k = pilotloc(i);
    a = P2sym1(k);
    a1 = P2sym1(k1);
    prod1 = angle(a1./p2pilots(k1)); % unwrap()
    prod = angle(a./p2pilots(k));
    prod = (prod1)-(prod);
    Timingphase(i+1) = Timingphase(i)+ prod;
end

%b. Median filtering method
range = 25;
offset = movsum(Timingphase,range);
offset = offset/range;
offset = diff(offset);
offset = medfilt1(offset,20);
offset = median(offset);

offset = round(offset*(NFFT/(2*pi*P2.DX))); %Estimate of the offset

Finestart = P2start-offset-1;% Offset correction

disp('P2 Fine Timing Completed');
fprintf('P2 start (main part of P2 symbol): %d \n', Finestart+p2start);
end