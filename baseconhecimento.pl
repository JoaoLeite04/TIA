% BASE DE CONHECIMENTO – INTOXICAÇÕES


:- op(800, fx, if).
:- op(700, xfx, then).
:- op(300, xfy, or).
:- op(500, xfy, and).


% EMERGÊNCIA – Compromisso ABC
if alteracao_consciencia then disposicao(emergencia).
if dificuldade_respiratoria then disposicao(emergencia).
if hemorragia_abundante then disposicao(emergencia).
if corrosiva then disposicao(emergencia).
if convulsoes then disposicao(emergencia).

% URGÊNCIA HOSPITALAR – Sintomas moderados
if nauseas then disposicao(urgencia).
if vomitos then disposicao(urgencia).
if irritacao_cutanea then disposicao(urgencia).
if tonturas then disposicao(urgencia).


% AUTOCUIDADO – Assintomático + baixa toxicidade
if baixa_toxicidade and assintomatico then disposicao(autocuidado).