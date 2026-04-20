:- module(knowledge, [
    triage_rule/4, 
    rule_explanation/3,
    symptom_question/2, 
    all_symptoms/2, 
    case_types/1, 
    case_type_question/2
]).

% -------------------------------------------------------------------
% 1. TIPO DE CASO
% Mantemos esta estrutura caso o professor queira testar a modularidade
% -------------------------------------------------------------------
case_type_question('Intoxicações e Envenenamentos', 'O motivo do contacto está relacionado com a ingestão, inalação ou contacto com substâncias tóxicas, medicamentos ou drogas?').

case_types(Types) :-
    findall(Type, case_type_question(Type, _), Types).

% -------------------------------------------------------------------
% 2. LISTA DE SINTOMAS POR GRAVIDADE (Algoritmo SNS24)
% -------------------------------------------------------------------
all_symptoms('Intoxicações e Envenenamentos', [
    obstrucao_vias_aereas,          % EMERGÊNCIA (Vermelho)
    respiracao_inadequada,          % EMERGÊNCIA (Vermelho)
    convulsoes,                     % EMERGÊNCIA (Vermelho)
    inconsciencia,                  % EMERGÊNCIA (Vermelho)
    substancia_corrosiva,           % MUITO URGENTE (Laranja / CIAV)
    sintomas_neurologicos_agudos,   % MUITO URGENTE (Laranja)
    dor_intensa,                    % MUITO URGENTE (Laranja)
    risco_autoagressao,             % URGENTE (Amarelo)
    vomitos_persistentes,           % URGENTE (Amarelo)
    dor_moderada,                   % URGENTE (Amarelo)
    assintomatico_substancia_segura % AUTOCUIDADO (Verde/Azul)
]).

% -------------------------------------------------------------------
% 3. PERGUNTAS DE TRIAGEM (Discriminadores do Enfermeiro)
% -------------------------------------------------------------------
symptom_question(obstrucao_vias_aereas, 'Existe bloqueio na passagem de ar ou a pessoa engasgou-se gravemente? (y/n)').
symptom_question(respiracao_inadequada, 'A pessoa apresenta dificuldade respiratória grave, respiração muito lenta ou paragem? (y/n)').
symptom_question(convulsoes, 'A pessoa está a ter ou teve convulsões (tremores incontroláveis do corpo)? (y/n)').
symptom_question(inconsciencia, 'A pessoa está inconsciente, não acorda ou não reage a estímulos? (y/n)').
symptom_question(substancia_corrosiva, 'A substância envolvida é corrosiva ou cáustica (ex: lixívia, ácidos, detergentes fortes)? (y/n)').
symptom_question(sintomas_neurologicos_agudos, 'A pessoa apresenta confusão mental súbita, letargia extrema ou alucinações? (y/n)').
symptom_question(dor_intensa, 'A pessoa queixa-se de uma dor súbita e insuportável no peito ou abdómen? (y/n)').
symptom_question(risco_autoagressao, 'Há suspeita de que a ingestão foi intencional (tentativa de suicídio)? (y/n)').
symptom_question(vomitos_persistentes, 'A pessoa está com vómitos contínuos e não consegue reter líquidos? (y/n)').
symptom_question(dor_moderada, 'A pessoa queixa-se de dor abdominal ou náuseas moderadas? (y/n)').
symptom_question(assintomatico_substancia_segura, 'A pessoa sente-se bem e a substância era inofensiva ou em dose muito baixa? (y/n)').

% -------------------------------------------------------------------
% 4. REGRAS DE TRIAGEM COM FATORES DE CERTEZA (CF)
% O CF vai de 0.0 a 1.0 (onde 1.0 é 100% de certeza médica)
% -------------------------------------------------------------------

