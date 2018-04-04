function mapEventDetect(input_file,videoLength,begin_time, varargin )
% mapEventDetect(input_file,videoLength,begin_frame, varargin )
% Objective: to map detected event to video frame
% input: 
%   begin_frame - index
%   input_file - input file name in data/
%   videoLength - target composed video length
%   default: 'windowSize'=1 | 'dataFreq'=10 | 'fps'=29.97 | 'attrLen'=5
% output:
%   mapEventMat - table: [frameidx left_LC right_LC left_turn right_turn go_straight]
% version1.0 6/9/2017 :first creation tcyu@umich.edu

mapEventMat_var = {'frameIdx','leftLC','rightLC','leftT','rightT','goStraight'};
[~,outputname] = fileparts(input_file);
disp(['start maping event at ' datestr(now)]); 
%% initialize parameter
windowSize = 1;
dataFreq = 10;
fps = 29.97;
attrLen = 5;

varLen = length(varargin);
for i = 1:2:varLen
    switch varargin{i}
        case 'windowSize'
            windowSize = varargin{i+1};
        case 'dataFreq'
            dataFreq = varargin{i+1};
        case 'fps'
            fps = varargin{i+1};
        case 'attrLen'
            attrLen = varargin{i+1};
    end
end

beginFrameIdx = round(fps*begin_time+windowSize*fps);
%% load input file
load(['data/' input_file]);

% initialize empty matrix
frameLen = round(fps*videoLength);
mapEventMat = [(1:frameLen)' zeros(frameLen,attrLen-1) ones(frameLen,1)];

if fps>dataFreq
    upsampleRate = round(fps/dataFreq);
    detect_result_resample = reshape(repmat(detect_result,1,upsampleRate)', ...
                                    attrLen,[])';
    
elseif fps<dataFreq
    disp('currently not support downsample')
    return 
end

detect_result_len = size(detect_result_resample,1);
mapEventMat(beginFrameIdx:beginFrameIdx+detect_result_len-1,2:end) = ...
    detect_result_resample;

%% save table
mapEventMat = array2table(mapEventMat,'VariableNames',mapEventMat_var);
outputname = [outputname '-' datestr(now,'yyyymmdd_HHMM') '.mat'];
save(['output/' outputname],'mapEventMat');

disp(['completed at' datestr(now)]); 
disp(['file saved at output/' outputname]); 
end

           
        
        
