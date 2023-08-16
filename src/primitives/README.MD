## What are Qiskit Primitives?
In computing, a primitive is the smallest processing instruction for a given abstraction level. Put simply, you can think of primitives as the simplest building blocks you can give to a user to create something useful. From the user’s perspective, they are black boxes that “do something I need but I don’t care about the specific details of how.” They abstract away implementation details.

## What is Sampler primitive?
A Sampler Primitive calculates probabilities or quasi-probabilities of bitstrings from quantum circuits. Quasi-probabilities are similar to regular probabilities except they may include negative values, which can occur when using certain error mitigation techniques.

## What is Estimator primititve?
An Estimator Primitive computes expectation values of observables with respect to states prepared by quantum circuits. Users generally specify a list of circuits, observables, and possibly some additional configuration, with which the program can efficiently evaluate expectation values and variances.

Primitives in general allow a high-level user to write quantum algorithms without worrying about hardware details. So non-trivial tasks, like operator estimation for example, can be handled on a lower level without the need for user input.


## How to Use MATLAB-Qiskit Primitives
In order to initiate and submit a job to the qiskit runtime primititves through MATLAB, the ```Sampler.m``` adn ```Estimator.m``` are used. These classes will submit a job through the REST API using the IBM quantum token
and retreive the results using the submitted job id.Let’s look at some examples of how to use them:

## Sampler Example:
```
hubinfo = {};
hubinfo.hub = "ibm-q";
hubinfo.group = "open";
hubinfo.project = "main";
hubinfo.program_id = "sampler";
hubinfo.Access_API = runtime_apiToken.id;
hubinfo.backend = "ibmq_qasm_simulator";
hubinfo.Start_session = [];
hubinfo.session_id = [];
% Build some circuits
circuit = quantumCircuit([hGate(1) cxGate(1,2)]);
params = Options.SetOptions(circuit,hubinfo, []);

job = Sampler.run(params,hubinfo);

%%%% Retrieve the results back
Results = Sampler.Results(job.id,hubinfo.Access_API);

```
output: The output file would include two structures that include the '''quasi_dists''' and '''metadata'''
```
Results.quasidists=
field  value 
0x00   0.53
0x11   0.47

```
The first column (field) is the bitstring and the second (value) would be the corresponding probabilities!
## Estimator Example:

```
% Build some circuits

hubinfo = {};
hubinfo.hub = "ibm-q";
hubinfo.group = "open";
hubinfo.project = "main";
hubinfo.program_id = "estimator";
hubinfo.Access_API = runtime_apiToken.id;
hubinfo.backend = "ibmq_qasm_simulator";
hubinfo.Start_session = [];
hubinfo.session_id = [];

circuit = quantumCircuit([hGate(1) cxGate(1,2)]);
observables.Pauli_Term = ["II","IZ","ZI","ZZ","XX"];
observables.Coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);
params = Options.SetOptions(circuit,hubinfo, observables);

jobinfo = Estimator.run (params,hubinfo )

Results = Estimator.Results(jobinfo.id,hubinfo.Access_API);

```

Output: The output would be an structure with two information that include values (expectation value) and metadata (an structure): 
```
values = -0.8827
```

