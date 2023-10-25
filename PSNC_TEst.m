clc;
clear;
close all;

data = importdata('15q_op.txt') ; 

Pauli_Term_cell = textscan( data{1,1}(16:end-2), '%s', 'Delimiter',',' );
Pauli_Term = [];
for i=1:length(Pauli_Term_cell{1,1})
    Pauli_Term = [Pauli_Term; convertCharsToStrings(strrep(Pauli_Term_cell{1, 1}{i, 1}, char(39), ''))];
    
end
Pauli_coef_cell = textscan( data{2,1}(23:end), '%s', 'Delimiter',',' );
Pauli_coef = [];
for i=1:length(Pauli_coef_cell{1,1})
    Pauli_coef = [Pauli_coef; convertCharsToStrings(Pauli_coef_cell{1, 1}{i,1})]; 
end
for i =3:length(data)
    Coeff = textscan( data{i,1}, '%s', 'Delimiter',',' );
    Pauli_coef = [Pauli_coef;convertCharsToStrings(Coeff{1,1})];
end


%% Setup IBM Quantum Platform credentials
% channel = "ibm_quantum";
% apiToken = "7d37efbcf8493c120b1a377a5488598dccedcece7291dfc23ded72067d9f15c4a22151274edc408236167c7edd24e9a3f442076dc70222e54cda4d570c734944";
% 
% service = QiskitRuntimeService(channel,apiToken,[]);
% 
% %% Define backend and access
% service.Start_session = false; %set to true to enable Qiskit Runtime Session 
% backend="ibmq_qasm_simulator";
% service.hub = "ibm-q-internal"
% service.group = "deployed"
% service.project = "default"
% %% 1. Enable the session and Sampler
% session = Session(service, backend);  
% sampler = Sampler(session=session);
  
%% 2. Build Bell State circuit
%%
circuit.reps=2;
circuit.entanglement = "pairwise";
circuit.number_qubits = ;
circuit.num_parameters = (circuit.reps+1)*circuit.number_qubits;
circuit.rotation_blocks = ["ry", "ry"];

%%

x0 = -5*ones(circuit.num_parameters,1);

circuit_t = Twolocal(circuit,x0)
plot(circuit_t)

qasm = generateQASM(circuit_t); 

qasm2 = QASM_Gen (circuit_t);

% %% 3. Execute the circuit using sampler primititve
% job1 = sampler.run(circuit_t);
% 
% %% 4. Retrieve the results back
% Results = sampler.Results(job1.id);
% Results
