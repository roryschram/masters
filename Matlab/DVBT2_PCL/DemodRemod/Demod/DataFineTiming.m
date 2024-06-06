function Finestart = DataFineTiming(Values,DVBT2,Datastart,datastart)
%Description: Fine Timing of DVBT signals
% Inputs: L1pre - L1 pre parameters
%         DVBT2 - Data Symbol Parameters
%         datastart - index of main part of first data symbol (internal to function)
%         Datastart - index of main part of first data symbol (external to function)
% Ouputs: Finestart - fine index estimate of main part of first data symbol (internal to function)
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

NFFT = DVBT2.NFFT;
Symbol = fftshift(fft(Values(1:NFFT)));
Symbol = Symbol(DVBT2.C_LOC)*sqrt(27*DVBT2.C_PS);

pilotloc = DVBT2.SPLoc(1,:); % Scattered Pilot Location in first data symbol
pilotloc(pilotloc==0)=[];

DataSPilotMap = DVBT2.Scatteredpilotmap;
DataSPilotMap = DataSPilotMap(1,:);
DataSPilotMap = DataSPilotMap.';

forn = zeros(1,length(pilotloc)); % Shows linear phase corresponding to symbol timing offset
for i = 1:length(pilotloc)-1
    k1 = pilotloc(i+1);
    k = pilotloc(i);
    a = Symbol(k);
    a1 = Symbol(k1);
    prod1 = angle(a1./DataSPilotMap(k1)); % unwrap()
    prod = angle(a./DataSPilotMap(k)); 
    prod = (prod1)-(prod);
    forn(i+1) = forn(i)+ prod;
end

%b. Median filtering method
range = 25;
offset = movsum(forn,range);
offset = offset/range;
offset = diff(offset);
offset = diff(forn);
offset = medfilt1(offset,20);
offset = median(offset);

offset = round(offset*(NFFT/(2*pi*(DVBT2.DX*DVBT2.DY)))); %Estimate of the offset

Finestart = Datastart-offset-1;% Offset correction

disp('Data Fine Timing Completed')
fprintf('Data start (main part of Data symbol): %d \n', Finestart+datastart)
end