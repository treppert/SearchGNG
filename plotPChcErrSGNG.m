function [ ] = plotPChcErrSGNG( Task )
%plotPChcErrSGNG Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(Task);

pCorr = new_struct({'clrSim','clrDiff'}, 'dim',[1,NUM_SESSION]);
pCorr = struct('arLow',pCorr, 'arHigh',pCorr);
pCorr = struct('green',pCorr, 'red',pCorr);

for kk = 1:NUM_SESSION
  
  %index by color similarity of the singleton and distractors
  idx_clr_sim = (Task(kk).HardColor == 1);
  idx_clr_diff = (Task(kk).HardColor == 0);
  
  %index by color of the singleton
  idx_sing_red = (Task(kk).SingletonColor == 0);
  idx_sing_nRed = (Task(kk).SingletonColor == 2);
  idx_sing_grn = (Task(kk).SingletonColor == 1);
  idx_sing_nGrn = (Task(kk).SingletonColor == 9);
  
  %index by singleton aspect ratio
  idx_ar_low = (Task(kk).SingletonDiff == 2);
  idx_ar_high = (Task(kk).SingletonDiff == 4);
  
  %index by trial outcome
  idx_corr = (Task(kk).Correct == 1);
  
  %compute percent correct
  pCorr.red.arHigh(kk).clrDiff = sum(idx_clr_diff & idx_sing_red & idx_ar_high & idx_corr) / sum(idx_clr_diff & idx_sing_red & idx_ar_high);
  pCorr.red.arHigh(kk).clrSim = sum(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_high & idx_corr) / sum(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_high);
  pCorr.red.arLow(kk).clrDiff = sum(idx_clr_diff & idx_sing_red & idx_ar_high & idx_corr) / sum(idx_clr_diff & idx_sing_red & idx_ar_low);
  pCorr.red.arLow(kk).clrSim = sum(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_high & idx_corr) / sum(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_low);
  
end%for:session(kk)




end%plotPChcErrSGNG()

