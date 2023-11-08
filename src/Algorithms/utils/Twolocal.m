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
        gates_rot = [];
        for j=1:length(circuitinfo.rotation_blocks)
            gate_str = circuitinfo.rotation_blocks(j)+'Gate';
            Gates_block = str2func(gate_str);
            gates_rot = [gates_rot, Gates_block([1:circuitinfo.number_qubits], parameters((j-1+2*(i-1))*circuitinfo.number_qubits+1:(j+2*(i-1))*circuitinfo.number_qubits))'];
        end
        if circuitinfo.entanglement=="linear"
            gates = [
                     cxGate(1:circuitinfo.number_qubits-1, 2:circuitinfo.number_qubits)
                    ];
        elseif circuitinfo.entanglement=="pairwise"
 
            gates = [
                     cxGate(1:2:circuitinfo.number_qubits-1, 2:2:circuitinfo.number_qubits)
                     cxGate(2:2:circuitinfo.number_qubits-1, 3:2:circuitinfo.number_qubits);
                    ];

        end
        Gates = [Gates,gates_rot,gates'];
    end

    final_rot = [];
    for j=1:length(circuitinfo.rotation_blocks)
        gate_str = circuitinfo.rotation_blocks(j)+'Gate';
        Gates_block = str2func(gate_str);
        final_rot = [final_rot, Gates_block([1:circuitinfo.number_qubits], parameters((j+2*i-1)*circuitinfo.number_qubits+1:(j+2*i)*circuitinfo.number_qubits))'];
    end
    
    Gates  = [Gates, final_rot];
    % Gates = [Gates xGate(5)' xGate(9)'];
    circuit = quantumCircuit(Gates);
end