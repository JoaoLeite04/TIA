:- dynamic(fact/1).
:- dynamic(utente_nome/1).

% Carrega os outros ficheiros (ajusta os nomes se necessário)
:- [forward, basedados, proof, baseconhecimento].

% -------------------------------------------------------------------
% 1. MENU PRINCIPAL
% -------------------------------------------------------------------

menu :- 
    nl, nl,
    write('*************************************************************************'), nl,
    write('** **'), nl,
    write('** SISTEMA DE TRIAGEM SNS24                       **'), nl,
    write('** Intoxicacoes e Envenenamentos                     **'), nl,
    write('** **'), nl,
    write('*************************************************************************'), nl,
    write('  Bem-vindo. Para iniciar o atendimento, qual o seu primeiro nome?'), nl,
    write('  (Nota: escreva o nome com letra minuscula e termine com um ponto. Ex: joao.)'), nl,
    read(Nome), nl,
    assert(utente_nome(Nome)), 
    write('*************************************************************************'), nl,
    write('  Prazer em ajuda-lo/a, '), write(Nome), write('.'), nl,
    write('  O algoritmo de triagem ira fazer-lhe algumas perguntas cruciais.'), nl,
    write('*************************************************************************'), nl,
    write('** Menu de Opcoes:'), nl,
    write('** 1 - Iniciar Triagem'), nl,
    write('** 2 - Sair do Sistema'), nl, nl,
    write('  Introduza a opcao (seguida de ponto): '),
    read(Opcao),
    avaliarEscolha(Opcao).

avaliarEscolha(1) :- questao_abc.
avaliarEscolha(2) :- write('O SNS24 agradece o seu contacto. As melhoras!'), halt.
avaliarEscolha(_) :- write('Opcao invalida. Tente novamente.'), nl, menu.

% -------------------------------------------------------------------
% 2. QUESTIONÁRIO DE TRIAGEM
% -------------------------------------------------------------------

% Pergunta 1: Avaliação de Risco de Vida (ABC)
questao_abc :-  
    write('*************************************************************************'), nl,
    write('** PRE-TRIAGEM (SINAIS DE ALERTA)'), nl,
    write('** O utente esta INCONSCIENTE ou tem DIFICULDADE RESPIRATORIA GRAVE?'), nl,
    write('** 1 - Sim'), nl,
    write('** 2 - Nao'), nl, nl,
    read(R1),
    (
        (R1 == 1), assert(fact(compromisso_abc(sim))), resultado; % Curto-circuito para o fim!
        (R1 == 2), assert(fact(compromisso_abc(nao))), questao_neuro
    ).

% Pergunta 2: Avaliação Neurológica
questao_neuro :-  
    write('*************************************************************************'), nl,
    write('** O utente apresenta CONVULSOES ou LETARGIA?'), nl,
    write('** 1 - Sim'), nl,
    write('** 2 - Nao'), nl, nl,
    read(R2),
    (
        (R2 == 1), assert(fact(sintomas_neurologicos(sim))), resultado; % Curto-circuito!
        (R2 == 2), assert(fact(sintomas_neurologicos(nao))), questao_via
    ).

% Pergunta 3: Via de Exposição
questao_via :-  
    write('*************************************************************************'), nl,
    write('** Como ocorreu a exposicao ao agente toxico?'), nl,
    write('** 1 - Ingestao (Engoliu a substancia)'), nl,
    write('** 2 - Inalacao (Respirou gas/fumo)'), nl,
    write('** 3 - Contacto (Pele/Olhos)'), nl, nl,
    read(R3),
    (
        (R3 == 1), assert(fact(via_exposicao(ingestao))), questao_substancia;
        (R3 == 2), assert(fact(via_exposicao(inalacao))), questao_substancia;
        (R3 == 3), assert(fact(via_exposicao(contacto))), questao_substancia
    ).

% Pergunta 4: Tipo de Substância
questao_substancia :-   
    write('*************************************************************************'), nl,
    write('** A substancia e CORROSIVA ou CAUSTICA? (Ex: lixivia, acido, detergente forte)'), nl,
    write('** 1 - Sim'), nl,
    write('** 2 - Nao / Nao tenho a certeza'), nl, nl,
    read(R4),
    (
        (R4 == 1), assert(fact(substancia_corrosiva(sim))), questao_dose;
        (R4 == 2), assert(fact(substancia_corrosiva(nao))), questao_dose
    ).

% Pergunta 5: Dose Estimada
questao_dose :-     
    write('*************************************************************************'), nl,
    write('** A quantidade envolvida/ingerida e considerada ALTA ou PERIGOSA?'), nl,
    write('** 1 - Sim (Quantidade elevada)'), nl,
    write('** 2 - Nao (Quantidade muito baixa ou inofensiva)'), nl, nl,
    read(R5), nl,
    (
        (R5 == 1), assert(fact(dose_toxica(alta))), resultado;
        (R5 == 2), assert(fact(dose_toxica(baixa))), resultado
    ).
            
% -------------------------------------------------------------------
% 3. MOTOR DE INFERÊNCIA E LIMPEZA
% -------------------------------------------------------------------

resultado :-    
    write('*************************************************************************'), nl,
    write('** PROCESSANDO TRIAGEM...                         **'), nl,           
    write('*************************************************************************'), nl, nl,
    result, 
    limpar_sessao.

% Limpa os factos depois da triagem acabar, para poder correr de novo limpo.
limpar_sessao :-
    retractall(fact(_)),
    retractall(utente_nome(_)),
    nl, write('Para fazer nova triagem, digite "menu."').