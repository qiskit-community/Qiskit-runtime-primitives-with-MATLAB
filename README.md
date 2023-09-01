# MATLAB and Qiskit Runtime Primitives (Sampler and Estimator)

The Qiskit Runtime service bridges the gap between several programming languages and quantum computing frameworks by being language-agnostic. It can accept OpenQASM 3.0 strings when submitting jobs to the quantum backend via REST API calls. As long as a programming language supports making REST API calls, which most languages do, and the associated quantum framework supports the generation of OpenQASM 3.0 strings from quantum circuits, quantum jobs can be successfully submitted to IBM Quantum backends and results can be retrieved in a language-agnostic manner.
## OpenQASM 3.0
OpenQASM is an imperative programming language designed for near-term quantum computing algorithms and applications. Quantum programs are described using the measurement-based quantum circuit model with support for classical feedforward flow control based on measurement outcomes. It forms a bridge between several quantum programming languages giving us a universal set of instructions that can run on quantum near-term hardware.

In order to create a circuit and generate the corresponding QASM string, [MATLAB Quantum computing toolbox](https://www.mathworks.com/products/quantum-computing.html) was used. This toolbox lets the user to build, simulate, and run quantum algorithms. With MATLAB Quantum Support Package, the user can:
- Build circuits to implement quantum algorithms using a variety of built-in and customizable composite gates
- Verify implementation of algorithms using simulations in your local computer or connect to a remote simulator through cloud services
- Execute Variational Quantum Algorithms (VQAs) with the help of variational quantum circuits.
## Quick start
1. Install MATLAB 2023a. [Link](https://www.mathworks.com/help/install/)
2. Install Quantum Computing Toolbox. [Link](https://www.mathworks.com/products/quantum-computing.html)
3. Clone this repo into your local machine. [How to clone a repository from MATLAB?](https://www.mathworks.com/help/simulink/ug/clone-git-repository.html)
4. Run ```startup.m``` to ensure that all files in the repository are added to the MATLAB path.
5. Input your IBM Quantum API token into the Examples/tests. i.e. ```apiToken= 'put your IBM quantum API token'```
6. Run the Examples/tests!

## Test the defined classes

To run all tests and evaluate all the classes for sampler and estimator, from MATLAB execute the following command.

```
For IBM Quantum Platform:
result = Test_Sampler_Estimator ('ibm_quantum','MY_IBM_QUANTUM_TOKEN', [])


For IBM Quantum Cloud:
result = Test_Sampler_Estimator ('ibm_cloud','MY_IBM_CLOUD_API_KEY','MY_IBM_CLOUD_CRN' )

```
output:
```
 1×6 TestResult array with properties:

    Name
    Passed
    Failed
    Incomplete
    Duration
    Details

Totals:
   6 Passed, 0 Failed, 0 Incomplete.
   26.9564 seconds testing time.

```
If you want to test the classes separately follow [this](/test/README.MD)!

##  Creating Your First Quantum Program in MATLAB and submit it to IBM Quantum simulator

```
%% Setup credentials

% IBM cloud example
% channel = "ibm_cloud";
% apiToken = 'MY_IBM_CLOUD_API_KEY';
% crn_service = 'MY_IBM_CLOUD_CRN';
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

```

In this part we specify the required information that is needed to be set before communicating to the IBM Quantum systems/simulators. 

```
circuit = quantumCircuit([hGate(1) cxGate(1,2)]);
plot (circuit);
```
By plotting the circuit, the generated circuit using quantum computing toolbox will be presented with the defined gates, i.e.,

<p align="center">
  <img width="600" height="400" src="docs/images/BellState.jpg">
</p>

Now in order to simulate the circuit using the MATLAB state vector simulator, the following line should be executed through the command window:
```
Results = simulate(circuit);
```
The output would be the following:
```
Results.BasisStates=
00
01
10
11

Results.Amplitudes=
0.707106781186548
0
0
0.707106781186548

Results.NumQubits = 2
```
```
histogram(Results)
```

<p align="center">
  <img width="800" height="600" src="docs/images/Results_BellState.jpg">
</p>

This simple example makes an entangled state, also called a [Bell state](https://en.wikipedia.org/wiki/Bell_state).


Once you've made your first quantum circuit using MATLAB Quantum computing toolbox and simulate it using the internal state vector simulator, you can then set the options information (such as error mitigation methods,number of shots, observables, etc.) for the sampler and estimator primitives. The following line shows how to call options and set the required information. The third argument would be an structure including the Pauli strings and the corresponding coefficients. For more information you can check the `MaxcutEstimator.m`. After calling the SetOption function, a Qasm string will be generated that will be used to submit the job.

```
%% Enable the session and Sampler
session = Session(service, backend);  
sampler = Sampler(session=session);
job1 = sampler.run(circuit);

%% Retrieve the results back
Results = sampler.Results(job1.id);
Results

```

## License
[Apache License 2.0](LICENSE)

