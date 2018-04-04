function mapLaneChangeDetect()
% mapLaneChangeDetect()
% Objective: to map the lane change detection result from 
% 	1. detection result in txt file
% 	2. ground truth label output file rui rui labelling system
% input: text file for Lane change CV detection and .xls for gt labelling xls
% output: the mapped array in csv format
% created @ 10/5/2017 tcyu@umich.edu 

%% adding path and initialize parameter

filename = 'umtri_0531';
fps = 29.97;
inputfolder = ['../input/' filename];
outputfolder = ['../output/' filename];

%% loading file
txtfile = dir([inputfolder '/*.txt']);
txtfile = [inputfolder '/' txtfile.name];
fid = fopen(txtfile);
detectResult = cell2mat(textscan(fid,'%f%f'));
fclose(fid);
xlsfile = dir([inputfolder '/*.xls']);
xlsfile = [inputfolder '/' xlsfile.name];
[~,~,C] = xlsread(xlsfile);

%% retrieve the file matrix
lcCol = find(cellfun(@(x) ~isempty(x),(regexp(C(1,:),'Lane|lane'))));
groundTruth =  cell2mat(C(2:end,[1 2 lcCol]));
videoLen = datestr(max(groundTruth(:,2)),'MM:SS.FFF');
groundTruth = groundTruth(groundTruth(:,3) == 1 | groundTruth(:,4) == 1,:);
frameLen = getFrameNumfromVideo(videoLen,fps);

%initialize output
mapDetectLCevent = [(1:frameLen)' zeros(frameLen,2)];

%groundTruth detectResult
%% mapping the event time to frame number to whole video event

%GT get the event period and map to frame number 
eventTime = num2cell(groundTruth(:,[1 2]));
groundTruth(: ,[1 2]) = cell2mat(cellfun(@(x) getFrameNumfromVideo(datestr(x,'MM:SS.FFF'),fps), ...
    eventTime,'UniformOutput',0));

%mapping detectResult to output
mapDetectLCevent(detectResult(:,1),2) = 1;

%mapping ground truth to output
for i = 1:size(groundTruth,1)
    mapDetectLCevent(groundTruth(i,1):groundTruth(i,2),3) = 1;
end

%% output result
% writing output
outputTable = array2table(mapDetectLCevent,...
    'VariableName',{'FrameNumber','LCDetect','LCGroundTruth'});
writetable(outputTable,[outputfolder '.csv'] ,'Delimiter',',','WriteVariableNames',1);

end

function frameNum = getFrameNumfromVideo(time,frameRate)
% frameNum = getFrameNumfromVideo(frameRate,time)
% time is a string: ex. 02:05.73
% frame rate typical fps = 29.97~30;
%%
if size(time,1)>1
    error('input dimension not support');
end

if nargin == 1
    frameRate = 29.97;
end
thisMin = str2double(time(1:2));
thisSec = str2double(time(4:5));
try
    this10ms =  str2double(time(7:8));
    totalSec =  thisMin*60+ thisSec + 0.01*this10ms;
catch
    this100ms =  str2double(time(:,7));
    totalSec =  thisMin*60+ thisSec + 0.1*this100ms;
end

frameNum = round(totalSec.*frameRate);
end








