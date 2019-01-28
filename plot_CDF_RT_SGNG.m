function [ ] = plot_CDF_RT_SGNG( Task )
%plot_CDF_RT_SGNG Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(Task);

respTime = new_struct({'clrSim','clrDiff'}, 'dim',[1,NUM_SESSION]);
respTime = struct('arLow',respTime, 'arHigh',respTime);
respTime = struct('green',respTime, 'red',respTime);

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
  
  %collect RT data
  respTime.red.arHigh(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idx_sing_red & idx_ar_high);
  respTime.red.arHigh(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_high);
  respTime.red.arLow(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idx_sing_red & idx_ar_low);
  respTime.red.arLow(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idx_sing_red | idx_sing_nRed) & idx_ar_low);
  respTime.green.arHigh(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idx_sing_grn & idx_ar_high);
  respTime.green.arHigh(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idx_sing_grn | idx_sing_nGrn) & idx_ar_high);
  respTime.green.arLow(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idx_sing_grn & idx_ar_low);
  respTime.green.arLow(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idx_sing_grn | idx_sing_nGrn) & idx_ar_low);
  
end%for:session(kk)


%% Plotting

xx.red.arHigh.clrDiff = sort(respTime.red.arHigh(1).clrDiff);
xx.red.arHigh.clrSim = sort(respTime.red.arHigh(1).clrSim);
xx.red.arLow.clrDiff = sort(respTime.red.arLow(1).clrDiff);
xx.red.arLow.clrSim = sort(respTime.red.arLow(1).clrSim);

yy.red.arHigh.clrDiff = (1:length(xx.red.arHigh.clrDiff)) / length(xx.red.arHigh.clrDiff);
yy.red.arHigh.clrSim = (1:length(xx.red.arHigh.clrSim)) / length(xx.red.arHigh.clrSim);
yy.red.arLow.clrDiff = (1:length(xx.red.arLow.clrDiff)) / length(xx.red.arLow.clrDiff);
yy.red.arLow.clrSim = (1:length(xx.red.arLow.clrSim)) / length(xx.red.arLow.clrSim);

figure(); hold on

plot(xx.red.arHigh.clrDiff, yy.red.arHigh.clrDiff, 'k-')
plot(xx.red.arHigh.clrSim, yy.red.arHigh.clrSim, 'r-')
plot(xx.red.arLow.clrDiff, yy.red.arLow.clrDiff, 'k--')
plot(xx.red.arLow.clrSim, yy.red.arLow.clrSim, 'r--')

ppretty()

end%fxn:plot_CDF_RT_SGNG()

