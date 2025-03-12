load -hdf5 Monostat.h5
% Get a list of all variables
var_list = who();

% Initialize empty arrays for I and Q
I_data = [];
Q_data = [];


% Loop through variables and extract I and Q chunks
for i = 1:length(var_list)
    var_name = var_list{i};

    if endsWith(var_name, "_I")
        I_data = [I_data,eval(var_list{i})];  % Append to I_data
        eval(['clear ', var_name]);  % Delete the variable A
    elseif endsWith(var_name, "_Q")
        Q_data = [Q_data,eval(var_list{i})];  % Append to Q_data
        eval(['clear ', var_name]);  % Delete the variable A
    end
end


disp("Finished assembling I and Q arrays.");

##plot(I_data)

