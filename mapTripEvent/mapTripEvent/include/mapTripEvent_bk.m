function mapTripEvent()
%% to map the onroad event labels of TRI video to OBD data

%% setup parameter
%path info--------------------------------
filename = 'umtri_0531';
inputfolder = ['../data/' filename];
outputfolder = ['../output/' filename];

%Label event attr column selection--------default
%1-'Start Time' 2-'End Time' 3-'Road Status' 4-'Traffic' 5-'Stop' 6-'Yield'
%7-'Traffic Light' 8-'Lane Change Left' 9-'Lane Change Right' 10-'Turn Left'
%11-'Turn Right'  12-'Merge Left' 13-'Merge Right' 14-'Intersection'
timeCol = [1 2];
eventCol = [8 9 10 11];

%OBD data freq----------------------------default
OBD_Freq = 100; %Hz
fps = 29.97 ; %fps

%% loading file
OBDattrNum = 9; % refer to event label output from TRI video
csvfile = dir([inputfolder '/*.csv']);
csvfile = [inputfolder '/' csvfile.name];
fid = fopen(csvfile);
OBD_Raw = textscan(fid,repmat('%s',1,OBDattrNum),'Delimiter',',');
fclose(fid);
OBDattr = cellfun(@(x) x(1),OBD_Raw);
OBDdata = cell2mat(cellfun(@(x) str2num(char(x(2:end))),OBD_Raw,'UniformOutput',0));
OBD = array2table(OBDdata,'VariableName',OBDattr);
xlsfile = dir([inputfolder '/*.xls']);
xlsfile = [inputfolder '/' xlsfile.name];
[~,~,tripEvent] = xlsread(xlsfile);

%output: OBD tripEvent
%% retrieve the file matrix
%lcCol = find(cellfun(@(x) ~isempty(x),(regexp(C(1,:),'Lane|lane'))));
attrCol = [timeCol eventCol];
tripEventAttr = tripEvent(1,eventCol);
tripEventAttr = cleanStr(tripEventAttr,' ');
tripEventList =  cell2mat(tripEvent(2:end,attrCol));
videoLen = datestr(max(tripEventList(:,2)),'MM:SS.FFF');
tripEventList = tripEventList(sum(tripEventList(:,3:end) == 1,2)~=0,:);
[eventLen,eventAttrNum] = size(OBD);
%initialize output
mapTripEvent = [OBD array2table(zeros(eventLen,length(eventCol)),...
    'VariableName',tripEventAttr)];

%output: OBD tripEventList mapTripEvent
%% mapping the event time to frame number to whole video event

%GT get the event period and map to frame number 
eventTime = num2cell(tripEventList(:,timeCol));
tripEventList(: ,[1 2]) = cell2mat(cellfun(@(x) round(getFrameNumfromVideo(datestr(x,'MM:SS.FFF'),fps).*(OBD_Freq/fps)), ...
    eventTime,'UniformOutput',0));

%mapping trip event to OBD data
for eventNum = 1:length(tripEventList(:,1))
    thisEventTime =  tripEventList(eventNum,timeCol(1)):tripEventList(eventNum,timeCol(2));
    thisEventLen = length(thisEventTime);
    thisEventAttr =  repmat(tripEventList(eventNum,3:end),thisEventLen,1);
    mapTripEvent{thisEventTime,eventAttrNum+1:end} = thisEventAttr;
end

%output: mapTripEvent
%% output result
% uncomment to write output as csv 
% writetable(mapTripEvent,[outputfolder '.csv'] ,'Delimiter',',','WriteVariableNames',1);

% write mat file
save([outputfolder '.mat'],'mapTripEvent');
end

function frameNum = getFrameNumfromVideo(time,frameRate,option)
% frameNum = getFrameNumfromVideo(frameRate,time)
% time is a string: ex. 02:05.73
% frame rate typical fps = 29.97~30;
% option selection for unround output frameNum
%%
if nargin ==2 
    option =[];
end
if size(time,1)>1
    error('input dimension not support');
end

if nargin == 1
    frameRate = 30;
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
if ~isempty(option)
    frameNum = totalSec.*frameRate;
else
frameNum = round(totalSec.*frameRate);
end
end

function cellStr = cleanStr(cellStr,char)
for i = 1:length(cellStr)
    cellStr{i}(strfind(cellStr{i},char))=[];
end
end







