function mapWLE2TRI(input_filename)
% syncWLE2TRI(input_filename)
% objective: to map synchronized WLE data to TRI neural network input
% format
% input: file name to be mapping of synchronized WLE data
% output: <file name>-OBD.csv <file name>-event.mat file OR
%         <file name>-combined.csv  <file name>-combined.mat
% where the attr list are as following
% event_attrname = {'time','LaneChangeLeft','LaneChangeRight','TurnLeft','TurnRight','GoStraight'};
% OBD_table_headers = {'time','speed','GPS_long','GPS_lat','GPS_heading', ...
%     'long_accel','lat_accel','vector_accel','vert_accel'};
% WLE context/event refer to ref/ txt file
% created at 9/13/2017 tcyu@umich.edu
% updated at 11/6/2017 tcyu@umich.edu :
%            - include physiological signal and combined output option
%% default parameter declaration
% path declaration
input_dir = 'data/';
output_dir = 'output/';
[~,filename,fileformat] = fileparts(input_filename);
% csv attr declaration
csv_attr = repmat('%s',1,26);
OBD_attr = [1 19,20,21,22,23,24,25,26];
event_attr = [1 16 17];
event_attrname = {'time','LaneChangeLeft','LaneChangeRight','TurnLeft','TurnRight','GoStraight'};
OBD_table_headers = {'time','speed','GPS_long','GPS_lat','GPS_heading', ...
    'long_accel','lat_accel','vector_accel','vert_accel'};
Physio_attr = [ 4 11];
Physio_table_headers = {'hr', 'scl'};

% flag to output combined output
combinedOutput = 1;

disp(['from now synchronization starts @ ' datestr(now) ' ...']);
%% program start
%read file
input_file = [input_dir input_filename];
fid = fopen(input_file);
csv_content = textscan(fid,csv_attr,'delimiter',',');
fclose(fid);

%get obd attr/ physiological attr
OBD_content = csv_content(OBD_attr);
Physio_content = csv_content(Physio_attr);

%check and retrieve the least rows of attr ( some sync data may not have
%same row number of the attr!!! such as SongWangTrip4 sync data)!!
min_col = min(cell2mat(cellfun(@(x) length(str2num(char(x(2:end)))), OBD_content,'UniformOutput',0)));
OBD_table_variables = cell2mat(cellfun(@(x) str2num(char(x(2:min_col+1))), OBD_content,'UniformOutput',0));
OBD_data = array2table(OBD_table_variables,'VariableNames',OBD_table_headers);

Physio_table_variables = cell2mat(cellfun(@(x) str2num(char(x(2:min_col+1))), Physio_content,'UniformOutput',0));
Physio_data = array2table(Physio_table_variables,'VariableNames',Physio_table_headers);

%get event attr
event_content = csv_content(event_attr);
%event_table_headers = cellfun(@(x) x(1), event_content);
event_table_variables = cell2mat(cellfun(@(x) str2num(char(x(2:min_col+1))), event_content,'UniformOutput',0));

time_len = length(event_table_variables(:,1));
event_data = [zeros(time_len,4) ones(time_len,1)];

%turning and lane change idx location 
left_turn_idx = event_table_variables(:,2)==1 & ...
             event_table_variables(:,3)==1;
right_turn_idx = event_table_variables(:,2)==1 & ...
             event_table_variables(:,3)==2;
left_change_idx = event_table_variables(:,2)==2 & ...
             event_table_variables(:,3)==1;
right_change_idx = event_table_variables(:,2)==2 & ...
             event_table_variables(:,3)==2;   

% mapping to TRI event list 
event_data(left_turn_idx,:) = repmat([0 0 1 0 0],sum(left_turn_idx),1);
event_data(right_turn_idx,:) = repmat([0 0 0 1 0],sum(right_turn_idx),1);
event_data(left_change_idx,:) = repmat([1 0 0 0 0],sum(left_change_idx),1);
event_data(right_change_idx,:) = repmat([0 1 0 0 0],sum(right_change_idx),1);


event_data_output =  array2table( [event_table_variables(:,1) event_data],...
    'VariableNames',event_attrname);    
         
%% save output

if ~combinedOutput

    output_OBD_Physio = [output_dir filename '-OBD_Physio.csv'];
    output_event = [output_dir filename '-event.mat'];

    writetable([OBD_data Physio_data] ,output_OBD_Physio,'Delimiter',',','WriteVariableNames',1);
    save(output_event,'event_data_output');


    disp(['synchronization complete @ ' datestr(now) ' ...']);
    disp(['OBD_phy file saved as ' output_OBD_Physio]);
    disp(['event file saved as ' output_event]);
elseif  combinedOutput
     % remove time component which stated at OBD_data
     event_data_output = event_data_output(:,2:end); 
     
     % output file name
     output_combined = [output_dir filename '-combined.csv'];
     output_combined_mat = [output_dir filename '-combined.mat'];
     
     
     combined_data = [OBD_data Physio_data event_data_output];
     
     
     writetable(combined_data ,output_combined,'Delimiter',',','WriteVariableNames',1);
     save(output_combined_mat,'combined_data');
     disp(['synchronization complete @ ' datestr(now) ' ...']);
     disp(['Combined file saved as ' output_combined]);
end
    


end