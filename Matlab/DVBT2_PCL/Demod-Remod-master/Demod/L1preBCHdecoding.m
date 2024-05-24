function L1_NBch_3072 = L1preBCHdecoding(L1_NBch_3240)
%Description: BCH decoding of L1 pre signalling 
% Inputs: L1_NBch_3240 - L1 pre BCH coded frame of 3240 bits length
% Ouputs: L1_NBch_3072 - L1 pre BCH uncoded frame of 3072 bits length
%References: A practical guide to error control coding using MATLAB

%Inputs
kBCH = 3072;
nBCH = 3240;
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

L1_NBch_3072 = step(BCHDec,L1_NBch_3240.');
end