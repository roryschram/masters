function [L1prebitstream, LLRChannel] = L1predemapping(L1presymbols,Variance)
%Description: Soft (Log-Probability) BPSK demapping of L1 pre signalling
% Inputs: L1presymbols - L1 pre QAM symbols
%         Variance - Estimated noise variance
%References: Error Correction Coding, Mathematical Methods and Algorithms
LLRChannel = zeros(1,1840);
L1prebitstream = LLRChannel;
if Variance<1e-3, Variance = 1e-3;end
Const = -1/(2*Variance); % Var is noise variance from FFT

for i = 1:1840
    numerator = exp(Const.*((real(L1presymbols(i))-1)).^2); %Pr given b = 0, symbol = 1
    denominator = exp(Const.*((real(L1presymbols(i))+1)).^2); %Pr given b = 1, symbol = -1
    LLRChannel(i) = log(numerator/denominator);
    if LLRChannel(i)>1000; LLRChannel(i)=10;end
    if LLRChannel(i)<-1000; LLRChannel(i)=-10;end
end

L1prebitstream((LLRChannel<0))=1;

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Note: LLRs given as (Pr(r|b=0)/Pr(r|b=1)
% so if postive, means b=0 more likely
% thus if negative, b=1 more likely
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end