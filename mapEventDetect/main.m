function main()
%% addpath
addpath include/ 

%% configuration
% windowSize - window size of neural network (default 1s)
% fps - frame per second (default 29.97Hz)
% dataFreq - data frequency of the .mat file (default 10Hz)
% input_file - input file name in data/
% begin_time - seconds
% videoLength - target composed video length


%windowSize = 1;
%dataFreq = 10;
%fps = 29.97;

begin_time= 190;
videoLength = 25*60+5; 
input_file = 'detect_result.mat';

mapEventDetect(input_file,videoLength,begin_time);
end

