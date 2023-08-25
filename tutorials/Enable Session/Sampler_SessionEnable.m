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
service.Start_session = false; %set to true to enable Qiskit Runtime Session 
backend="ibmq_qasm_simulator";
% service.hub = "your-hub"
% service.group = "your-group"
% service.project = "your-project"

%% 1. Enable the session and Sampler
session = Session(service, backend);  
sampler = Sampler(session=session);
  
%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]);

%% 3. Execute the circuit using sampler primititve
job1 = sampler.run(c1);

%% 4. Retrieve the results back
Results = sampler.Results(job1.id);
Results

%% Execute the next job using the session_id of the first job if Start_session is true!
c2 = quantumCircuit([hGate(1) cxGate(1,2)]);
job2 = sampler.run(c2);