% EMERGÊNCIA (VERMELHO - Acionar INEM/112)
triage_rule('Intoxicações e Envenenamentos', red, Symptoms, CF) :-
    (member(obstrucao_vias_aereas, Symptoms) -> CF1 = 0.95 ; CF1 = 0),
    (member(respiracao_inadequada, Symptoms) -> CF2 = 0.95 ; CF2 = 0),
    (member(convulsoes, Symptoms) -> CF3 = 0.9 ; CF3 = 0),
    (member(inconsciencia, Symptoms) -> CF4 = 0.95 ; CF4 = 0),
    combine_cf([CF1, CF2, CF3, CF4], CF).

% MUITO URGENTE (LARANJA - Contacto imediato CIAV / Urgência Hospitalar)
triage_rule('Intoxicações e Envenenamentos', orange, Symptoms, CF) :-
    \+ triage_rule('Intoxicações e Envenenamentos', red, Symptoms, _), % Só avalia se não for vermelho
    (member(substancia_corrosiva, Symptoms) -> CF1 = 0.9 ; CF1 = 0),
    (member(sintomas_neurologicos_agudos, Symptoms) -> CF2 = 0.85 ; CF2 = 0),
    (member(dor_intensa, Symptoms) -> CF3 = 0.8 ; CF3 = 0),
    combine_cf([CF1, CF2, CF3], CF).

% URGENTE (AMARELO - Avaliação Médica / CIAV)
triage_rule('Intoxicações e Envenenamentos', yellow, Symptoms, CF) :-
    \+ triage_rule('Intoxicações e Envenenamentos', red, Symptoms, _),
    \+ triage_rule('Intoxicações e Envenenamentos', orange, Symptoms, _),
    (member(risco_autoagressao, Symptoms) -> CF1 = 0.8 ; CF1 = 0),
    (member(vomitos_persistentes, Symptoms) -> CF2 = 0.7 ; CF2 = 0),
    (member(dor_moderada, Symptoms) -> CF3 = 0.65 ; CF3 = 0),
    combine_cf([CF1, CF2, CF3], CF).

% POUCO URGENTE / NÃO URGENTE (VERDE / AZUL - Autocuidado e Vigilância)
triage_rule('Intoxicações e Envenenamentos', green, Symptoms, CF) :-
    \+ triage_rule('Intoxicações e Envenenamentos', red, Symptoms, _),
    \+ triage_rule('Intoxicações e Envenenamentos', orange, Symptoms, _),
    \+ triage_rule('Intoxicações e Envenenamentos', yellow, Symptoms, _),
    (member(assintomatico_substancia_segura, Symptoms) -> CF1 = 0.8 ; CF1 = 0),
    combine_cf([CF1], CF).

% -------------------------------------------------------------------
% 5. CÁLCULO DE PROBABILIDADES (Fator de Certeza - Incerteza)
% Fórmula matemática: CF_novo = CF1 + CF2 * (1 - CF1)
% -------------------------------------------------------------------
combine_cf([], 0).
combine_cf([CF], CF).
combine_cf([CF1, CF2|Rest], Final) :-
    Combined is CF1 + CF2 * (1 - CF1),
    combine_cf([Combined|Rest], Final).

% -------------------------------------------------------------------
% 6. EXPLICAÇÕES PARA A INTERFACE (Exigência do enunciado)
% -------------------------------------------------------------------
rule_explanation(red, 'EMERGÊNCIA (Acionar INEM/112)', [
    'Risco imediato de falência de órgãos.',
    'Compromisso das vias aéreas, respiração ou estado de consciência.'
]).

rule_explanation(orange, 'MUITO URGENTE (Contactar CIAV)', [
    'Risco elevado. Substância potencialmente fatal ou corrosiva.',
    'Necessita de avaliação hospitalar urgente.'
]).

rule_explanation(yellow, 'URGENTE', [
    'Sintomas moderados ou risco de autoagressão.',
    'Necessita de observação nas próximas horas.'
]).

rule_explanation(green, 'AUTOCUIDADO / VIGILÂNCIA', [
    'Substância de baixa toxicidade.',
    'Ausência de sintomas críticos. Recomenda-se vigilância domiciliária.'
]).