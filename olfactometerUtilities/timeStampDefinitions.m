function olfactometerInstructions = timeStampDefinitions(olfactometerInstructions)
% timeStampDefinitions holds the definitions for the mapping of
% olfactometer events to time stamp values, and adds this information
% to the olfactometerInstructions structure.
%
% timeStampDefinitions(olfactometerInstructions) has
% olfactometerInstructions as an argument, and adds the timeStampIDs
% (values of timestamps for the different events), which are defined in
% this function to the olfactometerInstructions structure. It then returns
% the populated olfactometerInstructions to the calling function.
%
% lorenzpammer 2012/07


%% Define the time stamp values for the different events

timeStampIDs(1).name = 'powerGatingValve';
% timeStampIDs(1).timeStampValue = 1;
timeStampIDs(1).timeStampValue = '1000';

timeStampIDs(8).name = 'unpowerGatingValve';
% timeStampIDs(8).timeStampValue = 2;
timeStampIDs(8).timeStampValue = '1000';

timeStampIDs(2).name = 'powerFinalValve';
% timeStampIDs(2).timeStampValue = 3;
timeStampIDs(2).timeStampValue = '0001';

timeStampIDs(7).name = 'unpowerFinalValve';
% timeStampIDs(7).timeStampValue = 4;
timeStampIDs(7).timeStampValue = '0001';

timeStampIDs(3).name = 'closeSuctionValve';
% timeStampIDs(3).timeStampValue = 5;
timeStampIDs(3).timeStampValue = '0100';

timeStampIDs(6).name = 'openSuctionValve';
% timeStampIDs(6).timeStampValue = 6;
timeStampIDs(6).timeStampValue = '0100';

timeStampIDs(4).name = 'openSniffingValve';
% timeStampIDs(4).timeStampValue = 7;
timeStampIDs(4).timeStampValue = '0010';

timeStampIDs(5).name = 'closeSniffingValve';
% timeStampIDs(5).timeStampValue = 8;
timeStampIDs(5).timeStampValue = '0010';

timeStampIDs(11).name = 'powerHumidityValve';
% timeStampIDs(11).timeStampValue = 9;
timeStampIDs(11).timeStampValue = [];

timeStampIDs(12).name = 'unpowerHumidityValve';
% timeStampIDs(12).timeStampValue = 10;
timeStampIDs(12).timeStampValue = [];

timeStampIDs(9).name = 'purge';
% timeStampIDs(9).timeStampValue = 11;
timeStampIDs(9).timeStampValue = [];

timeStampIDs(10).name = 'cleanNose';
% timeStampIDs(10).timeStampValue = 12;
timeStampIDs(10).timeStampValue = [];



%% Write time stamp values into olfactometerInstructions structure

for i = 1 : length(olfactometerInstructions)
    index = find(strcmp({timeStampIDs.name},olfactometerInstructions(i).name));
    if length(index) > 1
        error('Too many matching fields were found.')
    end
    olfactometerInstructions(i).timeStampID = timeStampIDs(index).timeStampValue;
end
clear index;

end
