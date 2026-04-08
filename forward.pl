% Foward: Motor de Inferência (Forward Chaining) para Triagem SNS24

% 1. Definição de Operadores (Para escrever as regras em linguagem natural)
:- op( 800, fx, if).
:- op( 700, xfx, then).
:- op( 300, xfy, or).
:- op( 500, xfy, and).

% 2. Ciclo Principal de Inferência
result :- 
   new_derived_fact(P),             
   !,
   resultadowrite(P), nl,
   assert(fact(P)), 
   result. 
                           
% Condição de paragem: Quando já não consegue deduzir mais nada
result :- 
   nl, write('----------------------------------------------------'), nl,
   write('Triagem Concluída. Por favor, siga as indicações dadas.'), nl,
   write('----------------------------------------------------'), nl.          

% 3. Lógica para encontrar um NOVO facto
new_derived_fact(Concl) :-
   if Cond then Concl,           
   \+ fact(Concl),                
   composed_fact(Cond).             

% 4. Avaliação das Condições (Lida com ANDs, ORs e factos simples)
composed_fact(Cond) :-
   fact(Cond).                      

composed_fact(Cond1 and Cond2) :-
   composed_fact(Cond1),
   composed_fact(Cond2).            

composed_fact(Cond1 or Cond2) :-
   composed_fact(Cond1)
   ;
   composed_fact(Cond2).

% 5. Apresentação de Resultados (Específico para o SNS24)
% Se o facto deduzido for uma disposição final (ex: ir para o hospital)
resultadowrite(disposicao(D)) :-
   format('>>> ALERTA SNS24: A disposicao calculada e: ~w <<<', [D]).

% Para outros factos intermédios deduzidos ao longo do processo
resultadowrite(Fact) :-
   Fact \= disposicao(_), % Garante que não é uma disposição final
   format('INFO: Novo dado clinico deduzido -> ~w', [Fact]).