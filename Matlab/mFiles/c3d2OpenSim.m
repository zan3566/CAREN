%% Header file from CAREN to Paper!
% Let's get c3d files and do the following: analyses, model development and produce new results!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. import trc and mot using runOpensim.m
%2. Collect all revelant data using Data_Collection_OpenSim.m e.g. all TRC
%for gait events, D and ND events,
%3. Get gait events using trcGaitEvents.m i.e. timing  (D and ND), etc,
%4. Gait paramers: COM, COP, MOS, SL, SF, ....get them all as struct
%5. Read DFLOW data (if missing then reproduce using c3d and foot markers)so we have Belt
%velocity,pertub timing, and CAREN data
%% In Opensim do the following
%5. In OpenSim: run Scaling (Note: there are manual work here) -
%InverseKinematic(IK) - Inverse Dynamics(ID) - RRA - SO - CMC -FD - Muslce contribution - JRF and ...etc
%6.
%7. Synch the DFLOW and C3D from Vicon: if DFLOW is not avaiable reproduce
%belt velcoty from feet (or platform markers) %markers as mentioned above and now we have clean data and Synched
%8.
%9.
%9.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualization
%1. For Visualization and postprocessing use the following scritps.
%1.
%1.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author(s): Dr.Hossein Mokhtarzadeh
% Date: 8 July 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% RoadMap for Stability and gait parameters, OpenSim
% Fig. (3) in (Gordon DFN, et al.,2018;5:1?16),good for my roadMap!

% Preprocessing
% naming of files, cleaning up and events, pertub Ok, etc...check all details

% Analyses
%                                 FullBody OpenSim
%                                    |
%                                    |
% c3d + generic model OpenSim ---> scaled ---> IK ---> ID ---> SO ---> JRF,
% c3d ---> trc + mot --->     ---> GRF            ---> RRA        ---> CMC ---> Metabolic Caculation
%              |                                                           ---> Muscle  Contr
%              |                                                           ---> ....
%              |                                                           ---> ....
% TRCs ---> gait events, gait stability parameters ---> SL, SF,
%                                                  ---> D/ND
%                                                  ---> MoS
%                                                  ---> CoM (can come from OpenSim)
%                                                  ---> Belt Speed
%                                                  ---> Pre/Post Pertub Event
%                                                  --->
%
% DFLOW ---> BeltSpeed, Pertub timing, match w/TRC ---> Compare w TRCs Belt Speed

%Questions to handle: Nans, Pertub No, Missign Data, how to save data,
%plots, check ups error gathering at each step, manual work for cleaning

% Postprocessing e.g. Visualize etc

%% 0. Setup Environment
% Before running the program, make sure you have install the dependency
% between matlab and opensim software. For more information please visit : 
% https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab

%Attention : below variables are declared in global scope! For more
%information, please type help global in the command window.

% The openSimPATH variable is the path of the opensim-matlab dependency. 
t1=clock;
global openSimPath;
openSimPath = '/Applications/OpenSim 4.0/OpenSim 4.0.app/Contents/Resources/OpenSim/Resources/Code/Matlab';

% The source is the path to the data 
global source;
source = '/Users/duoyizhang/Intern2019Summer/Data';

% Code repository
global codeRepo;
codeRepo = '/Users/duoyizhang/Intern2019Summer/OpenSim/Matlab/mFiles';
%% 1. Import TRC and MOT files
%TODOs
%make sure CoP is correct I see some big changes as filtering happens in
%all cycle.
% time = each sesseion about 2-3hr
% make it in a folder to read all the folder and run them in one go so make
% it a loop to read dirIn in sequqnce and keep going

addpath(openSimPath);
% dirIn = 'D:\Intern2019Summer\Data'; % or loop
dirIn = source;
%  dirIn = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH-Filtered';
% dirIn = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\Chrion Testing\Targetsearch\NoSuit';
% dirIn = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\Chrion Testing\Targetsearch\Suit';
runOpensim(dirIn,1,10,4)

%% 2. Collect all revelant data using Data_Collection_OpenSim.m e.g. all TRC, MOT, etc
% Note I think I should put the data cpollecton at the very end unless they
% are needed. e.g. IK is fast so it can be done. The order here might
% change as we go...
% time = each sesseion about 1hr
%for gait events, get the following trcs, grfs (15min exlcuding calibration), and all otehr as you
%simulate
addpath(openSimPath);

% run C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab\Data_Collection_OpenSim.m % not auto manual
% Automatic just provide source directory and the type of file to collect

%this script below collects everything after we have the data. I think I
%shuld collect and if something is missing, I will take care of it in
%visualization and analyses.. Go for it Hossein this is great! :)
FileType = {'trc', 'IK', 'ID', 'SO', 'GRF'};
cd(codeRepo);
for i=1:length(FileType)
    Data_Collection_OpenSim_Auto(source,FileType{i})
    cd(codeRepo);
end

%% 3. Get gait events using trcGaitEvents.m i.e. timing, etc
% time = each sesseion about 0.5hr
addpath(openSimPath);
cd(codeRepo);
gaitEvents = trcGaitEvents(source);
% figure;title('FS Left side');vline(gaitEvents.data.HSLocL) % plot the TO for left side or
% figure;title('FSright side');vline(gaitEvents.data.HSLocR) % plot the TO for right side
%

