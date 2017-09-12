function mapTripEvent()
%% to map the onroad event labels of TRI video to OBD data
% synchronization on TRI event labels and OBD data 
% @ 29/7/2017 by choi 
% 1.added the capability to choose any (onroad/dynamic trip event) to map on
% the OBD data 
% 2.added addGoStraightEventFlag to enable adding a event Col 'GoStraight' 
% @ 9/8/2017 by choi
% add outDataRate to get down sample output 
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
roadEventCol =[];
dynamicEventCol = [8 9 10 11];

%OBD data freq----------------------------default
OBD_Freq = 100; %Hz
fps = 29.97 ; %fps

%add go straight event--------------------flag go zero to turn off
addGoStraightEventFlag = 1;

%output format flag
OutputMatFile = 1;
OutputCSVFile = 0;

%output rate: change the rate to simply get the down sampled output data
%ex. ori freq = 100Hz, downsampleRate = 0.1 -> data rate -> 10Hz
%note. down sample here do not perform any filter
outDataRate = 0.1;


%% loading file
OBDattrNum = 9; % refer to event label output from TRI video

fprintf(['for now on start mapping event @ ' datestr(now) '\n']);
fprintf('loading event label data ...\n');
csvfile = dir([inputfolder '/*.csv']);
csvfile = [inputfolder '/' csvfile.name];
fid = fopen(csvfile);
OBD_Raw = textscan(fid,repmat('%s',1,OBDattrNum),'Delimiter',',');
fclose(fid);

fprintf('loading OBD data ...\n');
OBDattr = cellfun(@(x) x(1),OBD_Raw);
OBDdata = cell2mat(cellfun(@(x) str2num(char(x(2:end))),OBD_Raw,'UniformOutput',0));
OBD = array2table(OBDdata,'VariableName',OBDattr);
xlsfile = dir([inputfolder '/*.xls']);
xlsfile = [inputfolder '/' xlsfile.name];
[~,~,tripEvent] = xlsread(xlsfile);
 
fprintf('finish loading data\n');
%output: OBD tripEvent
%% retrieve the file matrix
%lcCol = find(cellfun(@(x) ~isempty(x),(regexp(C(1,:),'Lane|lane'))));
fprintf('start mapping the event and OBD data...\n');

% time attri retrieval
timeAttr = tripEvent(1,timeCol);
timeAttrList = cell2mat(tripEvent(2:end,timeCol));

% road event attri retrieval
roadEventList = cell2mat(tripEvent(2:end,roadEventCol));
roadEventAttr = tripEvent(1,roadEventCol);

% dynamic attri retrieval
dynamicEventList = cell2mat(tripEvent(2:end,dynamicEventCol));
dynamicEventAttr = tripEvent(1,dynamicEventCol);

% combine attri column
tripEventList = [timeAttrList roadEventList dynamicEventList];
videoLen = datestr(max(tripEventList(:,2)),'MM:SS.FFF');
tripEventAttr = [timeAttr roadEventAttr dynamicEventAttr];
tripEventAttr = cleanStr(tripEventAttr,' ');  
tripEventList = tripEventList(sum(tripEventList(:,3:end) == 1,2)~=0,:);
numEvent = length(tripEventList(:,1));

if addGoStraightEventFlag
    tripEventAttr = [tripEventAttr 'GoStraight'] ;
    tripEventList = [tripEventList zeros(numEvent,1)];
end


[OBDdataLen,OBDAttrNum] = size(OBD);
%initialize output
mapTripEvent = [OBD array2table(zeros(OBDdataLen,length(tripEventAttr(3:end))),...
    'VariableName',tripEventAttr(3:end))];
if addGoStraightEventFlag
    % assume all default dynamic direction  is going straight 
    mapTripEvent{:,end} = 1;
end

%output: OBD tripEventList mapTripEvent
%% mapping the event time to frame number to whole video event

%GT get the event period and map to frame number 
eventTime = num2cell(tripEventList(:,timeCol));
tripEventList(: ,[1 2]) = cell2mat(cellfun(@(x) ...
    round(getFrameNumfromVideo(datestr(x,'MM:SS.FFF'),fps).*(OBD_Freq/fps)), ...
    eventTime,'UniformOutput',0));

%mapping trip event to OBD data
for eventNum = 1:numEvent
    thisEventTime =  tripEventList(eventNum,timeCol(1)):tripEventList(eventNum,timeCol(2));
    thisEventLen = length(thisEventTime);
    thisEventAttr =  repmat(tripEventList(eventNum,3:end),thisEventLen,1);
    mapTripEvent{thisEventTime,OBDAttrNum+1:end} = thisEventAttr;
end

%downsample for output
mapTripEvent =array2table(mapTripEvent{1:round(1/outDataRate):end,:},...
    'VariableName',mapTripEvent.Properties.VariableNames);

%output: mapTripEvent
%% output result
% write output as csv 
if OutputCSVFile
writetable(mapTripEvent,...
    [outputfolder '_' datestr(now,'dd-mm-yyyy_HH-MM-SS') '.csv'] ,...
    'Delimiter',',','WriteVariableNames',1);
end
% write mat file
if OutputMatFile
    save([outputfolder '_' datestr(now,'dd-mm-yyyy_HH-MM-SS') '.mat'],...
        'mapTripEvent');
end
fprintf(['finished mapping @ ' datestr(now) '!\n']);
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







