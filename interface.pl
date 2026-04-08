% ===================================================================
% FICHEIRO: interface.pl
% TEMA: Intoxicacoes e Envenenamentos (SNS24)
% ===================================================================

:- dynamic(fact/1).
:- dynamic(utente_nome/1).

% Carrega os outros ficheiros
:- [forward, base_dados, proof, base_conhecimento].

% -------------------------------------------------------------------
% 1. MENU PRINCIPAL
% -------------------------------------------------------------------
menu :- 
    nl, nl,
    write('======================================================='), nl,
    write('               SISTEMA DE TRIAGEM SNS24                '), nl,
    write('            Intoxicacoes e Envenenamentos              '), nl,
    write('======================================================='), nl,
    write(' Bem-vindo. Para iniciar, qual o seu primeiro nome?'), nl,
    write(' (Escreva em minusculas e termine com ponto. Ex: joao.)'), nl,
    write(' > '),
    read(Nome), nl,
    assert(utente_nome(Nome)), 
    write('-------------------------------------------------------'), nl,
    write(' Prazer em ajudar, '), write(Nome), write('.'), nl,
    write(' O sistema ira fazer-lhe algumas perguntas cruciais.'), nl,
    write('-------------------------------------------------------'), nl,
    write(' Menu de Opcoes:'), nl,
    write(' 1 - Iniciar Triagem'), nl,
    write(' 2 - Sair do Sistema'), nl, nl,
    write(' Introduza a opcao (seguida de ponto): '),
    read(Opcao),
    avaliarEscolha(Opcao).

avaliarEscolha(1) :- questao_abc.
avaliarEscolha(2) :- write('O SNS24 agradece o seu contacto. As melhoras!'), halt.
avaliarEscolha(_) :- write('Opcao invalida. Tente novamente.'), nl, menu.

% -------------------------------------------------------------------
% 2. QUESTIONARIO DE TRIAGEM
% -------------------------------------------------------------------

% Pergunta 1: Avaliacao de Risco de Vida (ABC)
questao_abc :-  
    write('======================================================='), nl,
    write(' PRE-TRIAGEM (SINAIS DE ALERTA)'), nl,
    write(' O utente esta INCONSCIENTE ou tem FALTA DE AR GRAVE?'), nl,
    write(' 1 - Sim'), nl,
    write(' 2 - Nao'), nl, nl,
    write(' > '), read(R1),
    (
        (R1 == 1), assert(fact(alteracao_consciencia)), resultado; 
        (R1 == 2), questao_neuro
    ).

% Pergunta 2: Avaliacao Neurologica
questao_neuro :-  
    write('-------------------------------------------------------'), nl,
    write(' O utente apresenta CONVULSOES ou LETARGIA?'), nl,
    write(' 1 - Sim'), nl,
    write(' 2 - Nao'), nl, nl,
    write(' > '), read(R2),
    (
        (R2 == 1), assert(fact(convulsoes)), resultado; 
        (R2 == 2), questao_via
    ).

% Pergunta 3: Via de Exposicao
questao_via :-  
    write('-------------------------------------------------------'), nl,
    write(' Como ocorreu a exposicao ao agente toxico?'), nl,
    write(' 1 - Ingestao (Engoliu a substancia)'), nl,
    write(' 2 - Inalacao (Respirou gas/fumo)'), nl,
    write(' 3 - Contacto (Pele/Olhos)'), nl, nl,
    write(' > '), read(R3),
    (
        (R3 == 1), assert(fact(ingestao)), questao_substancia;
        (R3 == 2), assert(fact(inalacao)), questao_substancia;
        (R3 == 3), assert(fact(contacto)), questao_substancia
    ).

% Pergunta 4: Tipo de Substancia
questao_substancia :-   
    write('-------------------------------------------------------'), nl,
    write(' A substancia e CORROSIVA? (Ex: lixivia, acido)'), nl,
    write(' 1 - Sim'), nl,
    write(' 2 - Nao / Nao tenho a certeza / Baixa toxicidade'), nl, nl,
    write(' > '), read(R4),
    (
        (R4 == 1), assert(fact(corrosiva)), questao_sintomas;
        (R4 == 2), assert(fact(baixa_toxicidade)), questao_sintomas
    ).

% Pergunta 5: Sintomas Moderados
questao_sintomas :-     
    write('-------------------------------------------------------'), nl,
    write(' O utente apresenta sintomas moderados?'), nl,
    write(' 1 - Sim (Nauseas, Vomitos, Tonturas)'), nl,
    write(' 2 - Nao (Esta assintomatico)'), nl, nl,
    write(' > '), read(R5), nl,
    (
        (R5 == 1), assert(fact(nauseas)), resultado;
        (R5 == 2), assert(fact(assintomatico)), resultado
    ).
            
% -------------------------------------------------------------------
% 3. MOTOR DE INFERENCIA E LIMPEZA
% -------------------------------------------------------------------
resultado :-    
    write('======================================================='), nl,
    write(' PROCESSANDO TRIAGEM...                                '), nl,           
    write('======================================================='), nl, nl,
    result, 
    limpar_sessao.

% Limpa os factos depois da triagem acabar
limpar_sessao :-
    retractall(fact(_)),
    retractall(utente_nome(_)),
    nl, write('Para fazer nova triagem, digite "menu."').