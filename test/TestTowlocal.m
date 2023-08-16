% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef TestTowlocal < matlab.unittest.TestCase
    
    properties (ClassSetupParameter)
       circuitinfo = struct('circuitinfo', 1) ,
       parameters = struct('parameters', 1) ,

    end
    
    methods (TestClassSetup)
        function testmockTwoLocal (~,circuitinfo,parameters)
            
        end
        
    
    end

    methods (Test)
        function testTwolocal (testCase,circuitinfo,parameters)

            circuit = Twolocal(circuitinfo,parameters);
            testCase.verifyNotEmpty(circuit);
        end

    end


end

