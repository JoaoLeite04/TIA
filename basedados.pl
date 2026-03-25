% ===================================================================
% FICHEIRO: base_dados.pl
% OBJETIVO: Declarar factos dinâmicos e armazenar o estado da triagem 
%           atual de Ortopedia.
% ===================================================================

% -------------------------------------------------------------------
% 1. DECLARAÇÃO DE PREDICADOS DINÂMICOS
% Permite o uso de asserta/1, assertz/1 e retract/1 no sistema.
% -------------------------------------------------------------------

% Identificação do Utente
:- dynamic utente_sns/1.           % Ex: utente_sns(123456789).
:- dynamic utente_nome/1.          % Ex: utente_nome('Joao Silva').

% Objetivo da interação
:- dynamic objetivo_utente/1.      % Ex: objetivo_utente(avaliar_sintomas). / objetivo_utente(consultas).

% Sinais de Alerta (Emergência - 112)
:- dynamic sinal_alerta/1.         % Ex: sinal_alerta(trauma_grave). / sinal_alerta(sangramento_ativo).

% Caracterização da Queixa Ortopédica
:- dynamic local_dor/1.            % Ex: local_dor(coluna). / local_dor(articulacao).
:- dynamic mobilidade_limitada/1.  % Ex: mobilidade_limitada(sim). / mobilidade_limitada(nao).
:- dynamic intensidade_dor/1.      % Ex: intensidade_dor(alta). / intensidade_dor(baixa).

% Processos Administrativos
:- dynamic tem_guia_p1/1.          % Ex: tem_guia_p1(sim). / tem_guia_p1(nao).

% Disposição Final (Resultado da triagem)
:- dynamic disposicao_final/1.     % Ex: disposicao_final(emergencia_112).


% -------------------------------------------------------------------
% 2. PREDICADOS DE GESTÃO DA BASE DE DADOS
% -------------------------------------------------------------------

% limpar_dados/0
% Limpa todos os factos da memória para garantir que uma nova triagem 
% não usa dados do utente anterior.
limpar_dados :-
    retractall(utente_sns(_)),
    retractall(utente_nome(_)),
    retractall(objetivo_utente(_)),
    retractall(sinal_alerta(_)),
    retractall(local_dor(_)),
    retractall(mobilidade_limitada(_)),
    retractall(intensidade_dor(_)),
    retractall(tem_guia_p1(_)),
    retractall(disposicao_final(_)).

% estado_atual/0
% Predicado auxiliar útil para vocês testarem o código. 
% Imprime no ecrã tudo o que está guardado na memória no momento.
estado_atual :-
    write('--- ESTADO ATUAL DA BASE DE DADOS ---'), nl,
    listing(utente_sns/1),
    listing(sinal_alerta/1),
    listing(objetivo_utente/1),
    listing(local_dor/1),
    listing(tem_guia_p1/1),
    listing(disposicao_final/1),
    write('-------------------------------------'), nl.
    