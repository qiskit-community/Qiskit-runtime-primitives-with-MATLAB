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
       constant
   end
   methods (Static)

       function obj = QuadraticProgram(Linear,Quadratic, constant)
            obj.Linear = Linear;
            obj.Quadratic = Quadratic;
            obj.constant = constant;
       end

 %%     
      function [Pauli_terms,Pauli_Coeff, Offset_value] = To_ising (Linear, Quadratic,constant)
    
        %%% Step1:
        %%% Add the linear part to the diagonal elements of Quadratic
        %%% matrix since x^2=x for binary variables
        Q = Quadratic;
        for i=1:length(Linear)
            Q(i,i) = Linear(i)+Quadratic(i,i);
        end
        %%% N would be the number of qubits
        N =size(Q,1);
        %%% Step2:
        %%% Create III..I Pauli term to start and replace I with Z operator
        %%% if the (i,j) element inside Quadratix matrix is nonzero
        II_string = repmat('I', [1, N]);
        for i=1:N
            I_index = II_string;
            I_index((N+1)-i)='Z';
            for j=1:N
                J_index = I_index;
                J_index((N+1)-j) = 'Z';
                %%% The coefficient of diagonal element would be -1/2 *
                %%% weight of quadratic matrix otherwise would be 1/4 * weight
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
        %%% Step3:
        %%% Calculate Wii coefficient using the weights of (i,j) index. 
        for i=1:N
            Wij = 0;
            for j=1:N
                if i~=j && Q(i,j)~=0
                    Wij = Wij - 1/2* Q(i,j);
                end
            end
            Wii(i) = Wij;
        end
        
        %%% Step4:
        %%% Adding all the coefficients of the lower triangle to find the final
        %%% coefficient of Wij (if the coefficients are nonzero)
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
        %%% returned parameters
        constant2 = sum(sum(cons_ij));
        Pauli = [Pauli, II_string];
        coeff = [coeff, constant2+constant];
        Offset_value  = constant2+constant;
        Pauli_terms   = string(Pauli);
        Pauli_Coeff   = string(coeff);
    
    end

   end

end