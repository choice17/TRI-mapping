function main()

%% mapping WLE data to TRI compatible format
% for sync detail please try <help(syncWLE2TRI)>
%% add path
clear;close;
addpath include;

%% configuration
% file stored in data/ to be mapping

input_file=['SongWangTrip' num2str(5) '_synchronized data.csv'];
mapWLE2TRI(input_file);

%% reference information about the event/context attr in wle sync data
% >tri_attr
% time,speed,gps_long,gps_lat,heading,long_acc,lat_acc,vector_accel,vert_accel
% 
% >event_attr
% time,l_lc,r_lc,l_turn,r_turn,gostraight
% 
% >wle
% ?Event:
% 0:No event
% 1:Turn
% 2:Lane Change
% 3:Merge
% 4:Intersection
% 5:No Lane Change
% Context:
% 0: no turn
% 1:left
% 2:right


end


