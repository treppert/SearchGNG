function [ ] = plotRTcdfSGNG( Task )
%plotRTcdfSGNG Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(Task);

QUANTILE = (.05 : .10 : .95);
NUM_QUANT = length(QUANTILE);

RTcEsE = NaN(NUM_SESSION,NUM_QUANT); %color easy | shape easy
RTcEsH = NaN(NUM_SESSION,NUM_QUANT); %color easy | shape hard
RTcHsE = NaN(NUM_SESSION,NUM_QUANT);
RTcHsH = NaN(NUM_SESSION,NUM_QUANT);

for kk = 1:NUM_SESSION
  
  RTkk = Task(kk).SRT;
  
  %index by color discriminability
  idxClrHard = (Task(kk).HardColor == 1);
  idxClrEasy = (Task(kk).HardColor == 0);
  %index by aspect ratio
  idxARHard = (Task(kk).SingletonDiff == 2);
  idxAREasy = (Task(kk).SingletonDiff == 4);
  %index by trial outcome
  idxCorr = (Task(kk).Correct == 1);
  
  RTcEsE(kk,:) = quantile(RTkk(idxClrEasy & idxAREasy & idxCorr), QUANTILE);
  RTcEsH(kk,:) = quantile(RTkk(idxClrEasy & idxARHard & idxCorr), QUANTILE);
  RTcHsE(kk,:) = quantile(RTkk(idxClrHard & idxAREasy & idxCorr), QUANTILE);
  RTcHsH(kk,:) = quantile(RTkk(idxClrHard & idxARHard & idxCorr), QUANTILE);
  
end%for:session(kk)

%% Plotting

figure(); hold on

errorbar(mean(RTcEsE), QUANTILE, std(RTcEsE)/sqrt(NUM_SESSION), 'horizontal', ...
  'Color','k', 'LineWidth',1.5, 'CapSize',0)
errorbar(mean(RTcEsH), QUANTILE, std(RTcEsH)/sqrt(NUM_SESSION), 'horizontal', ...
  'Color','k', 'LineWidth',0.5, 'CapSize',0)
errorbar(mean(RTcHsE), QUANTILE, std(RTcHsE)/sqrt(NUM_SESSION), 'horizontal', ...
  'Color','r', 'LineWidth',1.5, 'CapSize',0)
errorbar(mean(RTcHsH), QUANTILE, std(RTcHsH)/sqrt(NUM_SESSION), 'horizontal', ...
  'Color','r', 'LineWidth',0.5, 'CapSize',0)

ppretty([6.4,4])

end%plotRTcdfSGNG()

%   %index by singleton color
%   idxSingRed = (Task(kk).SingletonColor == 0);
%   idxSingNRed = (Task(kk).SingletonColor == 2);
%   idxSingGrn = (Task(kk).SingletonColor == 1);
%   idxSingNGrn = (Task(kk).SingletonColor == 9);
