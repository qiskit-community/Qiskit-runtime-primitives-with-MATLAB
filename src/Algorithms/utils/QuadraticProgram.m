% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef QuadraticProgram < handle
   properties
       Linear,
       Quadratic,
   end
   methods (Static)

       function obj = QuadraticProgram(Linear,Quadratic)
            obj.Linear = Linear;
            obj.Quadratic = Quadratic;
       end

 %%     
      function [Pauli_terms,Pauli_Coeff, Offset_value] = To_ising (Linear, Quadratic)
    
        Q = Quadratic;
        for i=1:length(Linear)
            Q(i,i) = Linear(i)+Quadratic(i,i);
        end
        
        N =size(Q,1);
        II_string = repmat('I', [1, N]);
        %%% Calculate the Pauli terms and the corresponding Coefficients
        for i=1:N
            I_index = II_string;
            I_index((N+1)-i)='Z';
            for j=1:N
                J_index = I_index;
                J_index((N+1)-j) = 'Z';
                if i==j
                    Coeff_i(i,j) = -1/2*Q(i,j);
                    cons_ij(i,j) = Q(i,j)/2;
                else 
                    Coeff_ij(i,j) = 1/4*Q(i,j);
                    cons_ij(i,j) = Q(i,j)/4; 
                end
                T{i,j} = J_index;
                
            end
            
        end 
        
        for i=1:N
            Wij = 0;
            for j=1:N
                if i~=j && Q(i,j)~=0
                    Wij = Wij - 1/2* Q(i,j);
                end
            end
            Wii(i) = Wij;
        end
        
        k=1;
        for i=1:N
            for j=1:i
                if (Coeff_ij(i,j)~=0)
                    coeff(k) = 2*Coeff_ij(i,j);
                    Pauli{k} = T{i,j};
                    k = k+1;
                end
                if (i==j)
                    coeff(k) = Coeff_i(i,j)+Wii(i);
                    Pauli{k} = T{i,j};
                    k = k+1;
                end
        
            end
        
        end
        
        constant = sum(sum(cons_ij));
        Pauli = [Pauli, II_string];
        coeff = [coeff, constant];
        Offset_value  = constant;
        Pauli_terms   = string(Pauli);
        Pauli_Coeff   = string(coeff);
    
    end

   end

end