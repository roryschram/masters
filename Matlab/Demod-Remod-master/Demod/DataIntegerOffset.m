function ioffset = DataIntegerOffset(Symbol,DVBT2)
%Description: Get Data Cells in
% Inputs  Symbol - Data Symbol in time
%         DVBT2 - Data Symbol Parameters
% Ouputs: ioffset - interger freq offset estimated
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: DVBT2 - 1024 FFT of P1 symbol

NFFT = DVBT2.NFFT;

% DataSPilotLoc = DVBT2.SPLoc(1,:); % Scattered Pilot Location in first data symbol
% DataSPilotLoc(DataSPilotLoc==0)=[];
% 
% DataSPilotMap = DVBT2.Scatteredpilotmap;
% DataSPilotMap = DataSPilotMap(1,:);
% DataSPilotMap = DataSPilotMap.';
% DataSPilotMap = conj(DataSPilotMap);
% DataSPilotMap = DataSPilotMap(DataSPilotLoc);

DataCPilotLoc = DVBT2.CPLoc(1,:); % Scattered Pilot Location in first data symbol
DataCPilotLoc(DataCPilotLoc==0)=[];
								
									
											 

DataCPilotMap = DVBT2.Continualpilotmap;
DataCPilotMap = DataCPilotMap(1,:);
DataCPilotMap = DataCPilotMap.';
DataCPilotMap = conj(DataCPilotMap);
DataCPilotMap = DataCPilotMap(DataCPilotLoc);

Symbol = fftshift(fft(Symbol));
Symbol = Symbol.';

minrange = -DVBT2.C_LOC(1)+1;
maxrange =  NFFT-DVBT2.C_LOC(end);
ioffsetrange = minrange:1:maxrange;
M = zeros(1,length(minrange:1:maxrange));

for i = 1:length(ioffsetrange)
    c = Symbol(DVBT2.C_LOC(1)-1+DataCPilotLoc+ioffsetrange(i));
    c = c.'.*DataCPilotMap;
    c = abs(c);
    M(i) = sum(c);
end
ioffset = ioffsetrange((M==max(M)));
disp('Data Integer Frequency Offset Estimation Completed')
fprintf('Integer offset (in number of frequency bins): %d \n',ioffset)
end