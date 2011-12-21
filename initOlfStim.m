function initOlfStim
% olfStim is the wrapper function calling the all necessary steps for odor
% stimulation. The action goes on in the called functions.
% lorenzpammer 2011/07

global smell % smell is the data structure containing all information relevant to the session
global olfactometerOdors % olfactometerOdors is a data structure, that contains information about which odors are loaded into the olfactometer

%% User has to define which odors are loaded into olfactometer
% start by opening the odorSelectionGui. User has to define which odorants
% are loaded in which concentration to which vial and which odors he want
% to use in the experiment.

olfactometerOdors = odorSelectionGui;

%% Set up smell structure
buildSmell('setUp');

%% Next start the gui for controlling 
selectedProtocol = protocolChooserSubGui;


%% Execute selected protocol
functionHandle = str2func(selectedProtocol); % make string of selected protocol to function handle
functionHandle(); % evaluate function handle, i.e. call function

end


