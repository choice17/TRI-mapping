%% demo usage of mapCVNNResult
% see more details by <help mapCVNNResult>

clearvars;
close all;

addpath include;
load('data/122_umtri0720_05-10-2017_15-18-48.mat');
load('data/detect_result_122_20171005_1524.mat')

CV_result = mapDetectLCevent;
NN_result = mapEventMat;

[CV_result,NN_result] = mapCVNNResult(CV_result,NN_result);