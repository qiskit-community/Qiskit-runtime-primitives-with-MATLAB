clc;
clear;
close all;
%%

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "token";

%% Define backend and access
backend="ibm_cairo";

%% 2. Build Bell State circuit, transpile it using TranspilerService and create a qasm3 string
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

%% Parameters for the transpilerService, this would be optional input to the TranspilerService 
params.ai = true;
params.optimization_level = 2;
params.coupling_map = [];
params.qiskit_transpile_options = []; %% Find the keys and values of this Dic!
params.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

channelInfo.token = apiToken;
channelInfo.channel = channel;

%% Transpile the circuit
cloud_transpiler_service = TranspilerService(backend, channelInfo,params);
transpiled_circuit = cloud_transpiler_service.run(qasm);

%% 1. Enable the session and Sampler
backend="ibmq_qasm_simulator";

service = QiskitRuntimeService(channel,apiToken,[]);
session = Session(service, backend);

service.Start_session = true; %set to true to enable Qiskit Runtime Session 
options = Options();
options.transpilation_settings.skip_transpilation = true;
sampler = Sampler(session,options);

%% 3. Execute the circuit using sampler primititve

job1 = sampler.run(transpiled_circuit.qasm);

if isfield(job1,'session_id')
    sampler.session.service.session_id = job1.session_id;
end


%% 4. Retrieve the results back
Results = sampler.Results(job1.id);
Results





