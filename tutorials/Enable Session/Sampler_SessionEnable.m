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
% Setup IBM Quantum credentials
apiToken = 'Put your IBM Quantum API Token here';

service = QiskitRuntimeService(apiToken);
service.Start_session = true;

backend="ibmq_qasm_simulator"; 

%% 1. Enable the session and Estimator
session = Session(service, backend);  
sampler = Sampler(session=session);
  
%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]);

%% 3. Execute the circuit using sampler primititve
job1 = sampler.run(c1);

%% 4. Retrieve the results back
Results = sampler.Results(job1.id,session.service.Access_API);
Results

%% Execute the next job using the session_id of the first job if Start_session is true!
c2 = quantumCircuit([hGate(1) cxGate(1,2)]);
job2 = sampler.run(c2);
