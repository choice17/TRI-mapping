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

look at the main() for function demonstration

    