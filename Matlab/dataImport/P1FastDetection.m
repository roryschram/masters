function [index, ffreq]= P1FastDetection(RefData, PlotP1)
%Description: Gives index for Beginning of P1 and estimate of fractional frequency offset

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: DVBT2 - IQ data
%Outputs: index - start of P1 symbol for FFT
%         ffreq - fine frequency offset estimate

disp('Begininng P1 Detection..')

clear1 = '';
timeindicate = 0;
t = 0:1:(length(RefData)-1);
fd = -1/1024;
% Add the frequency shift
ShiftedRefData = (RefData.').*exp(2*pi*1i*fd*t);
U = 0;
V = 0;
ShortLength = round((length(RefData) - 2048)/271) - 1;
Ushort(ShortLength) = 0;
Vshort(ShortLength) = 0;

for x = 1:ShortLength
 % P1 detection time to completion console display
    if ((x/ShortLength)*100)>timeindicate
        msg = sprintf('P1 Detection: %2.2f%% completed',(x/ShortLength)*100);
        msglength = length(msg);
        disp([clear1 msg])
        timeindicate = timeindicate+0.1;
        clear1 = (repmat(sprintf('\b'), 1, msglength+1));
    end

    i = (x - 1)*271 + 1;
    Ushort(x) = (conj(ShiftedRefData(i:(i + 542 - 1))))*(RefData((i + 542):(i + 542 + 542 - 1)));
    Vshort(x) = (conj(ShiftedRefData((i + 482):(i + 482 + 482 - 1))))*(RefData(i:(i + 482 - 1)));

end
Zshort = abs(circshift(Ushort, 1084/271).*Vshort); % use for estimate of P1 start

if PlotP1 == 1
    figure();
    plot(abs(Zshort), 'b');
end

Threshold = min(Zshort) + (max(Zshort) - min(Zshort))/2;
count = 0;
RoughP1 = 0;
while max(Zshort) > Threshold
    count = count + 1;
    [val, index] = max(Zshort);
    RoughP1(count) = index;
    if index < 5
        Zshort((1):(index + 5)) = Zshort((1):(index + 5))*0;
    elseif index > length(Zshort) - 5
        Zshort((index - 5):(end)) = Zshort((index - 5):(end))*0;
    else
        Zshort((index - 5):(index + 5)) = Zshort((index - 5):(index + 5))*0;
    end
end
RoughP1 = sort(RoughP1);

U = 0;
V = 0;
U(length(RefData) - 2048) = 0;
V(length(RefData) - 2048) = 0;
for y = 1:length(RoughP1)
    if (RoughP1(y)*271 - 2084 < 1)
        start = 1;
    else
        start = RoughP1(y)*271 - 2084;
    end
    if (RoughP1(y)*271 + 1084 > (length(RefData) - 2048))
        endd = length(RefData) - 2048;
    else
        endd = RoughP1(y)*271 + 1084;
    end
    for i = start:endd
        U(i) = ((ShiftedRefData(i:(i + 542 - 1))))*conj(RefData((i + 542):(i + 542 + 542 - 1)));
        V(i) = (conj(ShiftedRefData((i + 482):(i + 482 + 482 - 1))))*(RefData(i:(i + 482 - 1)));
    end
end
Z = (circshift(U,1024).*V);
Z2 = abs(Z);

if PlotP1 == 1
    figure();
    plot(abs(Z), 'b');
end

Threshold = max(Z2)/2;
count = 0;
P1Loc = 0;
while max(Z2) > Threshold
    count = count + 1;
    [val, index] = max(Z2);
    P1Loc(count) = index;
    if index < 3000
        Z2((1):(index + 3000)) = Z2((1):(index + 3000))*0;
    elseif index > length(Z2) - 3000
        Z2((index - 3000):(end)) = Z2((index - 3000):(end))*0;
    else
        Z2((index - 3000):(index + 3000)) = Z2((index - 3000):(index + 3000))*0;
    end
end
P1Loc = sort(P1Loc);

index = P1Loc-542;
ffreq = angle(Z(P1Loc(1)))/(2*pi);
fprintf('P1 Fractional Frequency Offset: %d \r\n', ffreq)

end