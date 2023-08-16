% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


function circuit = Twolocal(circuitinfo,parameters)
    Gates = [];
    for i =1:circuitinfo.reps
        if circuitinfo.entanglement=="linear"
    gates = [
             ryGate([1:circuitinfo.number_qubits], parameters((i-1)*circuitinfo.number_qubits+1:i*circuitinfo.number_qubits))
             cxGate(1:circuitinfo.number_qubits-1, 2:circuitinfo.number_qubits)
            ];
    Gates = [Gates,gates'];
        end
    end
    final_rot = [ryGate([1:circuitinfo.number_qubits], parameters(circuitinfo.reps*circuitinfo.number_qubits+1:(circuitinfo.reps+1)*circuitinfo.number_qubits))]';
    Gates  = [Gates, final_rot];
    circuit = quantumCircuit(Gates);
end