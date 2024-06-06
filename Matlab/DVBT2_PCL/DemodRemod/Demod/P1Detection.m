function [index, ffreq]= P1Detection(DVBT2,PlotP1)
%Description: Gives index for Beginning of P1 and estimate of fractional frequency offset

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: DVBT2 - IQ data
%Outputs: index - start of P1 symbol for FFT
%         ffreq - fine frequency offset estimate

disp('Begininng P1 Detection. Please be patient...')

Values = [DVBT2; zeros(2048,1)];
n = (0:length(Values)-1).';

U = zeros(length(Values),1); %Cross Correlation vector of Part C with Part A
V = zeros(length(Values),1); %Cross Correlation vector of Part B with Part A

total = length(Values);
timeindicate = 0;
clear1 = '';

Cpath = Values.*exp(1i*2*pi*(-1*n/1024));
%% Cross correlation of the guard intervals of the P1 symbol, Cross multiplication
for i = 1:length(Values)-2048
    
    % P1 detection time to completion console display
        if ((i/total)*100)>timeindicate
            msg = sprintf('P1 Detection: %2.2f%% completed',(i/total)*100);
            msglength = length(msg);
            disp([clear1 msg])
            timeindicate = timeindicate+0.1;
            clear1 = (repmat(sprintf('\b'), 1, msglength+1));
        end
   
    U(i) = (1/1024)*((Cpath(i:i+542-1)).')*conj((Values(i+542:i+542+542-1))); % Cross correlation part C with part A
    V(i) =  (1/1024)*(conj(Cpath(i+482:i+482+482-1)).')*((Values(i:i+482-1))); % Cross correlation part B with part A
	
end
U2 = circshift(U,1024); % Line up Part C detection with Part B detection
Z2 = U2.*V;

%figure()
%plot(abs(U2))
%grid on
%figure()
%plot(abs(V))
%grid on

%% Threshold detection of peaks for P1 Detection using mean noise floor
mZ =0;
for i = 1:20
    mZ = mZ + mean(abs(Z2(1+i*1000:1+i*1000+100)));
end
mZ = mZ/20;
varZ = var(Z2);

threshold = 2*(varZ^2+mZ^2)*log(1/10e-6); % 10e-20 is prob false alarm. Chosen empiracally
threshold = sqrt(threshold);
% threshold = max(Z2)/2;
[~,Coarse_time_index]=findpeaks(abs(Z2),'minpeakdistance',28544,'MinPeakHeight',10*abs(threshold)); %Find P1 start. 28544 chosen as it relates to minimum frame length in DVBT2
%% Detection decsion making and Fine Frequency offset detection
if isempty(Coarse_time_index)
    error('P1 Detection: No P1 Found')
else
    if length(Coarse_time_index)==1 && (Coarse_time_index(1)<442 ||(Coarse_time_index(1)>(length(Values)-483)))
        index = [];
        ffreq = [];
        disp('P1 Detection: Not enough samples for P1 demodulation')
    end
    Coarse_time_index(Coarse_time_index<442)=[];
    Coarse_time_index(Coarse_time_index>(length(Values)-483))=[];
    if isempty(Coarse_time_index)
        index = [];
        ffreq = [];
        disp('P1 Detection: No P1 Found')
    end
    index = Coarse_time_index-542;
    index(index<=0)=1;
end
    ffreq = angle(Z2(Coarse_time_index(1)))/(2*pi);
    fprintf('P1 Fractional Frequency Offset: %d \r\n', ffreq)
    disp('P1 Detection completed.')
end   