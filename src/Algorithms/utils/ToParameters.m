% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


function qasm = ToParameters(circuit,parameters)
    qasm= generateQASM(circuit);
    v=['[' sprintf('t%d,',1:length(parameters))];
    v(end)=']';
    t=str2sym(v);
    for i=1:length(parameters)
        qasm = replace( qasm , int2str(-(1000)*i) , string(t(i)) );
        qasm = insertAfter(qasm,'"stdgates.inc";',"input float[64] t"+int2str(length(parameters)-i+1)+";");  
    end
        
end