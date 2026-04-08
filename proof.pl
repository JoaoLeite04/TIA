% Proof: Motor de Inferência (Backward Chaining) com Explicação

% 1. Definição de Operadores

:- op( 800, fx, if).
:- op( 700, xfx, then).
:- op( 300, xfy, or).
:- op( 500, xfy, and).
:- op( 800, xfx, <=). 

% 2. MOTOR DE EXPLICAÇÃO (Criação da Árvore de Prova)

% CASO BASE: Se P já é um facto conhecido (na base de dados), 
% a prova de P é simplesmente P. Não precisamos de procurar mais.
result( P, P)  :-
   fact( P).

% PASSO RECURSIVO: Como provar uma conclusão (P) através de regras?
% A prova de P é (P <= CondProof) SE existir uma regra 'if Cond then P'
% e conseguirmos provar a condição (CondProof).
result( P, P <= CondProof)  :-
   if Cond then P,
   result( Cond, CondProof).

% LIDAR COM 'AND': Para provar duas coisas juntas, 
% provamos a primeira E provamos a segunda.
result( P1 and P2, Proof1 and Proof2)  :-
   result( P1, Proof1),
   result( P2, Proof2).

% LIDAR COM 'OR': Tenta provar a primeira; se falhar (;), tenta a segunda.
result( P1 or P2, Proof)  :-
   result( P1, Proof);
   result( P2, Proof).

% Imprimir quando é uma dedução
imprimir_prova( Conclusao <= Condicoes ) :-
    nl, write('>>> DECISAO: '), write(Conclusao), nl,
    write('>>> JUSTIFICACAO: Porque verificamos que...'), nl,
    imprimir_prova(Condicoes).

% Imprimir quando há múltiplas condições ligadas por "E"
imprimir_prova( Cond1 and Cond2 ) :-
    imprimir_prova(Cond1),
    imprimir_prova(Cond2).

% Imprimir os factos base
imprimir_prova( Facto ) :-
    Facto \= (_ <= _),
    Facto \= (_ and _),
    write('    - '), write(Facto), nl.