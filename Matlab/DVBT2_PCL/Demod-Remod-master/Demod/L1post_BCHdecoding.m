function LLRChannel_7032 = L1post_BCHdecoding(LLRChannel_7200)
%Description: Depuncture and add zeros
% Inputs: LLRChannel_7200 - 7200 bit length FEC block BCH Coded
% Ouputs: LLRChannel_7032 - 7032 bit length FEC block BCH unCoded
% Reference:
kBCH = 7032;
nBCH = 7200;
tBCH = 12;
primitivepoly = de2bi(16427,'left-msb');

nzp = {[1 3 5]                  ... g1
    [6 8 11]                 ... g2
    [1 2 6 9 10]             ... g3
    [4 7 8 10 12]            ... g4
    [2 4 6 8 9 11 13]        ... g5
    [3 7 8 9 13]             ... g6
    [2 5 6 7 10 11 13]       ... g7
    [5 8 9 10 11]            ... g8
    [1 2 3 9 10]             ... g9
    [3 6 9 11 12]            ... g10
    [4 11 12]                ... g11
    [1 2 3 5 6 7 8 10 13]};  ... g12
    g = zeros([12 14+1]);
for n = 1:12
    g(n,[1 nzp{n}+1 end]) = 1;
end

Poly = gf(g(1,:),1);
for n = 2:tBCH
    Poly = conv(Poly, gf(g(n,:),1));
end
BCH_GEN = fliplr(double(Poly.x)); %generator polynomial

BCHDec = comm.BCHDecoder('CodewordLength', nBCH, ...
    'MessageLength', kBCH, ...
    'PrimitivePolynomialSource', 'Property', ...
    'PrimitivePolynomial', primitivepoly, ...
    'GeneratorPolynomialSource', 'Property', ...
    'GeneratorPolynomial', BCH_GEN, ...
    'CheckGeneratorPolynomial', false);

LLRChannel_7032 = step(BCHDec,LLRChannel_7200.');