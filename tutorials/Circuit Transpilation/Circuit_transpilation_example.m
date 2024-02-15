clc;
clear;
close all;
%%

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";

%% Define backend and access
backend="ibm_cairo";

%% 2. Build Bell State circuit, transpile it using TranspilerService and create a qasm3 string
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

%% transpilationOptions for the transpilerService, this would be optional input to the TranspilerService
%%% Default values: 
%           transpilationOptions.optimization_level=1
%           ranspilationOptions.ai = false
%           transpilationOptions.coupling_map = [];
%           transpilationOptions.qiskit_transpile_options = []; 
%           transpilationOptions.ai_layout_mode  = []; 

transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

%% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%% 1. Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(qasm, backend,transpilationOptions); 

%% 2. Enable the session and Sampler
backend="ibmq_qasm_simulator";

service = QiskitRuntimeService(channel,apiToken,[]);
session = Session(service, backend);

service.Start_session = true; %set to true to enable Qiskit Runtime Session 
options = Options();
options.transpilation_settings.skip_transpilation = true;
sampler = Sampler(session,options);

%% 3. Execute the transpiled circuit using sampler primititve
job1 = sampler.run(transpiled_circuit.qasm);

if isfield(job1,'session_id')
    sampler.session.service.session_id = job1.session_id;
end


%% 4. Retrieve the results back
Results = sampler.Results(job1.id);
Results





