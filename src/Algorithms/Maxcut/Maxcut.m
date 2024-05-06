% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Maxcut < handle
   properties(Access=private)
       cost_func,
       optimizer,
       arguments,
   end

   methods (Static)
   
       function [angles,minEnergy] = Maxcut(cost_func,optimizer,arguments)

       end

    %%
    function [Pauli_terms, Pauli_Coeff, Offset_value, Offset_string] = ToIsing(G)
        W = full(adjacency(G,'weighted'));
        N =numnodes(G);
        II_string = repmat('I', [1, N]);
        %%% Create the objective function
        for i=1:N
            I_index = II_string;
            I_index((N+1)-i)='Z';
            for j=1:N
                J_index = I_index;
                J_index((N+1)-j) = 'Z';
                Coeff_ij(i,j) = 1/2*W(i,j);
                T{i,j} = J_index;
                cons_ij(i,j) = -W(i,j)/4;
                
            end
            K{i} = W(i,i)*I_index;
            cons_i(i) = W(i,i)/2;
            
        end 
        
        k=1;
        for i=1:N
            for j=1:i
                if (Coeff_ij(i,j)~=0)
                    coeff(k) = Coeff_ij(i,j);
                    Pauli{k} = T{i,j};
                    k = k+1;
                end
            end
        
        end
        
        constant = sum(sum(cons_ij)) + sum(cons_i);
        Pauli = [Pauli, II_string];
        coeff = [coeff, constant];
        Offset_value  = constant;
        Offset_string = II_string;
        Pauli_terms   = string(Pauli);
        Pauli_Coeff   = double(coeff);
    end
%%
function plot_results(G,bitstring_data,probability,color)
        figure;
        bar(categorical(bitstring_data),probability,color)
        xlabel('Bitstrings')
        ylabel('Probabilities')
        title('Returned distribution from Qiskit Runtime Sampler primitive')
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',10,'FontWeight','bold')
        set(gca,'XTickLabelMode','auto')
        b = get(gca,'YTickLabel');
        set(gca,'YTickLabel',b,'fontsize',10,'FontWeight','bold')
        set(gca,'YTickLabelMode','auto')
        set(gca, 'LineWidth', 2.5)
        %%%% Color the graph based on the qiskit results
     %%%%extract the Bitstring with the highest probability
        Bit_max = bitstring_data(find(probability==max(probability)));
        Bit_max = cell2mat(Bit_max(1));
        
        Bit_max = dec2bin(hex2dec(Bit_max(1,:)),G.numnodes);
        % Reverse the order of qubits
        x_final = Bit_max(length(Bit_max):-1:1);

        index =[];
        for i=1:length(x_final)
            if str2double(x_final(i))==1
                index = [index i];
            end
        end
        

        if ~isempty(G)
            figure
            N = numnodes(G);
            h = plot(G);
            
            highlight(h,index,'NodeColor','g')
            highlight(h,1:N,'MarkerSize',20)
        end  
    end


end
end

