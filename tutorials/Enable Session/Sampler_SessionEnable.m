% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

clc;
clear;
close all;
%%
% Setup IBM Quantum cloud credentials
% channel = "ibm_cloud";
% apiToken = 'MY_IBM_CLOUD_API_KEY';
% crn_service = 'MY_IBM_CLOUD_CRN';
% 
% service = QiskitRuntimeService(channel,apiToken,crn_service);


%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";


service = QiskitRuntimeService(channel,apiToken,[]);

%% Define backend and access
service.Start_session = true; %set to true to enable Qiskit Runtime Session 
backend="ibm_lagos";

% service.hub = "hub";
% service.group = "group";
% service.project = "project";
%% 1. Enable the session and Sampler
session = Session(service, backend);

options = Options();
options.transpilation_settings.skip_transpilation = true;
sampler = Sampler(session,options);

%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]);

%% 3. Execute the circuit using sampler primititve
job1 = sampler.run(c1);

if isfield(job1,'session_id')
    sampler.session.service.session_id = job1.session_id;
end


%% 4. Retrieve the results back
Results = sampler.Results(job1.id);
Results

%% Execute the next job using the session_id of the first job if Start_session is true!
c2 = quantumCircuit([hGate(1) cxGate(1,2)]);
job2 = sampler.run(c2);
