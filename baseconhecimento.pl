% ===================================================================
% FICHEIRO: base_conhecimento.pl
% OBJETIVO: Regras de produção (Se... Então...) para triagem de Ortopedia.
% ===================================================================

% Nota: O sistema vai tentar satisfazer estas regras de cima para baixo.
% Por isso, as regras mais graves (Emergência) devem vir primeiro.

% -------------------------------------------------------------------
% 1. CAMINHO DE URGÊNCIA (Sinais de Alerta - Prioridade Máxima)
% -------------------------------------------------------------------
% SE o utente tem trauma grave OU sangramento ativo, ENTÃO é Emergência.

avaliar_disposicao(emergencia_112) :-
    sinal_alerta(trauma_grave).

avaliar_disposicao(emergencia_112) :-
    sinal_alerta(sangramento_ativo).


% -------------------------------------------------------------------
% 2. CAMINHO ADMINISTRATIVO (Consultas e Exames)
% -------------------------------------------------------------------
% SE o objetivo é marcar consulta E tem guia P1, ENTÃO avança para agendamento.

avaliar_disposicao(validar_codigo_e_agendar) :-
    objetivo_utente(consultas),
    tem_guia_p1(sim).

% SE o objetivo é marcar consulta E NÃO tem guia P1, ENTÃO informar processo.

avaliar_disposicao(informar_obtencao_referenciacao) :-
    objetivo_utente(consultas),
    tem_guia_p1(nao).


% -------------------------------------------------------------------
% 3. CAMINHO DE TRIAGEM CLÍNICA (Avaliar Sintomas de Dor/Mobilidade)
% -------------------------------------------------------------------
% SE quer avaliar sintomas E tem dor de alta intensidade E tem mobilidade limitada
% ENTÃO encaminhar para consulta de especialidade.

avaliar_disposicao(encaminhar_consulta_especialidade) :-
    objetivo_utente(avaliar_sintomas),
    intensidade_dor(alta),
    mobilidade_limitada(sim).

% SE quer avaliar sintomas, tem dor baixa E não tem limite de mobilidade
% ENTÃO fornecer guia de autocuidado e exercícios.

avaliar_disposicao(guia_autocuidado) :-
    objetivo_utente(avaliar_sintomas),
    intensidade_dor(baixa),
    mobilidade_limitada(nao).

% Regra de segurança (Catch-all): Se os sintomas não encaixam nem num caso 
% nem noutro (ex: dor alta mas com mobilidade normal), sugerimos ligar SNS24.
avaliar_disposicao(ligar_sns24_apoio_medico) :-
    objetivo_utente(avaliar_sintomas).