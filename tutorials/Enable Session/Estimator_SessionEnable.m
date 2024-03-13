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
%% Setup IBM Quantum cloud credentials

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
if service.Start_session ==true;
    service.session_mode = "batch";
end

backend="ibm_kyoto";

%% 1. Enable the session and Estimator
session = Session(service, backend);  

options = Options();
options.transpilation_settings.skip_transpilation = false;
estimator = Estimator(session,options);

%% 2. Mapping the problem (H2 molecule) to qubits/Quantum Hamiltonian
%%% The Hamiltonian (Pauli terms and coefficients) for a bonding distance
%%% of 0.72 Angstrom will be:
hydrogen_Pauli = ["II","IZ","ZI","ZZ","XX"];
coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);


hamiltonian.Pauli_Term = hydrogen_Pauli;
hamiltonian.Coeffs = coeffs;

%% 3. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2) ]); 

qasm= generateQASM(c1);

%% 4. TranspilationOptions for the transpilerService, this would be optional input to the TranspilerService
transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

%% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%% 4.1 Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(qasm, backend,transpilationOptions); 

%% 5. Execute the circuit using estimator primititve
job1 = estimator.run(transpiled_circuit.qasm,hamiltonian);

if isfield(job1,'session_id')
    estimator.session.service.session_id = job1.session_id;
end
%% 5.1 Retrieve the results back
Results = estimator.Results(job1.id);
Results

%% Execute the next job using the session_id of the first job if Start_session is true!
c2 = quantumCircuit([hGate(1) cxGate(1,2)]);
job2 = estimator.run(c2,hamiltonian);
