% ===================================================================
% FICHEIRO: main.pl
% TEMA: Intoxicacoes e Envenenamentos (SNS24)
% OBJETIVO: Ficheiro Principal (Orquestrador / Ponto de Entrada)
% ===================================================================

:- set_prolog_flag(encoding, utf8).

% 1. Carrega todos os modulos do sistema
:- use_module(knowledge).
:- use_module(triage).
:- use_module(interface).

% 2. Cria um comando amigavel para arrancar manualmente (se necessario)
iniciar :-
    interface:start_consultation.

% 3. Funcao de arranque automatico
arranque_automatico :-
    catch(set_stream(user_output, encoding(utf8)), _, true),
    catch(set_stream(user_input, encoding(utf8)), _, true),
    catch(set_stream(user_error, encoding(utf8)), _, true),
    nl,
    writeln('======================================================='),
    writeln(' SISTEMA DE TRIAGEM SNS24 CARREGADO COM SUCESSO        '),
    atom_codes(Tema, [32,84,101,109,97,58,32,73,110,116,111,120,105,99,97,231,245,101,115,32,101,32,69,110,118,101,110,101,110,97,109,101,110,116,111,115]),
    format(' ~w                   ~n', [Tema]),
    writeln('======================================================='),
    writeln(' -> Servidor Web/API ativo na porta 8080               '),
    writeln(' -> A abrir a interface de terminal...                 '),
    writeln('======================================================='),
    nl,
    iniciar.

% 4. Diz ao SWI-Prolog para executar o arranque assim que o ficheiro for lido
:- initialization(arranque_automatico).