function [CV_result,NN_result] = mapCVNNResult(CV_result_in,NN_result_in)
    % [NN_result,CV_result] = mapCVNNResult(NN_result_in,CVresult_in)
    % Objective: to synchronize the time stamp of Neural network output and
    %            Computer vision output 
    %            Note: time stamp is based on video frames count in
    %            mapDetectLCevent (NN_result), it is asummed that the NN
    %            result mapping frame idx based on more precise video time duration
    %            than the 
    % input    : NN_result_in output generated from Neural network
    %          : CV_result_in output generated from CV part with sync
    %            timestamp
    % output   : sync time stamp of NN and CV result
    % created @ 10/5/2017 tcyu@umich.edu
    
    assert(isa(CV_result_in,'double'),'wrong input format, CV result should be double-array');
    assert(isa(NN_result_in,'table'),'wrong input format, NN result input should be table format');
    
    [NN_y,~] = size(NN_result_in{:,:});
    [CV_y,~] = size(CV_result_in);
    
    if NN_y > CV_y        
        CV_result = [CV_result_in; repmat(CV_result_in(end,:),NN_y-CV_y,1)];
        NN_result = NN_result_in;
    elseif NN_y == CV_y   
        CV_result = CV_result_in;
        NN_result = NN_result_in;
    else
        CV_result = CV_result_in(1:end-abs(NN_y-CV_y),:);
        NN_result = NN_result_in;
    end
    
    
end