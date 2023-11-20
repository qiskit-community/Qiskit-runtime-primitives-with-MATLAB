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

%%
service.program_id = "estimator";
service.Start_session = true;
backend="ibmq_qasm_simulator";

% service.hub = "hub";
% service.group = "group";
% service.project = "project";

%% 1. Enable the session and Estimator
session = Session(service, backend);  

options = Options();
options.transpilation_settings.skip_transpilation = false;
estimator = Estimator(session,options);

%% 1. Mapping the problem (H2 molecule) to qubits/Quantum Hamiltonian
%%% The Hamiltonian (Pauli terms and coefficients) for a bonding distance
%%% of 0.72 Angstrom will be:
hydrogen_Pauli = ["II","IZ","ZI","ZZ","XX"];
coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);

hamiltonian.Pauli_Term = hydrogen_Pauli;
hamiltonian.Coeffs = coeffs;


%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

%% 3. Execute the circuit using estimator primititve
job1 = estimator.run(c1,hamiltonian);

if isfield(job1,'session_id')
    estimator.session.service.session_id = jo1.session_id;
end
%% 4. Retrieve the results back
Results = estimator.Results(job1.id);
Results

%% Execute the next job using the session_id of the first job if Start_session is true!
c2 = quantumCircuit([hGate(1) cxGate(1,2)]);
job2 = estimator.run(c2,hamiltonian);
