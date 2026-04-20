% ===================================================================
% FICHEIRO: inductive_rules.pl
% TEMA: Intoxicacoes e Envenenamentos (SNS24)
% OBJETIVO: Parte B - Regras extraídas por Machine Learning (Árvore de Decisão)
% ===================================================================

:- module(inductive_rules, [inductive_triage/2, important_symptoms/1]).

% -------------------------------------------------------------------
% 1. MOTOR DE TRIAGEM INDUTIVA
% -------------------------------------------------------------------
% inductive_triage(+Sintomas, -Cor)
inductive_triage(Symptoms, Color) :-
    find_color(Symptoms, Color),
    !.  % Cut (!) garante que assim que encontra a cor certa, pára de procurar.

% Caso de Defeito (Fallback): Se a árvore de decisão não encontrar nenhum 
% padrão perigoso nos sintomas, assume a cor mais segura (Verde).
inductive_triage(_, green).  

% -------------------------------------------------------------------
% 2. REGRAS DA ÁRVORE DE DECISÃO (Geradas por Algoritmo)
% Em Prolog, os ramos da árvore representam-se com member (Tem sintoma) 
% e \+ member (Não tem sintoma).
% -------------------------------------------------------------------

% Regras para VERMELHO (Emergência)
find_color(Symptoms, red) :-
    % Ramo 1: Se tem alteração de consciência, é logo vermelho.
    member(alteracao_consciencia, Symptoms) ;
    % Ramo 2: Não tem alteração, mas tem convulsões.
    (\+ member(alteracao_consciencia, Symptoms),
     member(convulsoes, Symptoms)).

% Regras para LARANJA (Muito Urgente)
find_color(Symptoms, orange) :-
    % Ramo 3: Toxidrome clássico (ex: drogas estimulantes)
    (\+ member(alteracao_consciencia, Symptoms),
     \+ member(convulsoes, Symptoms),
     member(pupilas_dilatadas, Symptoms),
     member(dor_abdominal_intensa, Symptoms)) ;
    % Ramo 4: Vómitos severos com sinais neurológicos oculares
    (\+ member(alteracao_consciencia, Symptoms),
     \+ member(convulsoes, Symptoms),
     member(vomitos, Symptoms),
     member(pupilas_dilatadas, Symptoms)).

% Regras para AMARELO (Urgente)
find_color(Symptoms, yellow) :-
    % Ramo 5: Vómitos isolados (sem sinais neurológicos)
    (\+ member(alteracao_consciencia, Symptoms),
     \+ member(convulsoes, Symptoms),
     \+ member(pupilas_dilatadas, Symptoms),
     member(vomitos, Symptoms)) ;
    % Ramo 6: Sudorese fria com pupilas dilatadas (mas sem dor/vómitos)
    (\+ member(alteracao_consciencia, Symptoms),
     \+ member(convulsoes, Symptoms),
     member(pupilas_dilatadas, Symptoms),
     \+ member(dor_abdominal_intensa, Symptoms),
     \+ member(vomitos, Symptoms),
     member(sudorese_fria, Symptoms)).

% Regras para VERDE (Pouco Urgente / Autocuidado)
find_color(Symptoms, green) :-
    % Ramo 7: Assintomático
    member(assintomatico, Symptoms) ;
    % Ramo 8: Apenas suores frios por ansiedade, sem mais nada
    (\+ member(alteracao_consciencia, Symptoms),
     \+ member(convulsoes, Symptoms),
     \+ member(vomitos, Symptoms),
     \+ member(pupilas_dilatadas, Symptoms),
     member(sudorese_fria, Symptoms)).

% -------------------------------------------------------------------
% 3. ATRIBUTOS MAIS IMPORTANTES (Feature Importance)
% Esta é a lista de sintomas que o modelo de ML considerou relevantes 
% para construir a árvore acima.
% -------------------------------------------------------------------
important_symptoms([
    alteracao_consciencia,
    convulsoes,
    pupilas_dilatadas,
    dor_abdominal_intensa,
    vomitos,
    sudorese_fria,
    assintomatico
]).