%% Pertubation either from DFLOw files (Belt Speed) or predicton from TRC files
% make sure allt the names are correct in the DFLOW folder
% first do the following for checking all the pertubation, belt speeds and whether they are missing or not

% 1.
addpath(openSimPath);
% 2. change this accordingly or make it automated later on
trcPath = fullfile(source,'trcResults');
cd(codeRepo)
disp(trcPath);
%or CAREFul SAVING AS WELL:
% 5. Careful this below will save it and overwrite so be careful dude!
%[framePerturb, BeltVelPredict,FootVelL, FootVelR] = dflowReproduceTRC_alignSignal(trcPath,1, 1); %plot, SAVE

% now we know pretty much all the predicted and actual data whenver
% possible into the outcomes of last function

% Now we need to use dflow.m to get actul pertubation, belt speed and if
% they are missing, we will fill them from the above function that we
% already collected...
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
cd(codeRepo);
[missginFiles, BeltVel, Perturb] = dflow(source, 1, 1);

% now we have all the BeltVel, Pertub timing, frame etc. hopefully by now
% we have gaitevents, timing of pertub and all we need for furthur to limit
% our findings. e.g. if we want muscle forces between certain time points,
% we can simply load gaitevent adn/or dflow outcomes to detect the timings
% we need and plot in beween. so now let's go ahead with TRC and GRF files
% to continue with OPenSim before that check and make sure you OpenSim
% files are ready, mfiles, scale model, proper generic model, etc.

%% MoS calcualton and getting gaitUtils in trcFolder (margin of stability, LR things, campring the dflow with the belt speed. for validation.) 
addpath(openSimPath);
cd(codeRepo)
% 2. run this beaut below:
[mos_AP mos_ML bos_AP bos_ML, com_vel XCOM COM] = MoS(source,-1) % -1: no saving, 1:saving as gaitUtils.mat in trcResults folder
close all
%% scaling
% TODOs make it a loop for all the subjects
% time = each sesseion about 2hr
%addpath('/Applications/OpenSim 4.0/OpenSim 4.0.app/Contents/Resources/OpenSim/Resources/Code/Matlab');
cd(codeRepo);
%
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\ScalingXMLs_TargetSearch\';
% destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% for i=1:n
%     %find the revelant destination and then run ScalingProcess
% end
% but I guess it is still good to do it one by oone and check all the details
changes.mass = 85;% add mass of the person kg
changes.lock = 1; % if 1 then the feet joints are locked other wise, all is free
xmlSource = '/Users/duoyizhang/Intern2019Summer/OpenSim/OpenSim_requirments/ScalingXMLs_TargetSearch/';
destination = source;
ScalingProcess(xmlSource, destination, changes)


%% Inverse Kinematics
% time = each sesseion about ~5min for 50files or ?
addpath(openSimPath);
newSource = '/Users/duoyizhang/Intern2019Summer/OpenSim/OpenSim_requirments/IKXMLs_TargetSerach/';
cd(codeRepo);
%  destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';

setupAndRunIKBatchExample(newSource, destination)

%% Inverse Dynamics
% time = each sesseion about ~5min for 50files or ?
addpath(openSimPath);
newSource = '/Users/duoyizhang/Intern2019Summer/OpenSim/OpenSim_requirments/IDXMLs_TargetSerach/';
destination = source;
cd(codeRepo);
setupAndRunIDBatchExample(newSource, destination)


%% RRA
% time = each sesseion about ~5min for 50files or ?
addpath(openSimPath);
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\RRAXMLs_TargetSerach\';
% destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
newSource = '/Users/duoyizhang/Intern2019Summer/OpenSim/OpenSim_requirments/RRAXMLs_TargetSerach/';
destination = source;
cd(codeRepo);
setupAndRunRRABatchExample(newSource, destination)


%% Static Optimization (SO)
% time = each sesseion about ~5min for 50files or ?
% Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
addpath(openSimPath);
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
newSource = '/Users/duoyizhang/Intern2019Summer/OpenSim/OpenSim_requirments/SOXMLs_TargetSerach/';
destination = source;
cd(codeRepo);
setupAndRunSOBatchExample(newSource, destination,-1)
t2=clock;
etime(t2,t1)

%%
% %% IA (IA) following SO
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% 
% %% IA (IA) following CMC
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% Joint Reaction Analysis (JRA)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% Joint Reaction Analysis (JRA)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% 
% %% Muscle Analysis(MA)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% Metabolic Cost(MC)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% Stability Measures via OpenSim (SMO)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% Predictive Modeling(PM)
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% %% ML/AI(AI in TF)Py or Ipython
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% 
% 
% 
% %% Do all in Py honeys check GEM frm MIT
% % time = each sesseion about ~5min for 50files or ?
% % Keep this in mind that I have changed the low-pas fileter in the setup file to 4 and works for all for now
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab')
% % source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\SOXMLs_TargetSerach\';
% % destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\SH\';
% 
% 