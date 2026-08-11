const API_BASE = 'http://localhost:8080/api/materials';

type Aggregatzustand = 'FEST' | 'GAS';

interface Material {
  id: number;
  bezeichnung: string;
  aggregatzustand: Aggregatzustand;
  gasDruckBar: number | null;
}

const form = document.querySelector<HTMLFormElement>('#material-form')!;
const gasDruckField = document.querySelector<HTMLDivElement>('#gas-druck-field')!;
const gasDruckInput = document.querySelector<HTMLInputElement>('#gasDruckBar')!;
const statusEl = document.querySelector<HTMLParagraphElement>('#status')!;
const listBody = document.querySelector<HTMLDivElement>('#list-body')!;
const listCount = document.querySelector<HTMLSpanElement>('#list-count')!;
const radios = form.querySelectorAll<HTMLInputElement>('input[name="aggregatzustand"]');

function aktuellerZustand(): Aggregatzustand {
  return (form.querySelector<HTMLInputElement>('input[name="aggregatzustand"]:checked')?.value ??
    'FEST') as Aggregatzustand;
}

// Kernstück der Anforderung: je nach Aggregatzustand Felder ein-/ausblenden,
// damit das Formular schnell ausgefüllt werden kann.
function feldSichtbarkeitAktualisieren() {
  const zustand = aktuellerZustand();
  const istGas = zustand === 'GAS';

  gasDruckField.hidden = !istGas;
  gasDruckInput.required = istGas;

  if (!istGas) {
    gasDruckInput.value = '';
  }
}

radios.forEach((radio) => radio.addEventListener('change', feldSichtbarkeitAktualisieren));

function setStatus(text: string, state: 'ok' | 'error' | '' = '') {
  statusEl.textContent = text;
  if (state) {
    statusEl.dataset.state = state;
  } else {
    delete statusEl.dataset.state;
  }
}

function renderListe(materialien: Material[]) {
  listCount.textContent = String(materialien.length);

  if (materialien.length === 0) {
    listBody.innerHTML = '<p class="list__empty">Noch nichts erfasst.</p>';
    return;
  }

  listBody.innerHTML = materialien
    .map((m) => {
      const meta = m.aggregatzustand === 'GAS' && m.gasDruckBar != null
        ? `${m.gasDruckBar} bar`
        : '—';
      return `
        <div class="list__item">
          <div class="list__item-main">
            <span class="list__item-name">${escapeHtml(m.bezeichnung)}</span>
            <span class="list__item-meta">${meta}</span>
          </div>
          <span class="list__item-badge" data-state="${m.aggregatzustand}">${m.aggregatzustand}</span>
        </div>
      `;
    })
    .join('');
}

function escapeHtml(value: string): string {
  const div = document.createElement('div');
  div.textContent = value;
  return div.innerHTML;
}

async function ladeMaterialien() {
  try {
    const response = await fetch(API_BASE);
    if (!response.ok) throw new Error('Serverfehler beim Laden');
    const materialien: Material[] = await response.json();
    renderListe(materialien);
  } catch (error) {
    console.error(error);
    setStatus('Backend nicht erreichbar (läuft es auf Port 8080?)', 'error');
  }
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  setStatus('');

  const bezeichnung = (document.querySelector<HTMLInputElement>('#bezeichnung')!).value.trim();
  const zustand = aktuellerZustand();

  if (!bezeichnung) {
    setStatus('Bitte eine Bezeichnung eingeben.', 'error');
    return;
  }

  const payload: Omit<Material, 'id'> = {
    bezeichnung,
    aggregatzustand: zustand,
    gasDruckBar: zustand === 'GAS' && gasDruckInput.value ? Number(gasDruckInput.value) : null,
  };

  try {
    const response = await fetch(API_BASE, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) throw new Error('Serverfehler beim Speichern');

    form.reset();
    feldSichtbarkeitAktualisieren();
    setStatus('Material erfasst.', 'ok');
    await ladeMaterialien();
  } catch (error) {
    console.error(error);
    setStatus('Speichern fehlgeschlagen. Läuft das Backend?', 'error');
  }
});

feldSichtbarkeitAktualisieren();
ladeMaterialien();
