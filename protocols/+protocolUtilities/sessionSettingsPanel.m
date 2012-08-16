function h = sessionSettingsPanel(h,guiEnlarge,panelPosition)
% sessionSettingsPanel(h,guiEnlarge)
% will add a new panel to h.guiHandle for session settings.
% h is the handle for the olfStim gui.
% guiEnlarge - can either be a 1 or 0, indicating whether function should
% enlarge the gui or not. Will enlarge by the size of the new panel.
%
% lorenzpammer august 2012

%% Check arguments

if nargin < 1
    error('Not enough input arguments.')
end

%% Make gui larger
if guiEnlarge == 1
    guiSize = get(h.guiHandle,'Position');
    guiSize = guiSize + [0 -60 0 60];
    set(h.guiHandle,'Position',guiSize);
end

%% Add panel


if nargin < 3
    olfactometerSettingsPanel = get(h.olfactometerSettings.panel,'Position');
    spacing = 3;
    panelPosition(1) = olfactometerSettingsPanel(1);
    panelPosition(2) = olfactometerSettingsPanel(2) + olfactometerSettingsPanel(4) + spacing;
    panelPosition(3) = olfactometerSettingsPanel(3);
    panelPosition(4) = olfactometerSettingsPanel(4)/2;
end
clear olfactometerSettingsPanel;


h.sessionSettings.panel = uipanel('Parent',h.guiHandle,'Title','Session Settings',...
    'FontSize',8,'TitlePosition','centertop',...
    'Units','pixels','Position',panelPosition,...
    'Tag','sessionSettingsPanel'); % 'Position',[x y width height]


end