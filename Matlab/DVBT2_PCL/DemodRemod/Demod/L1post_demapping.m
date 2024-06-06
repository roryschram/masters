function [L1postsymbols, LLRChannel] = L1post_demapping(L1postsymbols, L1pre,Variance)
%Description: Demapping of L1 post bits using Soft bit demodulation
% Inputs: L1postsymbols - received QAM symbols of L1 post
%         L1pre - L1 pre parameters
%         Variance - Estimated noise variance
% Ouputs: L1postsymbols - QAM symbols of L1 post
%         LLRChannel - LLR of L1 post symbols
% Reference:

C_Points = L1pre.L1cpoints; %L1 post constellation points
C = L1pre.L1C; %L1 post constellation normalization factor
Num_Cpoints = length(C_Points); %Number of constellation points
LLRChannel = zeros(1,L1pre.L1V*length(L1postsymbols)); % Initialize Channel LLR for each bit of output
L1postbitstream = LLRChannel;
if Variance<1, Variance = 1;end
Const = -1/(2*Variance); % Var is noise variance from FFT

%Determine the binary representation of each symbol in array in constellation
binarycon = de2bi(0:(Num_Cpoints-1),'left-msb');

for i = 1:length(LLRChannel)
    
    i1 = floor((i-1)/L1pre.L1V)+1; %indexing for symbol use
    points_zero = C_Points((binarycon(:,(mod(i-1,L1pre.L1V)+1))==0)); % all the points correponding to a zero at a particular bit in cell word
    points_one = C_Points((binarycon(:,(mod(i-1,L1pre.L1V)+1))==1));% all the points corresponding to a ONE at a particular bit in cell word
    
    numerator = sum(exp(Const.*((((real(L1postsymbols(i1)).*(C))-(real(points_zero)))).^2 ...
                +(((imag(L1postsymbols(i1)).*(C))-imag(points_zero))).^2))); %Pr given b = 0
    denominator = sum(exp(Const.*((((real(L1postsymbols(i1)).*(C))-(real(points_one)))).^2 ...
                +(((imag(L1postsymbols(i1)).*(C))-imag(points_one))).^2))); %Pr given b = 0
    LLRChannel(i)= log(numerator/denominator);
    
    if LLRChannel(i)>1000; LLRChannel(i)=10;end
    if LLRChannel(i)<-1000; LLRChannel(i)=-10;end
end
L1postbitstream((LLRChannel<0))=1;

L1postsymbols = reshape(L1postbitstream,L1pre.L1V,[]);
L1postsymbols = L1postsymbols.';
L1postsymbols = bi2de(L1postsymbols,'left-msb');
L1postsymbols = L1pre.L1cpoints(L1postsymbols+1);
L1postsymbols = L1postsymbols/L1pre.L1C;

end