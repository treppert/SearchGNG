function [ ] = plot_CDF_RT_SGNG( Task )
%plot_CDF_RT_SGNG Summary of this function goes here
%   Detailed explanation goes here

N_SESS = length(Task);
PR_BIN = (0.1 : 0.1 : 0.9);   N_BIN = length(PR_BIN);

rtHH = NaN(N_SESS,N_BIN); %High identifiability, High discriminability
rtHL = NaN(N_SESS,N_BIN);
rtLH = NaN(N_SESS,N_BIN);
rtLL = NaN(N_SESS,N_BIN);

for kk = 1:N_SESS
  
  RTkk = Task(kk).SRT;
  
  %index by color similarity (singleton identifiability)
  idxIH = (Task(kk).HardColor == 0); %Identifiability High
  idxIL = (Task(kk).HardColor == 1); %Identifiability Low
  
  %index by color of the singleton
  idxSingRed = (Task(kk).SingletonColor == 0);
  idxSingNRed = (Task(kk).SingletonColor == 2);
  idxSingGrn = (Task(kk).SingletonColor == 1);
  idxSingNGrn = (Task(kk).SingletonColor == 9);
  
  %index by singleton aspect ratio (cue discriminability)
  idxDH = (Task(kk).SingletonDiff == 4); %Discriminability High
  idxDL = (Task(kk).SingletonDiff == 2); %Discriminability Low
  
  %index by trial outcome
  idxCorr = (Task(kk).Correct == 1);
  
  %collect RT data
  rtHH(kk,:) = quantile(RTkk(idxIH & idxDH & idxCorr), PR_BIN);
  rtHL(kk,:) = quantile(RTkk(idxIH & idxDL & idxCorr), PR_BIN);
  rtLH(kk,:) = quantile(RTkk(idxIL & idxDH & idxCorr), PR_BIN);
  rtLL(kk,:) = quantile(RTkk(idxIL & idxDL & idxCorr), PR_BIN);
  
%   respTime.red.arHigh(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idxSingRed & idx_ar_high);
%   respTime.red.arHigh(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idxSingRed | idxSingNRed) & idx_ar_high);
%   respTime.red.arLow(kk).clrDiff = Task(kk).SRT(idx_clr_diff & idxSingRed & idx_ar_low);
%   respTime.red.arLow(kk).clrSim = Task(kk).SRT(idx_clr_sim & (idxSingRed | idxSingNRed) & idx_ar_low);
  
end%for:session(kk)


%% Plotting

%cumulative distribution
muRTHH = mean(rtHH);  seRTHH = std(rtHH) / sqrt(N_SESS);
muRTHL = mean(rtHL);  seRTHL = std(rtHL) / sqrt(N_SESS);
muRTLH = mean(rtLH);  seRTLH = std(rtLH) / sqrt(N_SESS);
muRTLL = mean(rtLL);  seRTLL = std(rtLL) / sqrt(N_SESS);

figure(); hold on
errorbar(muRTHH, PR_BIN, seRTHH, 'horizontal', 'k-', 'LineWidth',1.25, 'CapSize',0)
errorbar(muRTHL, PR_BIN, seRTHL, 'horizontal', 'k-', 'LineWidth',0.75, 'CapSize',0)
errorbar(muRTLH, PR_BIN, seRTLH, 'horizontal', 'r-', 'LineWidth',1.25, 'CapSize',0)
errorbar(muRTLL, PR_BIN, seRTLL, 'horizontal', 'r-', 'LineWidth',0.75, 'CapSize',0)
xlabel('Response time (ms)')
ylabel('F(t)'); ylim([0 1])
ppretty([6.4,4]); pause(0.1)


%mean interaction contrast
idxMed = 5; %index corresponding to median RT

figure(); hold on
errorbar([1 2], [muRTHH(idxMed) muRTHL(idxMed)], [seRTHH(idxMed) seRTHL(idxMed)], 'k-', 'CapSize',0)
errorbar([1 2], [muRTLH(idxMed) muRTLL(idxMed)], [seRTLH(idxMed) seRTLL(idxMed)], 'r-', 'CapSize',0)
ylabel('RT (ms)')
xlim([.9 2.1]); xticks([1 2]); xticklabels({'High','Low'})
ppretty([2 4])


%distribution of session medians

figure()
subplot(2,2,1); histogram(rtHH(:,idxMed), 'BinWidth',10, 'FaceColor',[.4 .4 .4], 'LineWidth',1.25)
subplot(2,2,2); histogram(rtHL(:,idxMed), 'BinWidth',10, 'FaceColor',[.4 .4 .4], 'LineWidth',0.5)
subplot(2,2,3); histogram(rtLH(:,idxMed), 'BinWidth',10, 'FaceColor',[1 .5 .5], 'LineWidth',1.25)
subplot(2,2,4); histogram(rtLL(:,idxMed), 'BinWidth',10, 'FaceColor',[1 .5 .5], 'LineWidth',0.5)
ppretty([6.4,4])


%% Stats

%save session medians for Shapiro-Wilk test of normality
rtHH = rtHH(:,idxMed);
rtHL = rtHL(:,idxMed);
rtLH = rtLH(:,idxMed);
rtLL = rtLL(:,idxMed);
save('Fig3A-Da-medRT.mat', 'rtHH','rtHL','rtLH','rtLL')

end%fxn:plot_CDF_RT_SGNG()

