function lasomFunctions(instruction)
%
% lasomFunctions(instruction)
% The argument instruction is a string 
%   - 'checkConnection', checks whether a connection to the LASOM can be
%      established, if yes results in a positive message, if no, results in an
%      error message, and will terminate olfStim.
%   - 'connect', establishes a connection to the LASOM
%
% lorenzpammer 2012/07

%% extablish connection to LASOM

if strcmp(instruction,'checkConnection')
    dbstack
    disp(': Checking connection not yet programmed.')
    
elseif strcmp(instruction,'connect')
    lasomH = actxcontrol('LASOMX.LASOMXCtrl.1'); 
    invoke(lasomH, 'DevOpen', 0, 1);
    invoke(lasomH, 'GetLastError');
    invoke(lasomH, 'GetID');
end

end