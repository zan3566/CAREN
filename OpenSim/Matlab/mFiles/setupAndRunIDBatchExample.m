% ----------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and           %
% simulation. See http://opensim.stanford.edu and the NOTICE file         %
% for more information. OpenSim is developed at Stanford University       %
% and supported by the US National Institutes of Health (U54 GM072970,    %
% R24 HD065690) and by DARPA through the Warrior Web program.             %
%                                                                         %   
% Copyright (c) 2005-2017 Stanford University and the Authors             %
%                                                                         %   
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %
function setupAndRunIDBatchExample(source, destination)

%% Example
% addpath('C:\Users\mhossein\Documents\OpenSim\4.0\Code\Matlab');
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\IDXMLs_TargetSerach';
% destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\JS\';
% setupAndRunIDBatchExample(source, destination)



%% Now Copy the relvenat xml file for this person.

ik_results_folder = fullfile(destination,'IKResults');
GRF_results_folder = fullfile(destination,'grfResults');
results_folder = fullfile(destination,'IDResults');
setupfiles_folder = fullfile(destination,'IDSetup');
% genericSetupForIK = 'IK_HBM_Setup.xml';
copyfile(source, setupfiles_folder)
modelFile = 'subject01_simbody.osim';
model_folder = fullfile(destination,'ScaledModel');


% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

% move to directory where this subject's files are kept
% subjectDir = uigetdir('./DF1', 'Select the folder that contains the current subject data');

% Go to the folder in the subject's folder where IK Results are
% ik_results_folder = fullfile(subjectDir, 'IKResults');

% Go to the folder in the subject's folder where GRF data Results are
% GRF_results_folder = fullfile(subjectDir, 'grfResults');

% specify where setup files will be printed.
% setupfiles_folder = fullfile(subjectDir, 'IDSetup');

% specify where results will be printed.
% results_folder = fullfile(subjectDir, 'IDResults');

% specify where scaledModel will be printed.
% model_folder = fullfile(subjectDir, 'ScaledModel');
% %% To send an email at the end of this function define these variables appropriately:
% % more details available here:
% % http://www.mathworks.com/support/solutions/en/data/1-3PRRDV/
% %
% mail = 'youremailaddress@gmail.com'; %Your GMail email address
% password = 'yourPassword'; %Your GMail password
% 
% % Then this code will set up the preferences properly:
% setpref('Internet','E_mail',mail);
% setpref('Internet','SMTP_Server','smtp.gmail.com');
% setpref('Internet','SMTP_Username',mail);
% setpref('Internet','SMTP_Password',password);
% props = java.lang.System.getProperties;
% props.setProperty('mail.smtp.auth','true');
% props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
% props.setProperty('mail.smtp.socketFactory.port','465');

%% Get and operate on the files

subjectNumber = 'subject01';
% genericSetupForAn = fullfile(setupfiles_folder, [subjectNumber '_Setup_Analyze_generic.xml']);
genericSetupForAn = fullfile(setupfiles_folder, ['ID_HBM_Setup.xml']);

% analyzeTool = AnalyzeTool(genericSetupForAn);
idanalyzeTool = InverseDynamicsTool(genericSetupForAn);
    
% get the file names that match the ik_reults convention
% this is where consistent naming conventions pay off
trialsForAn = dir(fullfile(ik_results_folder, '*_ik.mot'));
trialsForAnGRF = dir(fullfile(GRF_results_folder, '*.mot'));
osimScaled = dir(fullfile(model_folder, 'subject01_simbody.osim')); % correct this if needed esp. for RRA etc
nTrials =length(trialsForAn);

import org.opensim.modeling.*
for trial= 2:nTrials
    
    % get the name of the file for this trial
    motIKCoordsFile = trialsForAn(trial).name;
    motGRFCoordsFile = trialsForAnGRF(trial).name;
    
    % create name of trial from .trc file name
    name = regexprep(motIKCoordsFile,'_ik.mot','');
    nameGRF = regexprep(motGRFCoordsFile,'.mot','');
    
    % get .mot data to determine time range change this to proepr API code
    % instead of Storage!
    motCoordsData = Storage(fullfile(ik_results_folder, motIKCoordsFile));
    motGRFCoordsData = Storage(fullfile(GRF_results_folder, motGRFCoordsFile));
          
% motCoords = STOFileAdapter.read(fullfile(ik_results_folder, motIKCoordsFile));
% % motCoordsData = osimTableToStruct(motCoords);
% motGRFCoords = STOFileAdapter.read(fullfile(GRF_results_folder, motGRFCoordsFile));
% motGRFCoordsData = osimTableToStruct(motGRFCoords);
    
    
    % for this example, column is time
    initial_time = motCoordsData.getFirstTime();
    final_time = motCoordsData.getLastTime();
    
    idanalyzeTool.setName(name);
    idanalyzeTool.setResultsDir(results_folder);
    idanalyzeTool.setModelFileName(fullfile(model_folder, osimScaled.name));
    model = Model(fullfile(model_folder, osimScaled.name));
    model.initSystem();
    idanalyzeTool.setModel(model);

 
    idanalyzeTool.setCoordinatesFileName(fullfile(ik_results_folder, motIKCoordsFile));
    idanalyzeTool.setStartTime(initial_time);
    idanalyzeTool.setEndTime(final_time); 
    
        % no model needed for Externalloads defintion so do as below
    % i dont know why extenral loads does not work check this tomorrow
    % get and set up GRF in xml
%     ExtLoads = ExternalLoads(model,[setupfiles_folder '\GRF.xml']);
%     ExtLoads = ExternalLoads([model_folder '\GRF.xml'],1); % setupfiles_folder
    setup1 = fullfile(setupfiles_folder,'GRF.xml');
% ExtLoads = ExternalLoads([setupfiles_folder 'GRF.xml'],1); % setupfiles_folder
    ExtLoads = ExternalLoads(setup1,1); % setupfiles_folder
%     ExternalLoads.invokeConnectToModel(model)
    extloadpath = fullfile(GRF_results_folder, motGRFCoordsFile);
%     [setupfiles_folder '\GRF.xml'];
    ExtLoads.setDataFileName(extloadpath);
    setup2 = fullfile(setupfiles_folder,'GRF1.xml');
    ExtLoads.print(setup2)
%     ExtLoads.print([setupfiles_folder 'GRF1.xml'])
%     https://github.com/opensim-org/opensim-core/issues/2076 
%     idanalyzeTool.setExternalLoadsFileName([setupfiles_folder 'GRF1.xml'])
    idanalyzeTool.setExternalLoadsFileName(setup2)
    idanalyzeTool.setOutputGenForceFileName([name '_ID.sto'])
%     statop.setExternalLoadsFileName([setupfiles_folder 'extForces_Setup.xml']);
    
%     
%     analyzeTool.setResultsDir(results_folder);
%     analyzeTool.setCoordinatesFileName(fullfile(ik_results_folder, motIKCoordsFile));
%     analyzeTool.setInitialTime(initial_time);
%     analyzeTool.setFinalTime(final_time);   
    
    outfile = ['Setup_Analyze_' name '.xml'];
    idanalyzeTool.print(fullfile(setupfiles_folder, outfile));
    cd(results_folder)
    idanalyzeTool.run();
    fprintf(['Performing ID on cycle # ' num2str(trial) '\n']);
    
    % rename the out.log so that it doesn't get overwritten
%     copyfile('out.log', fullfile(results_folder, [name '_out.log']));
    
end
%sendmail(mail,subjectNumber, ['Hello! Analysis for ' subjectNumber '  is complete']);


