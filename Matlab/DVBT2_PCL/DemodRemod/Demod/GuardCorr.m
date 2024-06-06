function guardintest = GuardCorr(DVBT2, NFFT, guardint)
%Description: Determine Guard interval length 

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

%Inputs:  DVBT2 - IQ data (starts at course estimate, 8 symbols long)
%		  NFFT  - FFT Size
%		  guardint = possible guard intervals
%Outputs: guardintest - guard interval estimate

L = min(guardint)*NFFT;
gammalength = NFFT/4;
gamma = zeros(gammalength,1); % 
NumGI = length(guardint); % number of possible guard intervals
GR = zeros(NFFT/4,NumGI);

for i1 = 1:NumGI
    tri = zeros(NFFT/4,1);
    for l = 0:6
        for i = 1:gammalength
            gamma(i) = (DVBT2(i+l*(NFFT*(1+guardint(i1))):i+l*(NFFT*(1+guardint(i1)))+256-1).')*conj(DVBT2(i+l*(NFFT*(1+guardint(i1)))+NFFT:i+l*(NFFT*(1+guardint(i1)))+256-1+NFFT));
        end
        tri = tri+abs(gamma);
    end
    GR(:,i1) = tri;
end

guardintest = max(GR,[],1);
[~,guardintest] = max(guardintest);
guardintest = guardint(guardintest);

Lint =rat(guardintest);
Lint(Lint=='0'|Lint=='+'|Lint=='('|Lint==')'|Lint==' ')='';

disp('Guard interval length Estimation Completed')
fprintf('Estimated Guard interval = %s\n',Lint)
end