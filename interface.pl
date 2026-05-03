% ===================================================================
% FICHEIRO: interface.pl
% TEMA: Intoxicações e Envenenamentos (SNS24)
% OBJETIVO: Interface de Terminal e Servidor Web (API)
% ===================================================================

:- module(interface, [start_consultation/0]).
:- set_prolog_flag(encoding, utf8).
:- catch(set_stream(user_output, encoding(utf8)), _, true).
:- catch(set_stream(user_input, encoding(utf8)), _, true).
:- catch(set_stream(user_error, encoding(utf8)), _, true).
:- use_module(knowledge, [case_types/1, all_symptoms/2, symptom_question/2, case_type_question/2, triage_rule/4, rule_explanation/3]).
:- use_module(triage, [evaluate_triage/5]).
:- use_module(inductive_rules, [inductive_triage/3]).

% ===================================================================
% 1. INTERFACE DE TERMINAL (LINHA DE COMANDOS)
% ===================================================================

% Menu Principal
start_consultation :-
    repeat,
    nl,
    writeln('======================================================='),
    writeln('   SNS24 - Triagem de Intoxicações e Envenenamentos    '),
    writeln('======================================================='),
    writeln('Escolha uma opção:'),
    writeln('1. Iniciar Triagem (Sistema Baseado em Regras - Dedutivo)'),
    writeln('2. Iniciar Triagem (Data Mining / Altair - Indutivo)'),
    writeln('3. Sair'),
    write('> '),
    read_line_to_string(user_input, Choice),
    (
        Choice = "1" -> handle_deductive_approach ;
        Choice = "2" -> handle_inductive_approach ;
        Choice = "3" -> writeln('A encerrar o sistema...'), !, true ;
        writeln('Opção inválida!')
    ),
    (Choice = "3" -> true ; 
        format('~n~nDeseja avaliar outro utente? (y/n) '),
        read_line_to_string(user_input, Answer),
        ((Answer = "n" ; Answer = "N") -> !, true ; fail)
    ).

% Fluxo de Triagem Original
handle_deductive_approach :-
    get_case_type_by_questions(CaseType),
    (CaseType = 'Nenhuma das anteriores' ->
        writeln('O caso relatado não se enquadra no protocolo de Intoxicações.')
    ;
        format('~nProtocolo Iniciado (DEDUTIVO): ~w~n', [CaseType]),
        writeln('-------------------------------------------------------'),
        gather_symptoms(CaseType, Symptoms),
        evaluate_triage(CaseType, Symptoms, Color, CF, Explanation),
        show_result(Color, CaseType, Symptoms, CF, Explanation)
    ).

% Fluxo de Triagem Data Mining
handle_inductive_approach :-
    get_case_type_by_questions(CaseType),
    (CaseType = 'Nenhuma das anteriores' ->
        writeln('O caso relatado não se enquadra no protocolo de Intoxicações.')
    ;
        format('~nProtocolo Iniciado (DATA MINING): ~w~n', [CaseType]),
        writeln('-------------------------------------------------------'),
        gather_symptoms(CaseType, Symptoms),
        ( inductive_rules:inductive_triage(CaseType, Symptoms, Decision) ->
            show_inductive_result(CaseType, Symptoms, Decision)
        ;
            writeln('ERRO: Nenhuma regra gerada correspondeu aos sintomas!')
        )
    ).

% Descobre qual é o tipo de caso (neste projeto, só temos 1, mas mantém-se modular)
get_case_type_by_questions(CaseType) :-
    findall(Type, case_type_question(Type, _), Types),
    ask_case_types(Types, CaseType).

ask_case_types([Type|Rest], SelectedType) :-
    case_type_question(Type, Question),
    format('~w (y/n) ', [Question]),
    read_line_to_string(user_input, Answer),
    (
        (Answer = "y" ; Answer = "Y") -> 
        SelectedType = Type
        ;
        (Rest = [] -> 
            SelectedType = 'Nenhuma das anteriores'
            ;
            ask_case_types(Rest, SelectedType)
        )
    ).

% Pergunta todos os sintomas disponíveis para o caso
gather_symptoms(CaseType, Symptoms) :-
    knowledge:all_symptoms(CaseType, AllSymptoms),
    ask_all_symptoms(AllSymptoms, Symptoms).

