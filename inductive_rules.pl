:- module(inductive_rules, [
    inductive_triage/3
]).
:- set_prolog_flag(encoding, utf8).

% inductive_triage(+CaseType, +Symptoms, -Decision)

% Regra 1
inductive_triage('intoxicacoes', Symptoms, 'Autocuidado e Vigilância') :-
    member(assintomatico_substancia_segura, Symptoms).

% Regra 2
inductive_triage('intoxicacoes', Symptoms, 'Contacto imediato CIAV / Urgência Hospitalar') :-
    member(risco_autoagressao, Symptoms).

% Regra 3
inductive_triage('intoxicacoes', Symptoms, 'Acionar INEM/112') :-
    member(respiracao_inadequada, Symptoms).

% Regra 4
inductive_triage('intoxicacoes', Symptoms, 'Avaliação Médica / CIAV') :-
    member(dor_intensa, Symptoms),
    \+ member(sintomas_neurologicos_agudos, Symptoms),
    \+ member(substancia_corrosiva, Symptoms),
    \+ member(obstrucao_vias_aereas, Symptoms).

% Regra 5
inductive_triage('intoxicacoes', Symptoms, 'Contacto imediato CIAV / Urgência Hospitalar') :-
    member(sintomas_neurologicos_agudos, Symptoms).

% Regra 6
inductive_triage('intoxicacoes', Symptoms, 'Acionar INEM/112') :-
    member(convulsoes, Symptoms).

% Regra 7
inductive_triage('intoxicacoes', Symptoms, 'Autocuidado e Vigilância') :-
    member(dor_moderada, Symptoms),
    \+ member(vomitos_persistentes, Symptoms).

% Regra 8
inductive_triage('intoxicacoes', Symptoms, 'Avaliação Médica / CIAV') :-
    member(vomitos_persistentes, Symptoms),
    \+ member(substancia_corrosiva, Symptoms).

% Regra 9
inductive_triage('intoxicacoes', Symptoms, 'Contacto imediato CIAV / Urgência Hospitalar') :-
    member(substancia_corrosiva, Symptoms).

% Regra ELSE (fallback)
inductive_triage('intoxicacoes', Symptoms, 'Acionar INEM/112') :-
    \+ member(assintomatico_substancia_segura, Symptoms),
    \+ member(risco_autoagressao, Symptoms),
    \+ member(respiracao_inadequada, Symptoms),
    \+ member(dor_intensa, Symptoms),
    \+ member(sintomas_neurologicos_agudos, Symptoms),
    \+ member(convulsoes, Symptoms),
    \+ member(dor_moderada, Symptoms),
    \+ member(vomitos_persistentes, Symptoms),
    \+ member(substancia_corrosiva, Symptoms).
