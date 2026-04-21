// O nome do nosso caso (tem de ser igual ao que definimos no Prolog)
const CASE_TYPE = 'intoxicacoes';

// Elementos do HTML (Ecrãs e Botões)
const screenStart = document.getElementById('screen-start');
const screenQuestions = document.getElementById('screen-questions');
const screenResult = document.getElementById('screen-result');

document.getElementById('btn-start').addEventListener('click', startTriage);
document.getElementById('btn-evaluate').addEventListener('click', evaluateTriage);
document.getElementById('btn-restart').addEventListener('click', () => location.reload());

// Função 1: Buscar sintomas ao Prolog e desenhar no ecrã
async function startTriage() {
    screenStart.classList.add('hidden');
    screenQuestions.classList.remove('hidden');

    try {
        // Pede os sintomas à API do Prolog
        const response = await fetch('/api/symptoms', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ caseType: CASE_TYPE })
        });
        
        const symptoms = await response.json();
        const listContainer = document.getElementById('symptoms-list');
        listContainer.innerHTML = '';

        // Cria uma checkbox para cada sintoma que o Prolog enviou
        symptoms.forEach(sym => {
            const div = document.createElement('div');
            div.className = 'symptom-item';
            div.innerHTML = `
                <input type="checkbox" id="${sym.id}" value="${sym.id}">
                <label for="${sym.id}">${sym.question}</label>
            `;
            listContainer.appendChild(div);
        });

    } catch (error) {
        console.error("Erro a contactar o Prolog:", error);
        alert("Erro de ligação. Certifica-te que o servidor Prolog está a correr!");
    }
}

// Função 2: Enviar as respostas escolhidas para o Prolog avaliar
async function evaluateTriage() {
    // Descobre quais checkboxes estão ativas
    const checkboxes = document.querySelectorAll('#symptoms-list input:checked');
    const selectedSymptoms = Array.from(checkboxes).map(cb => cb.value);

    try {
        // Envia para o motor de inferência (triage.pl)
        const response = await fetch('/api/evaluate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ caseType: CASE_TYPE, symptoms: selectedSymptoms })
        });
        
        const result = await response.json();
        showResult(result);

    } catch (error) {
        console.error("Erro a avaliar triagem:", error);
    }
}

// Função 3: Mostrar o resultado na página com as cores certas
function showResult(data) {
    screenQuestions.classList.add('hidden');
    screenResult.classList.remove('hidden');

    const resultBox = document.getElementById('result-box');
    const title = document.getElementById('result-title');
    const certainty = document.getElementById('result-certainty');
    const explanationList = document.getElementById('result-explanation');

    // Dicionário de tradução das cores
    const colorNames = {
        'red': 'PULSEIRA VERMELHA (Emergência)',
        'orange': 'PULSEIRA LARANJA (Muito Urgente)',
        'yellow': 'PULSEIRA AMARELA (Urgente)',
        'green': 'PULSEIRA VERDE (Autocuidado)'
    };

    // Aplica a classe CSS da cor correta
    resultBox.className = `result-box bg-${data.color}`;
    
    // Preenche o texto
    title.innerText = colorNames[data.color] || data.color;
    certainty.innerText = `Certeza Clínica: ${(data.certainty * 100).toFixed(1)}%`;

    // Preenche a justificação médica
    explanationList.innerHTML = '';
    data.explanation.forEach(text => {
        const li = document.createElement('li');
        li.innerText = text;
        explanationList.appendChild(li);
    });
}2