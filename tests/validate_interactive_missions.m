function validate_interactive_missions
%VALIDATE_INTERACTIVE_MISSIONS Check catalog discovery and mission resume state.
% Run with Interactive Missions and Control System Toolbox installed.
% Each reset executes in a separate function workspace, leaving base variables
% unchanged. Only figures created by that reset are closed after inspection.

repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
catalog = interactiveMissions.catalog( ...
    MarketplaceRoot=repositoryRoot, Audience="learner");
assert(height(catalog) == 1, 'Expected one learner-visible starter mission.');
assert(catalog.MissionName == "cruise-control-lqr");
assert(catalog.MarketplaceSource == "matlab-control-systems-tutorial");
assert(catalog.TaskCount == 5 && ~catalog.AllowAgentEdits);
assert(isequal(catalog.TaskIds{1}, ["t01"; "t02"; "t03"; "t04"; "t05"]));
assert(isequal(catalog.Products{1}, ["MATLAB"; "Control System Toolbox"]));

resetFolder = fullfile(repositoryRoot, 'missions', 'cruise-control-lqr', ...
    'task_reset_cruise-control-lqr');
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(resetFolder);
for taskNumber = 2:5
    validateReset(taskNumber);
    fprintf('PASS: resume task %d restores preceding task state.\n', taskNumber);
end
fprintf('PASS: catalog discovers the five-task mission with required metadata.\n');
clear pathCleanup
end

function validateReset(taskNumber)
originalFolder = pwd;
existingFigures = findall(groot, 'Type', 'figure');
unrelatedSentinel = pi;

% Only these four authored reset scripts may be evaluated here.
assert(ismember(taskNumber, 2:5));
eval(sprintf('reset_t%02d;', taskNumber));
resetFigures = setdiff(findall(groot, 'Type', 'figure'), existingFigures);
figureCleanup = onCleanup(@() close(resetFigures(isgraphics(resetFigures))));

assert(strcmp(pwd, originalFolder), 'A reset changed the current folder.');
assert(unrelatedSentinel == pi, 'A reset cleared unrelated workspace state.');
assert(isa(cruisePlant, 'ss') && cruisePlant.Ts == 0);
assert(isequal(size(cruisePlant), [1 1]));
assert(abs(cruisePlant.A + 0.5) < 1e-12);
assert(abs(cruisePlant.B - 0.01) < 1e-12);
assert(cruisePlant.C == 1 && cruisePlant.D == 0);

if taskNumber >= 3
    expectedTime = (0:0.01:12)';
    expectedOpen = 10*(1-exp(-0.5*expectedTime));
    assert(isequal(cruiseTime, expectedTime));
    assert(max(abs(reshape(openVelocity, [], 1)-expectedOpen)) < 1e-6);
    assert(isscalar(resetFigures), 'Expected the original response figure.');
    responseLine = findall(resetFigures, 'Type', 'line');
    assert(isscalar(responseLine));
    assert(max(abs(responseLine.XData(:)-expectedTime)) < 1e-12);
    assert(max(abs(responseLine.YData(:)-expectedOpen)) < 1e-6);
    responseAxes = ancestor(responseLine, 'axes');
    assert(strcmp(responseAxes.XLabel.String, 'Time (s)'));
    assert(strcmp(responseAxes.YLabel.String, 'Speed (m/s)'));
end

if taskNumber >= 4
    assert(abs(plantPoles + 0.5) < 1e-12);
    assert(controllabilityRank == 1);
end

if taskNumber >= 5
    % Independent scalar Riccati solution and analytic closed-loop response.
    expectedGain = sqrt(50^2 + 1000/0.1)-50;
    assert(abs(lqrGain-expectedGain) < 1e-9);
    assert(abs(dcgain(cruiseClosedLoop)-1) < 1e-12);
    assert(abs(pole(cruiseClosedLoop)+(50+expectedGain)/100) < 1e-12);
    expectedClosed = 10*(1-exp(-(50+expectedGain)/100*cruiseTime));
    actualClosed = step(10*cruiseClosedLoop, cruiseTime);
    assert(max(abs(actualClosed(:)-expectedClosed)) < 1e-6);
    assert(stepinfo(cruiseClosedLoop).SettlingTime < ...
        stepinfo(cruisePlant).SettlingTime);
end

% Resuming must not solve the active task.
switch taskNumber
    case 2
        assert(~exist('openVelocity', 'var'));
    case 3
        assert(~exist('plantPoles', 'var'));
    case 4
        assert(~exist('lqrGain', 'var'));
    case 5
        assert(~exist('closedVelocity', 'var'));
end
clear figureCleanup
end
