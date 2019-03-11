function [ sessGNG ] = loadSessSearchGNG( monkey )
%loadSessSearchGNG Summary of this function goes here
%   Detailed explanation goes here

FILE_XLSX = '~/Dropbox/SearchGNG/Info-Sessions-SGNG.xlsx';

[~,sessGNG] = xlsread(FILE_XLSX, monkey(1:2), 'C3:C32');

NUM_SESSION = length(sessGNG);
for kk = 1:NUM_SESSION
  sessGNG{kk} = [monkey, '-', sessGNG{kk}];
end%for:session(kk)

sessGNG = transpose(sessGNG);

end%util:loadSessSearchGNG()

