% BASE DE CONHECIMENTO – INTOXICAÇÕES


:- op(800, fx, if).
:- op(700, xfx, then).
:- op(300, xfy, or).
:- op(500, xfy, and).


% EMERGÊNCIA – Compromisso ABC
if alteracao_consciencia then emergencia.
if dificuldade_respiratoria then emergencia.
if hemorragia_abundante then emergencia.
if corrosiva then emergencia.
if convulsoes then emergencia.

% URGÊNCIA HOSPITALAR – Sintomas moderados
if nauseas then urgencia.
if vomitos then urgencia.
if irritacao_cutanea then urgencia.
if tonturas then urgencia.


% AUTOCUIDADO – Assintomático + baixa toxicidade
if baixa_toxicidade and assintomatico then autocuidado.


% Perfis finais 

perfil(emergencia, _) :-
    write('Encaminhamento: EMERGÊNCIA HOSPITALAR – Contactar 112 e CIAV.').

perfil(urgencia, _) :-
    write('Encaminhamento: URGÊNCIA HOSPITALAR – Consultar CIAV.').

perfil(autocuidado, _) :-
    write('Encaminhamento: AUTOCUIDADO – Observação domiciliária.').