% ===================================================================
% FICHEIRO: interface.pl
% TEMA: Intoxicacoes e Envenenamentos (SNS24)
% OBJETIVO: Interface de Terminal e Servidor Web (API)
% ===================================================================

:- module(interface, [start_consultation/0]).
:- set_prolog_flag(encoding, utf8).
:- use_module(knowledge, [case_types/1, all_symptoms/2, symptom_question/2, case_type_question/2, triage_rule/4, rule_explanation/3]).
:- use_module(triage, [evaluate_triage/5]).

% ===================================================================
% 1. INTERFACE DE TERMINAL (LINHA DE COMANDOS)
% ===================================================================

% Menu Principal
start_consultation :-
    repeat,
    nl,
    writeln('======================================================='),
    writeln('   SNS24 - Triagem de Intoxicacoes e Envenenamentos    '),
    writeln('======================================================='),
    writeln('Escolha uma opcao:'),
    writeln('1. Iniciar Triagem (Sistema Baseado em Regras)'),
    writeln('2. Sair'),
    write('> '),
    read_line_to_string(user_input, Choice),
    (
        Choice = "1" -> handle_deductive_approach ;
        Choice = "2" -> writeln('A encerrar o sistema...'), !, true ;
        writeln('Opcao invalida!')
    ),
    (Choice = "2" -> true ; 
        format('~n~nDeseja avaliar outro utente? (y/n) '),
        read_line_to_string(user_input, Answer),
        ((Answer = "n" ; Answer = "N") -> !, true ; fail)
    ).

% Fluxo de Triagem
handle_deductive_approach :-
    get_case_type_by_questions(CaseType),
    (CaseType = 'Nenhuma das anteriores' ->
        writeln('O caso relatado nao se enquadra no protocolo de Intoxicacoes.')
    ;
        format('~nProtocolo Iniciado: ~w~n', [CaseType]),
        writeln('-------------------------------------------------------'),
        gather_symptoms(CaseType, Symptoms),
        evaluate_triage(CaseType, Symptoms, Color, CF, Explanation),
        show_result(Color, CaseType, Symptoms, CF, Explanation)
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
    (Symptoms = [] -> writeln('- Nenhum sintoma critico reportado.') ; maplist(print_point, Symptoms)),
    format('~nDisposicao Final:~n'),
    format('>>> ~w <<<~n', [Title]),
    format('~nJustificacao:~n'),
    maplist(print_point, Points),
    writeln('=======================================================').

print_point(Point) :-
    format('- ~w~n', [Point]).


% ===================================================================
% 2. SERVIDOR WEB (API PARA FRONTEND)
% ===================================================================

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