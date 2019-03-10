function [tdtEvs,tdtEvTms] = klGetEvsTDT(sessDir)

% Pull out event codes and times
tdtEvRaw = TDTbin2mat(sessDir,'TYPE',{'epocs','scalars'},'VERBOSE',0);
if isfield(tdtEvRaw.epocs,'STRB')
    tdtEvs = tdtEvRaw.epocs.STRB.data;
    if any(tdtEvs > 2^15)
        tdtEvs = tdtEvs-2^15;
    end
    tdtEvTms = tdtEvRaw.epocs.STRB.onset.*1000;
    tdtEvTms(tdtEvs <= 0) = [];
    tdtEvs(tdtEvs <= 0) = [];
elseif isfield(tdtEvRaw.epocs,'EVNT')
    tdtEvs = tdtEvRaw.epocs.EVNT.data;
    if any(tdtEvs > 2^15)
        tdtEvs = tdtEvs-2^15;
    end
    if ~any(ismember(tdtEvs,taskHeaders))
        tdtEvs = tdtEvs./2;
    end
    tdtEvTms = tdtEvRaw.epocs.EVNT.onset.*1000;
    tdtEvTms(tdtEvs <= 0) = [];
    tdtEvs(tdtEvs <= 0) = [];

else
    if isempty(tdtEvRaw.scalars)
        tdtEvs = nan; tdtEvTms = nan;
        return
    end
    tdtEvs = tdtEvRaw.scalars.EVNT.data;
    if any(tdtEvs >= (2^15))
        tdtEvs = tdt2EvShft(tdtEvs);
    end
    if any(mod(tdtEvs,1)) ~= 0
        tdtEvs = tdtEvRaw.scalars.EVNT.data - (2^15);
    end
    tdtEvTms = tdtEvRaw.scalars.EVNT.ts.*1000;
    tdtEvTms(tdtEvs < 0) = [];
    tdtEvs(tdtEvs < 0) = [];
end