ask_all_symptoms([], []) :- !.
ask_all_symptoms([Symptom|Rest], [Symptom|Symptoms]) :-
    ask_symptom(Symptom),
    !,
    ask_all_symptoms(Rest, Symptoms).
ask_all_symptoms([_|Rest], Symptoms) :-
    ask_all_symptoms(Rest, Symptoms).

ask_symptom(Symptom) :-
    knowledge:symptom_question(Symptom, Question),
    write(Question), write(' '),
    read_line_to_string(user_input, Answer),
    (Answer = "y" ; Answer = "Y").

% Tradução das Cores
color_translation(red, 'VERMELHO').
color_translation(orange, 'LARANJA').
color_translation(yellow, 'AMARELO').
color_translation(green, 'VERDE / AZUL').

% Mostra o Resultado Final
show_result(Color, CaseType, Symptoms, CF, [Title|Points]) :-
    color_translation(Color, TranslatedColor),
    Percentage is CF * 100,
    writeln('======================================================='),
    format('                 RESULTADO DA TRIAGEM                  ~n'),
    writeln('======================================================='),
    format('Protocolo: ~w~n', [CaseType]),
    format('Prioridade: ~w (Certeza: ~0f%)~n', [TranslatedColor, Percentage]),
    format('~nSintomas reportados:~n'),
    (Symptoms = [] -> writeln('- Nenhum sintoma crítico reportado.') ; maplist(print_point, Symptoms)),
    format('~nDisposição Final:~n'),
    format('>>> ~w <<<~n', [Title]),
    format('~nJustificação:~n'),
    maplist(print_point, Points),
    writeln('=======================================================').

print_point(Point) :-
    format('- ~w~n', [Point]).

% Mostra o Resultado Final (Data Mining)
show_inductive_result(CaseType, Symptoms, Decision) :-
    writeln('======================================================='),
    format('          RESULTADO DA TRIAGEM (DATA MINING)           ~n'),
    writeln('======================================================='),
    format('Protocolo: ~w~n', [CaseType]),
    format('Decisão (Árvore de Decisão): ~w~n', [Decision]),
    format('~nSintomas reportados:~n'),
    (Symptoms = [] -> writeln('- Nenhum sintoma crítico reportado.') ; maplist(print_point, Symptoms)),
    writeln('=======================================================').


% ===================================================================
% 2. SERVIDOR WEB (API PARA FRONTEND)
% ===================================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).

:- http_handler(root(.),  http_reply_from_files('static', []), [prefix]).
:- http_handler('/api/case-types', handle_case_types, []).
:- http_handler('/api/symptoms', handle_symptoms, []).
:- http_handler('/api/evaluate', handle_evaluate, []).

% Iniciar o Servidor
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('~n Servidor Web iniciado em http://localhost:~w~n', [Port]).

% API: Obter Tipos de Caso
handle_case_types(_Request) :-
    findall(_{
        id: Type,
        question: Question
    }, knowledge:case_type_question(Type, Question), TypesList),
    reply_json_dict(TypesList).

% API: Obter Sintomas
handle_symptoms(Request) :-
    http_read_json_dict(Request, Data),
    atom_string(CaseType, Data.caseType),
    all_symptoms(CaseType, AllowedSymptoms),
    findall(_{
        id: Symptom,
        question: Question_NoYN
    }, (
        member(Symptom, AllowedSymptoms),
        symptom_question(Symptom, Question),
        % Remove o " (y/n)" do final da pergunta para mostrar na web
        sub_string(Question, 0, L, 6, Question_NoYN),
        L >= 0
    ), SymptomsList),
    reply_json_dict(SymptomsList).

% API: Avaliar Triagem
handle_evaluate(Request) :-
    http_read_json_dict(Request, Data),
    atom_string(CaseType, Data.caseType),
    % Converte sintomas do JSON para Prolog
    maplist(atom_string, Symptoms, Data.symptoms),
    evaluate_triage(CaseType, Symptoms, Color, CF, Explanation),
    reply_json_dict(_{
        color: Color,
        certainty: CF,
        caseType: CaseType,
        symptoms: Data.symptoms,
        explanation: Explanation
    }).

% Inicializa o servidor web automaticamente na porta 8080 ao carregar o módulo
:- initialization(start_server(8080)).