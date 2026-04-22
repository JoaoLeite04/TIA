% ===================================================================
% FICHEIRO: triage.pl
% TEMA: Intoxicações e Envenenamentos (SNS24)
% OBJETIVO: Motor de Inferência (Avaliação e Cálculo de Certeza)
% ===================================================================

:- module(triage, [evaluate_triage/5]).
:- set_prolog_flag(encoding, utf8).
:- use_module(knowledge, [triage_rule/4, rule_explanation/3]).

% evaluate_triage(+TipoCaso, +Sintomas, -Cor, -CF, -Explicacao)
evaluate_triage(TipoCaso, Sintomas, Cor, CF, Explicacao) :-
    
    % 1. Encontra todas as cores (disposições) que atingem o limiar mínimo de certeza (> 0.2)
    findall(
        resultado(C, Certeza, Expl),
        (
            triage_rule(TipoCaso, C, Sintomas, Certeza),
            Certeza > 0.2,  % Limiar mínimo: ignora regras com probabilidade muito baixa
            rule_explanation(C, Titulo, Pontos),
            Expl = [Titulo|Pontos]
        ),
        Resultados
    ),
    
    % 2. Avalia os resultados e decide a disposição final
    (Resultados = [] ->
        % Se não encontrou nenhum sintoma grave (ou a certeza foi muito baixa),
        % assume por defeito a disposição de Autocuidado (Verde).
        Cor = green,
        CF = 0.8, % Dá uma certeza alta (80%) de que a situação é segura
        rule_explanation(green, Titulo, Pontos),
        Explicacao = [Titulo|Pontos]
    ;
        % Se encontrou várias disposições possíveis, ordena pela Certeza (argumento 2)
        % por ordem decrescente (@>=) e extrai a que tem o valor mais alto (a primeira da lista).
        sort(2, @>=, Resultados, [resultado(Cor, CF, Explicacao)|_])
    ).