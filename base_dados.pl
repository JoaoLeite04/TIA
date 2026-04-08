% BASE DE DADOS – INTOXICAÇÕES E ENVENENAMENTOS

% ----- Sintomas críticos (ABC) -----
sintoma_possivel(alteracao_consciencia).
sintoma_possivel(dificuldade_respiratoria).
sintoma_possivel(hemorragia_abundante).

% ----- Sintomas neurológicos -----
sintoma_possivel(convulsoes).

% ----- Sintomas gerais / moderados -----
sintoma_possivel(nauseas).
sintoma_possivel(vomitos).
sintoma_possivel(tonturas).
sintoma_possivel(irritacao_cutanea).

% ----- Vias de exposição -----
via_possivel(inalacao).
via_possivel(ingestao).
via_possivel(contacto).

% ----- Tipos de substâncias -----
substancia_possivel(corrosiva).
substancia_possivel(nao_corrosiva).
substancia_possivel(baixa_toxicidade).

% ----- Estado especial -----
estado_possivel(assintomatico).
