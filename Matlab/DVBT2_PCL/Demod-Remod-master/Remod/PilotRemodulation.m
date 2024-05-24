function Pilots_remodulated = PilotRemodulation(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2_CPE,Data_CPE,FC_CPE,P1foffset,P1ioffset,P2foffset,P2ioffset,L1pre,L1post,Start,JamPilotSetting)
%Description: Remodulation process

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)
MISO = Start.miso;
DVBT2 = DVBT2Parameters(L1pre,L1post);
P2 = P2Parameters(L1pre.S2,MISO);

%Symbol Mapping
[P2Symbols,DataSymbols,FCSymbol] = SymbolMapping(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2,DVBT2);
%Frequency interleaver
[P2Symbols, DataSymbols,FCSymbol] = FreqInterleaver(P2Symbols,DataSymbols,FCSymbol,L1pre,P2,DVBT2);
%MISO encoding - NOT USED IN CURRENT VERSION
[P2Symbols, DataSymbols,FCSymbol] = MISOEncoding(P2Symbols,DataSymbols,FCSymbol,MISO,L1pre,L1post,DVBT2);
%Frame Mapping
Frame = PilotMapping(P2Symbols,DataSymbols,FCSymbol,P2_CPE,Data_CPE,FC_CPE,L1pre,DVBT2,P2,JamPilotSetting);
%FFT
TimeFrame = DVBT2FFT(Frame,L1pre,DVBT2,P2);
%Guard interval
DVBT2TimeDomain = Guardinsertion(TimeFrame,L1pre,P2,DVBT2.NFFT,JamPilotSetting);
% n = 0:(length(DVBT2TimeDomain)-1);
% DVBT2TimeDomain = DVBT2TimeDomain.*exp((1i*2*pi*(P2foffset)*n)/Start.nfft);
% DVBT2TimeDomain = DVBT2TimeDomain.*exp((1i*2*pi*(P2ioffset)*n)/Start.nfft);
% DVBT2TimeDomain = DVBT2TimeDomain.*exp((1i*2*pi*(P1foffset(1))*n)/1024);
% DVBT2TimeDomain = DVBT2TimeDomain.*exp((1i*2*pi*(P1ioffset)*n)/1024);
%P1 Symbol insertion
P1 = P1SymbolTimeDomain(L1pre.S1Value,L1pre.S2Value);
% nP1 = 0:2047;
% P1 = P1.*exp((1i*2*pi*(P1foffset(1))*nP1)/1024);
% P1 = P1.*exp((1i*2*pi*(P1ioffset)*nP1)/1024);

Pilots_remodulated = [P1,DVBT2TimeDomain];
end