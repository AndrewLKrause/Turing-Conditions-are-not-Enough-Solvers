clear;
%NOTE: Solver only written for 1D
% Set the spatial dimension to be 1D or 2D.
dimensions = 1;

% Show a progress bar?
showProgressBar = false;

% Numerical tolerances (absolute and relative).
tolerance = 1e-9;

% Number of gridpoints per dimension. Use 60-300 or so for 2D, and ideally
% 300-3000 or so for 1D depending on the structures that need to be
% resolved.
m = 1000;

% Total number of gridpoints; varies by dimension as:
% 2D make N=m^2; 1D make N=m;
if (dimensions == 1)
    N = m;
elseif (dimensions == 2)
    N = m^2;
end

setup = 1;

NumRuns = 10000; % Number of runs to check.
Var = 0.05; 

% Time interval to solve the equations on.
T = linspace(0,10000,10);
Patterning = zeros(NumRuns,1);
Patterns = zeros(NumRuns,1);
if (~showProgressBar)
    TextProgressBar('Running: ');
end
InitialU0s = cell(NumRuns,1);

% Seed the random number generator and generate a latin hypercube sample.
rng('default');
LHS=(1-Var+2*Var*lhsdesign(NumRuns,6));

for iRun = 1:NumRuns
    % Domain length
    L = 30*LHS(iRun, 1);

    % Parameters in the reaction kinetics.
    a = 1*LHS(iRun, 2); b = 0.45*LHS(iRun, 3); c = 0.5*LHS(iRun, 4); 

    % Nonlocal interaction strength and range
    d = 20*LHS(iRun, 5);

    % Diffusion rate
    D = 1*LHS(iRun, 6);

    % Spatial step size.
    dx = L/(m-1);

    NonlocalAdvectionSolver;
    if (~showProgressBar)
        TextProgressBar(100 * iRun / NumRuns)
    end
    Patterns(iRun) = max(U(end,ui))-min(U(end,ui));
    Patterning(iRun) = max(abs(U(end,ui)-c))>1e-5;

    % Save.
    InitialU0s{iRun} = U0;
end
save("SystematicRunsNonlocalAdvection.mat");
TextProgressBar('')
