% ===================================================================
% FICHEIRO: main.pl
% TEMA: Intoxicacoes e Envenenamentos (SNS24)
% OBJETIVO: Ficheiro Principal (Orquestrador / Ponto de Entrada)
% ===================================================================

% 1. Carrega todos os módulos do sistema
:- use_module(knowledge).
:- use_module(triage).
:- use_module(interface).

:- set_prolog_flag(encoding, utf8).

% 2. Cria um comando amigável para arrancar manualmente (se necessário)
iniciar :-
    interface:start_consultation.

% 3. Função de arranque automático
arranque_automatico :-
    nl,
    writeln('======================================================='),
    writeln(' SISTEMA DE TRIAGEM SNS24 CARREGADO COM SUCESSO        '),
    writeln(' Tema: Intoxicacoes e Envenenamentos                   '),
    writeln('======================================================='),
    writeln(' -> Servidor Web/API ativo na porta 8080               '),
    writeln(' -> A abrir a interface de terminal...                 '),
    writeln('======================================================='),
    nl,
    iniciar.

% 4. Diz ao SWI-Prolog para executar o arranque assim que o ficheiro for lido
:- initialization(arranque_automatico).