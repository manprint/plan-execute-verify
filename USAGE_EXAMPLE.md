# Esempi d'uso: matrice modalità × opzioni

Questo documento espande, per ogni modalità di `/plan-execute-verify`, l'effetto
di ogni opzione iniziale: una breve descrizione, le implicazioni e il comando di
invocazione. Le regole normative restano in [SKILL.md](SKILL.md) e in
[references/invocation.md](references/invocation.md); in caso di dubbio
prevalgono quelle.

## Come leggere la matrice

Forma del comando:

```text
/plan-execute-verify [<opzioni e prefisso agenti, in qualsiasi ordine>] [<modalità>] <argomenti>
```

- Le opzioni valgono solo nella sequenza iniziale. Il primo token che non è
  un'opzione né un prefisso agenti chiude il parsing: in
  `task aggiungi l'opzione --json al comando export` il token `--json` resta
  testo della descrizione.
- Modalità: `onboard`, `plan` (anche implicita: una descrizione senza parola
  chiave), `execute`, `execute verify`, `task`, `bug`, `verify`, `resume`,
  `handoff`.
- Ogni modalità ha 15 casi: nessuna opzione; i due valori di
  `full-autonomous`; le due opzioni WIP da sole; le quattro coppie autonomia ×
  WIP, elencate perché insieme decidono i commit; i tre livelli di
  `executor-power`; le due forme del prefisso agenti; `--deadline`.
- La coppia autonomia/WIP, `executor-power`, il prefisso agenti e
  `--deadline` sono indipendenti: i loro effetti si sommano senza influenzarsi,
  quindi le combinazioni miste non sono enumerate (vedi
  [Combinazioni](#combinazioni)).
- I selettori (piano, fase, sotto-fase, report, voce di ledger) sono argomenti,
  non opzioni: compaiono solo dove cambiano le implicazioni di un caso.
- Gli esempi usano il piano `003` (`docs/plans/003_plan-RateLimit/`), il roster
  `agent-1:opus,agent-2:sonnet,agent-3:haiku` e l'agente singolo `my-model`:
  sostituiscili con identificativi supportati dal tuo host.

### Risoluzione delle impostazioni

`full-autonomous` e WIP si risolvono separatamente, in quest'ordine:

1. Opzione esplicita nell'invocazione.
2. Override dello scope di esecuzione salvato, solo mentre si continua quello
   scope.
3. Default del piano in STATE.md §3, scritti da Plan.
4. Default: `full-autonomous:false`, WIP off.

`executor-power` non segue quest'ordine: lo accetta solo Plan, che lo salva in
§3 (default `low`; un piano precedente all'opzione vale `low`). Ogni altra
modalità rifiuta l'opzione.

`--deadline` non segue quest'ordine: vale solo per l'invocazione che la riceve,
non viene salvata e non passa a un `resume` successivo.

| Modalità | Opzioni esplicite | Prefisso agenti |
|----------|-------------------|-----------------|
| Onboard | Solo per l'ispezione, mai salvate | Solo per l'ispezione |
| Plan | Default del piano in §3 | Roster salvato nel piano |
| Execute, Execute verify | Override dello scope che avviano, mai §3 | Sostituisce il roster del piano |
| Task, Bug, Verify, Resume | Solo per l'invocazione; registrate nella voce di ledger, nel report di audit o nell'unità ripresa | Solo per l'invocazione, registrato con essa |
| Handoff | Ignorate e segnalate, tranne `--deadline` (solo per questa run) | Ignorato e segnalato |

### Commit risultanti

| `full-autonomous` | WIP | Unità di codice e chiusure di fase completate | Commit WIP a rotazione ai checkpoint | Audit completato |
|-------------------|-----|-----------------------------------------------|--------------------------------------|------------------|
| `false` | off | No | No | No |
| `false` | on | Sì | Sì | No |
| `true` | off | Sì | No | Sì, solo artefatti |
| `true` | on | Sì | Sì | Sì, solo artefatti |

Un'unità di codice è una sotto-fase, un task, un bug fix o una correzione di
audit. Plan e Onboard non fanno mai commit. Un handoff (`handoff` o
`--deadline`) crea sempre un commit `handoff(request-by-user): …` per il lavoro
sul codice, anche con i commit disattivati; Plan e Verify interrotti salvano
solo il checkpoint. Nessuna combinazione autorizza push,
deploy, cambi di branch o lavoro fuori scope: i commit sono locali, sul branch
corrente. Con i commit disattivati il report finale avvisa che lavoro e record
del piano non sono committati e suggerisce il comando di commit senza eseguirlo.

## Default quando le opzioni sono omesse

Un'opzione omessa non vale sempre il default di fabbrica: prima si cercano i
valori salvati.

| Opzione omessa | Valore usato | Effetto del default di fabbrica |
|----------------|--------------|---------------------------------|
| `full-autonomous` | Override dello scope salvato (solo continuando lo stesso scope) → §3 del piano → **`false`** | Stop dopo ogni chiusura di fase (Task e Bug: uno stop per approvare il mini-piano); nessun commit di completamento |
| `--wip-commit` / `--no-wip-commit` | Override dello scope salvato → §3 del piano → **WIP off** | Nessun commit WIP a rotazione |
| `executor-power` | In Plan **`low`**; un piano senza valore salvato vale `low` | Le altre modalità usano sempre il livello del piano; `low` in `000_adhoc` |
| Prefisso agenti | Roster salvato nel piano → roster legacy **Opus/Sonnet/Haiku** in agent-1/agent-2/agent-3 | Revisioni obbligatorie e chiusure di fase ad agent-1 |
| `--deadline` | **Nessuna deadline** | La run si ferma solo a fine scope, blocco, stop dell'utente o `handoff`; `handoff` senza deadline si ferma subito |

Default effettivi per modalità, senza alcuna opzione:

| Modalità | `full-autonomous` | WIP | `executor-power` | Roster |
|----------|-------------------|-----|------------------|--------|
| Onboard | Irrilevante: mai commit | Irrilevante | Mostra quello del piano | Del piano, altrimenti legacy; solo per l'ispezione |
| Plan | `false`, salvato in §3 | Off, salvato in §3 | `low`, salvato in §3 | Legacy Opus/Sonnet/Haiku, salvato |
| Execute | Override dello scope → §3 → `false` | Override dello scope → §3 → off | Del piano | Del piano |
| Execute verify | Override dello scope → §3 → `false` | Override dello scope → §3 → off | Del piano | Del piano |
| Task, Bug su un piano | §3 → `false` | §3 → off | Del piano | Del piano |
| Task, Bug in `000_adhoc` | `false` | Off | `low` | Legacy |
| Verify | §3 → `false` (`false` in `000_adhoc`) | Irrilevante: il WIP non committa audit | Del piano, per le correzioni | Del piano, altrimenti legacy |
| Resume | Registrato sull'unità ripresa; per lo scope continuato, override → §3 → `false` | Come per `full-autonomous`, con default off | Del piano | Registrato sull'unità ripresa, altrimenti del piano |
| Handoff | Ignorato: il commit di handoff avviene comunque per il codice | Ignorato | Invariato | Invariato |

In nessuna modalità c'è una deadline di default.

Default degli argomenti omessi:

| Modalità | Argomento omesso | Default |
|----------|------------------|---------|
| Onboard | Piano | Inventario di piani e ledger ad-hoc; non sceglie il numero più alto |
| Plan | Descrizione | Nessuno: è obbligatoria |
| Execute | Piano | Piano reale con il numero più alto, ignorando `000_adhoc`; chiede se più piani attivi sono ambigui |
| Execute | Fase o sotto-fase | Intero piano |
| Execute verify | Piano | Come Execute |
| Execute verify | Report `V<NNN>` | Report più recente del piano |
| Task, Bug | Piano (non è un selettore) | `000_adhoc`, salvo richiesta che nomina un piano o ne cambia chiaramente uno attivo |
| Verify | Piano | Come Execute |
| Verify | Fase, sotto-fase o voce | Intero piano |
| Resume | Piano | Unico piano o ledger con lavoro riprendibile o scope salvato NOT_STARTED, RUNNING o BLOCKED; con più candidati chiede |
| Resume | ID unità | Recupera il lavoro aperto, poi continua lo scope salvato |
| Handoff | Deadline | Handoff immediato |
| Handoff | Target (non è un selettore) | La run in corso; da sessione inattiva, il piano o ledger scritto per ultimo, altrimenti l'unico con lavoro aperto o non committato |

## Matrice riassuntiva

Ogni cella riporta l'ID del caso e l'effetto in breve; i dettagli sono nelle
sezioni per modalità.

| # | Opzioni | Onboard | Plan | Execute | Execute verify | Task | Bug | Verify | Resume | Handoff |
|---|---------|---------|------|---------|----------------|------|-----|--------|--------|---------|
| 01 | nessuna (default) | ON-01 solo ispezione | PL-01 default in §3 | EX-01 impostazioni salvate | EV-01 impostazioni salvate | TA-01 §3 o default | BU-01 §3 o default | VE-01 §3 o default | RE-01 impostazioni registrate | HA-01 handoff immediato |
| 02 | `full-autonomous:true` | ON-02 nessun effetto | PL-02 salvato in §3 | EX-02 tutto lo scope, commit | EV-02 tutte le correzioni, commit | TA-02 commit del task | BU-02 commit del fix | VE-02 commit dell'audit | RE-02 solo questa run | HA-02 ignorata, handoff |
| 03 | `full-autonomous:false` | ON-03 nessun effetto | PL-03 salvato in §3 | EX-03 stop dopo la fase | EV-03 stop dopo fase riaperta | TA-03 approvazione, niente commit di completamento | BU-03 approvazione, niente commit di completamento | VE-03 nessun commit | RE-03 solo questa run | HA-03 ignorata, handoff |
| 04 | `--wip-commit` | ON-04 nessun effetto | PL-04 salvato in §3 | EX-04 commit + WIP | EV-04 commit + WIP | TA-04 commit + WIP | BU-04 commit + WIP | VE-04 nessun effetto | RE-04 solo questa run | HA-04 ignorata, handoff |
| 05 | `--no-wip-commit` | ON-05 nessun effetto | PL-05 salvato in §3 | EX-05 niente WIP | EV-05 niente WIP | TA-05 niente WIP | BU-05 niente WIP | VE-05 nessun effetto | RE-05 solo questa run | HA-05 ignorata, handoff |
| 06 | `full-autonomous:true --wip-commit` | ON-06 nessun effetto | PL-06 salvati in §3 | EX-06 tutto lo scope, commit + WIP | EV-06 tutte le correzioni, commit + WIP | TA-06 commit + WIP | BU-06 commit + WIP | VE-06 commit dell'audit | RE-06 solo questa run | HA-06 ignorata, handoff |
| 07 | `full-autonomous:false --wip-commit` | ON-07 nessun effetto | PL-07 salvati in §3 | EX-07 stop dopo la fase, commit + WIP | EV-07 stop dopo fase riaperta, commit + WIP | TA-07 approvazione, commit + WIP | BU-07 approvazione, commit + WIP | VE-07 nessun commit | RE-07 solo questa run | HA-07 ignorata, handoff |
| 08 | `full-autonomous:true --no-wip-commit` | ON-08 nessun effetto | PL-08 salvati in §3 | EX-08 tutto lo scope, solo commit di completamento | EV-08 tutte le correzioni, solo commit di completamento | TA-08 solo commit di completamento | BU-08 solo commit di completamento | VE-08 commit dell'audit | RE-08 solo questa run | HA-08 ignorata, handoff |
| 09 | `full-autonomous:false --no-wip-commit` | ON-09 nessun effetto | PL-09 salvati in §3 | EX-09 stop dopo la fase, nessun commit | EV-09 stop dopo fase riaperta, nessun commit | TA-09 approvazione, nessun commit | BU-09 approvazione, nessun commit | VE-09 nessun commit | RE-09 solo questa run | HA-09 ignorata, handoff |
| 10 | `executor-power:low` | ON-10 errore | PL-10 piano `low` | EX-10 errore | EV-10 errore | TA-10 errore | BU-10 errore | VE-10 errore | RE-10 errore | HA-10 ignorata, handoff |
| 11 | `executor-power:medium` | ON-11 errore | PL-11 piano `medium` | EX-11 errore | EV-11 errore | TA-11 errore | BU-11 errore | VE-11 errore | RE-11 errore | HA-11 ignorata, handoff |
| 12 | `executor-power:high` | ON-12 errore | PL-12 piano `high` | EX-12 errore | EV-12 errore | TA-12 errore | BU-12 errore | VE-12 errore | RE-12 errore | HA-12 ignorata, handoff |
| 13 | `agent-1:opus,agent-2:sonnet,agent-3:haiku` | ON-13 solo ispettori | PL-13 roster salvato | EX-13 sostituisce il roster | EV-13 sostituisce il roster | TA-13 solo questa run | BU-13 solo questa run | VE-13 solo questo audit | RE-13 solo questa run | HA-13 ignorato, handoff |
| 14 | `agent:my-model` | ON-14 un solo ispettore | PL-14 agente unico salvato | EX-14 agente unico, self-review | EV-14 agente unico, self-review | TA-14 agente unico, self-review | BU-14 agente unico, self-review | VE-14 agente unico | RE-14 solo questa run | HA-14 ignorato, handoff |
| 15 | `--deadline=31-10-2026_17_30` | ON-15 stop alla scadenza, si rilancia | PL-15 bozza salvata alla scadenza | EX-15 handoff alla scadenza | EV-15 handoff alla scadenza | TA-15 handoff alla scadenza | BU-15 handoff alla scadenza | VE-15 audit OPEN alla scadenza | RE-15 handoff alla scadenza | HA-15 handoff entro la scadenza |

## Errori indipendenti dalla modalità

Queste invocazioni vengono rifiutate prima di qualsiasi lavoro, in ogni
modalità tranne `handoff`. Un errore non fa mai ripiegare su un'altra modalità.

| Invocazione | Motivo |
|-------------|--------|
| `/plan-execute-verify full-autonomous:yes execute 003` | Valore non letterale: solo `true` o `false` |
| `/plan-execute-verify full-autonomous:true full-autonomous:false execute 003` | Opzione di autonomia duplicata |
| `/plan-execute-verify --wip-commit --no-wip-commit execute 003` | Opzioni WIP in conflitto |
| `/plan-execute-verify executor-power:max plan aggiungi export CSV` | Valore di `executor-power` non valido |
| `/plan-execute-verify executor-power:low executor-power:high plan aggiungi export CSV` | `executor-power` duplicato |
| `/plan-execute-verify executor-power:high execute 003` | `executor-power` fuori da Plan (casi 10–12 delle altre modalità) |
| `/plan-execute-verify --deadline=31-10-26_17_30 execute 003` | Deadline non valida: formato `dd-mm-yyyy_hh_mm` |
| `/plan-execute-verify --deadline=31-10-2026_17_30 --deadline=31-10-2026_18_00 execute 003` | `--deadline` duplicata |
| `/plan-execute-verify --deadline=31-02-2026_17_30 execute 003` | Deadline non valida: data inesistente |
| `/plan-execute-verify --fast execute 003` | Opzione iniziale sconosciuta |
| `/plan-execute-verify agent:opus,agent-2:sonnet execute 003` | Forme del prefisso miste |
| `/plan-execute-verify agent-1:opus,agent-3:haiku execute 003` | Indici con buchi: partono da 1, contigui |
| `/plan-execute-verify agent-1:opus,agent-1:sonnet execute 003` | Indice duplicato |
| `/plan-execute-verify agent-1:opus,agent-2: execute 003` | Nome mancante |

Le sole opzioni, come `/plan-execute-verify full-autonomous:true`, non
selezionano alcun lavoro. Argomenti mancanti o selettori non validi sono errori.

`handoff` fa eccezione: non rifiuta mai una richiesta di stop, perché fermarsi
prima non perde lavoro. Ignora e segnala opzioni, prefisso e selettori che non
usa; una deadline non valida o due deadline diverse valgono come handoff
immediato (casi HA-02…HA-15).

## Onboard

```text
/plan-execute-verify [<opzioni>] onboard [<piano>]
```

Ispeziona il repository, o il piano indicato per numero, nome univoco o
percorso, scrive solo `docs/onboarding.md` e suggerisce un comando successivo
senza eseguirlo. Non accetta selettori di fase o di report. Le opzioni sono
validate normalmente ma non autorizzano commit, modifiche di stato o
l'esecuzione del suggerimento; non vengono salvate né riportate nel comando
suggerito. Il recap mostra separatamente i default del piano (§3), gli override
dello scope salvato (§1) e le impostazioni locali all'invocazione.

### ON-01 · nessuna opzione

```text
/plan-execute-verify onboard 003
```

- **Descrizione:** mappa il progetto con il focus sul piano 003, confronta il
  checkpoint con il repository reale e propone un comando successivo.
- **Implicazioni:** nessun commit e nessuna modifica a codice, piani,
  impostazioni o roster. Se lo scope salvato o il piano hanno
  `full-autonomous:true`, il recap avverte che riprendere erediterebbe i commit
  automatici.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); roster del piano, altrimenti legacy Opus/Sonnet/Haiku, solo per
  l'ispezione; nessuna deadline.

### ON-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true onboard
```

- **Descrizione:** opzione accettata e validata, senza effetto operativo.
- **Implicazioni:** Onboard non esegue l'azione suggerita e non fa commit.
  L'opzione non viene salvata, non cambia il default del piano e non compare nel
  comando suggerito.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false onboard
```

- **Descrizione:** opzione accettata e validata, senza effetto operativo.
- **Implicazioni:** identiche a ON-01; il valore salvato nel piano resta quello
  che era.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit onboard
```

- **Descrizione:** opzione accettata, senza effetto.
- **Implicazioni:** Onboard non fa commit, nemmeno di `docs/onboarding.md`.
  L'opzione non viene salvata.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); roster del piano, altrimenti legacy Opus/Sonnet/Haiku, solo per
  l'ispezione; nessuna deadline; selettore omesso: inventario di piani e ledger.

### ON-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit onboard
```

- **Descrizione:** opzione accettata, senza effetto.
- **Implicazioni:** Onboard non fa comunque commit; il WIP salvato nel piano non
  cambia.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); roster del piano, altrimenti legacy Opus/Sonnet/Haiku, solo per
  l'ispezione; nessuna deadline; selettore omesso: inventario di piani e ledger.

### ON-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit onboard
```

- **Descrizione:** coppia accettata e validata, senza effetto.
- **Implicazioni:** nessun commit, nessuna esecuzione del suggerimento, niente
  salvato.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit onboard
```

- **Descrizione:** coppia accettata e validata, senza effetto.
- **Implicazioni:** come ON-06.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit onboard
```

- **Descrizione:** coppia accettata e validata, senza effetto.
- **Implicazioni:** come ON-06.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit onboard
```

- **Descrizione:** coppia accettata e validata, senza effetto.
- **Implicazioni:** come ON-06.
- **Default applicati:** roster del piano, altrimenti legacy Opus/Sonnet/Haiku,
  solo per l'ispezione; nessuna deadline; selettore omesso: inventario di piani
  e ledger.

### ON-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low onboard
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessuna ispezione. Il recap di un'esecuzione corretta
  riporta comunque il livello salvato nel piano.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### ON-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium onboard
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come ON-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### ON-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high onboard
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come ON-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### ON-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku onboard
```

- **Descrizione:** sceglie gli agenti che svolgono questa ispezione; per la
  ricostruzione architetturale iniziale è preferito l'agente forte (agent-1).
- **Implicazioni:** il roster vale solo per l'ispezione e non cambia le
  assegnazioni salvate del piano. Il report registra l'agente che ha ispezionato
  davvero e i limiti; un'interpretazione architetturale incerta resta
  etichettata come non revisionata, con l'handoff necessario.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); nessuna deadline; selettore omesso: inventario di piani e ledger.

### ON-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model onboard
```

- **Descrizione:** un solo agente svolge l'ispezione.
- **Implicazioni:** ogni revisione è self-review. Le assegnazioni salvate del
  piano non cambiano.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); nessuna deadline; selettore omesso: inventario di piani e ledger.

### ON-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 onboard
```

- **Descrizione:** ispezione normale, che si ferma entro la deadline.
- **Implicazioni:** Onboard è breve e di sola lettura: la deadline evita solo
  di sforare. Alla scadenza l'ispezione si interrompe senza altre scritture né
  commit, e il report propone di rilanciare `/plan-execute-verify onboard`. Se
  l'ispezione finisce prima, termina normalmente. La deadline non viene salvata.
- **Default applicati:** autonomia e WIP non contano (Onboard non fa mai
  commit); roster del piano, altrimenti legacy Opus/Sonnet/Haiku, solo per
  l'ispezione; selettore omesso: inventario di piani e ledger.

## Plan

```text
/plan-execute-verify [<opzioni>] plan <descrizione>
/plan-execute-verify [<opzioni>] <descrizione>
```

Crea `docs/plans/<NNN>_plan-<Nome>/` con overview.md, i file di fase e
STATE.md, usando il numero più alto esistente più uno. Non scrive codice di
produzione e non fa commit: le opzioni preimpostano l'esecuzione futura ma non
la autorizzano. Le opzioni esplicite diventano default del piano in §3 e il
prefisso diventa il roster salvato; lo scope di esecuzione resta `none` finché
Execute non lo imposta. Se la cartella del piano non è committata, il report
finale lo dice e suggerisce
`git add docs/plans/<id> && git commit -m "plan(<id>): <feature>"` senza
eseguirlo. Usa la forma esplicita `plan` quando la descrizione inizia con una
parola riservata, per esempio `plan task queue per i job in background`.

### PL-01 · nessuna opzione

```text
/plan-execute-verify aggiungi limiti di richieste per utente
```

- **Descrizione:** Plan implicito: crea il piano successivo con le impostazioni
  di default.
- **Implicazioni:** §3 riceve `full-autonomous:false`, WIP off e
  `executor-power:low`: la scomposizione più fine (di solito 3–6 sotto-fasi
  elementari per fase, con snippet verificati), quindi il piano più costoso da
  scrivere. Senza prefisso un nuovo piano usa il roster legacy
  Opus/Sonnet/Haiku. Un successivo `execute 003` senza opzioni si ferma dopo
  ogni chiusura di fase e non fa commit.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; `executor-power:low` salvato in §3; roster legacy Opus/Sonnet/Haiku
  salvato nel piano; nessuna deadline.

### PL-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva `true` come default del piano.
- **Implicazioni:** la pianificazione resta senza implementazione e senza
  commit. Senza opzioni esplicite, un successivo `execute 003` procede su tutto
  lo scope selezionato e committa ogni sotto-fase e chiusura di fase; anche
  `verify 003` committa i propri artefatti e un Task o Bug collegato al piano
  viene committato al completamento.
- **Default applicati:** WIP off salvato in §3; `executor-power:low` salvato in
  §3; roster legacy Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva esplicitamente `false`, uguale al default.
- **Implicazioni:** le esecuzioni future senza opzioni si fermano dopo ogni
  chiusura di fase e non fanno commit di completamento, salvo WIP attivo.
  Un'esecuzione può comunque passare `full-autonomous:true` per il proprio
  scope.
- **Default applicati:** WIP off salvato in §3; `executor-power:low` salvato in
  §3; roster legacy Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva WIP on come default del piano.
- **Implicazioni:** con l'autonomia di default (`false`), le esecuzioni future
  committano unità e chiusure di fase completate e aggiornano un commit
  `wip(<id>)` a rotazione a ogni checkpoint, fermandosi dopo ogni chiusura di
  fase. Il solo WIP non committa mai audit né pianificazione.
- **Default applicati:** `full-autonomous:false` salvato in §3;
  `executor-power:low` salvato in §3; roster legacy Opus/Sonnet/Haiku salvato
  nel piano; nessuna deadline.

### PL-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva esplicitamente WIP off, uguale al default.
- **Implicazioni:** nessun commit WIP nelle esecuzioni future. Non disattiva i
  commit di completamento dovuti a `full-autonomous:true`.
- **Default applicati:** `full-autonomous:false` salvato in §3;
  `executor-power:low` salvato in §3; roster legacy Opus/Sonnet/Haiku salvato
  nel piano; nessuna deadline.

### PL-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva entrambe le impostazioni al massimo.
- **Implicazioni:** le esecuzioni future percorrono tutto lo scope con commit di
  completamento e commit WIP a rotazione ai checkpoint: recupero più fine,
  storia Git più fitta.
- **Default applicati:** `executor-power:low` salvato in §3; roster legacy
  Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva autonomia off e WIP on.
- **Implicazioni:** le esecuzioni future si fermano dopo ogni chiusura di fase,
  ma committano unità e fasi completate e il WIP a rotazione.
- **Default applicati:** `executor-power:low` salvato in §3; roster legacy
  Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva autonomia on e WIP off.
- **Implicazioni:** le esecuzioni future percorrono tutto lo scope e committano
  solo unità e fasi completate e verificate; il lavoro interrotto resta nel
  working tree, non in un commit.
- **Default applicati:** `executor-power:low` salvato in §3; roster legacy
  Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit plan aggiungi limiti di richieste per utente
```

- **Descrizione:** salva esplicitamente entrambi i valori di default.
- **Implicazioni:** le esecuzioni future senza opzioni si fermano dopo ogni
  fase e non fanno commit automatici.
- **Default applicati:** `executor-power:low` salvato in §3; roster legacy
  Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low plan aggiungi limiti di richieste per utente
```

- **Descrizione:** piano per esecutori deboli (esempi: Haiku, Luna); uguale al
  default, ma esplicito.
- **Implicazioni:** più fasi e di solito 3–6 sotto-fasi elementari e testabili
  per fase; passi meccanici con posizioni esatte; ogni scelta architetturale,
  pattern e best practice esplicitata; snippet di codice verificati dal
  supervisore per le parti complesse. L'esecutore decide solo come ritrovare il
  codice e i dettagli che il piano lascia esplicitamente aperti. È il piano più
  lungo e costoso da produrre.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; roster legacy Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium plan aggiungi limiti di richieste per utente
```

- **Descrizione:** piano per esecutori abbastanza capaci (esempi: Sonnet, Terra,
  DeepSeek).
- **Implicazioni:** di solito 2–4 sotto-fasi per fase, con contratti, decisioni,
  pattern e passi dettagliati; snippet solo dove la prosa non basta a fissare un
  contratto. L'esecutore può anche riempire dettagli di routine (nomi locali,
  estrazione di helper, test aggiuntivi sui casi limite) che non cambiano alcuna
  decisione.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; roster legacy Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

### PL-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high plan aggiungi limiti di richieste per utente
```

- **Descrizione:** piano per esecutori forti (esempi: Fable, Opus, Astra, Sol,
  Kimi K3).
- **Implicazioni:** fasi più grandi, di solito 1–3 sotto-fasi di risultato per
  fase. Il supervisore fissa risultato, interfacce pubbliche, invarianti,
  errori, test di accettazione, gate e rischi; l'esecutore pianifica i propri
  passi e decide l'implementazione interna. I passi espansi vanno in STATE.md
  §6 prima delle modifiche (in stile delegato il worker li restituisce con il
  risultato e il coordinatore li registra), le decisioni interne in §8, riviste
  da agent-1 alla chiusura di fase. Ogni cambio di contratto passa da agent-1.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; roster legacy Opus/Sonnet/Haiku salvato nel piano; nessuna deadline.

Per PL-10, PL-11 e PL-12 il livello resta quello del piano per tutta la sua
vita: Execute non lo cambia e non esiste ancora un comando per cambiarlo. Task e
Bug collegati e le correzioni scritte da Verify seguono questo livello. La skill
non deduce il livello dai nomi dei modelli: sceglilo per l'implementatore più
debole che riceverà unità. Se in seguito assegni un implementatore più debole,
il supervisore ricalibra le sue unità prima del dispatch.

### PL-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku plan aggiungi limiti di richieste per utente
```

- **Descrizione:** agent-1 pianifica e supervisiona, agent-2 è
  l'implementatore principale, agent-3 fa ricognizione e implementazione
  assegnata.
- **Implicazioni:** il roster viene salvato in STATE.md; i file di fase nominano
  solo posizioni (`agent-2`), mai modelli, quindi un cambio di roster non
  richiede revisioni del piano. Execute ed Execute verify possono sostituirlo;
  Task, Bug, Verify e Resume lo cambiano solo per la propria invocazione. Con
  `agent-3:haiku` tra gli implementatori, `executor-power:low` è coerente.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; `executor-power:low` salvato in §3; nessuna deadline.

### PL-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model plan aggiungi limiti di richieste per utente
```

- **Descrizione:** un solo agente pianifica, implementa e revisiona; equivale a
  `agent-1:my-model`.
- **Implicazioni:** il roster salvato contiene solo quell'agente e ogni
  revisione è etichettata self-review. Scegli `executor-power` in base alla
  capacità di quell'agente.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off salvato
  in §3; `executor-power:low` salvato in §3; nessuna deadline.

### PL-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 plan aggiungi limiti di richieste per utente
```

- **Descrizione:** ricerca e pianificazione procedono; alla scadenza Plan
  salva il checkpoint della bozza (DRAFT) e si ferma senza commit.
- **Implicazioni:** la bozza resta non committata: il report lo segnala e
  suggerisce il comando di commit senza eseguirlo. Si riprende con
  `/plan-execute-verify resume <piano>`, usando il numero del nuovo piano. Se il
  piano diventa READY prima della scadenza, Plan termina normalmente. La
  deadline non viene salvata in §3.
- **Default applicati:** `full-autonomous:false` salvato in §3; WIP off
  salvato in §3; `executor-power:low` salvato in §3; roster legacy
  Opus/Sonnet/Haiku salvato nel piano.

## Execute

```text
/plan-execute-verify [<opzioni>] execute [<piano>] [<fase o sotto-fase>]
```

Implementa le unità eleggibili dentro lo scope selezionato: il piano intero,
`phase_02`, `1.2`, `§ 1.2` o `phase_02 § 1.2`. Senza piano usa il piano reale
con il numero più alto e chiede se più piani attivi rendono ambiguo il target.
Il selettore e le opzioni esplicite diventano lo scope di esecuzione salvato con
i suoi override: durano attraverso resume e nuove sessioni, decadono quando un
selettore diverso lo sostituisce e non cambiano mai §3. Lo stesso selettore su
uno scope RUNNING o BLOCKED lo continua, e le nuove opzioni esplicite ne
sostituiscono gli override; un selettore diverso su uno scope RUNNING o BLOCKED
chiede conferma prima di sostituirlo. Uno scope di sotto-fase termina alla sua
chiusura e non include mai la chiusura di fase `P<N>`; `execute 003 phase_02`
la include.

### EX-01 · nessuna opzione

```text
/plan-execute-verify execute 003
```

- **Descrizione:** esegue il piano 003 con le impostazioni risolte.
- **Implicazioni:** se continui lo stesso scope RUNNING o BLOCKED valgono i suoi
  override, altrimenti §3, altrimenti i default. Con i default procede fino alla
  chiusura della fase corrente, si ferma dopo `P<N>` (riprendi con
  `resume 003`) e non fa commit. Se Plan aveva salvato `full-autonomous:true`,
  procede su tutto lo scope e committa.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline; fase omessa: intero
  piano.

### EX-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute 003
```

- **Descrizione:** procede su tutto lo scope senza fermarsi ai confini di unità
  o di fase.
- **Implicazioni:** commit locale di ogni sotto-fase e chiusura di fase
  completate; si ferma solo per un blocco reale, uno stop dell'utente o
  un'interruzione dell'host. L'opzione resta come override dello scope e non
  cambia §3. Con `execute 003 § 1.2` resta limitato alla sotto-fase 1.2: non
  prosegue in 1.3 né esegue `P1`. Il WIP si risolve da override, §3 o default.
- **Default applicati:** WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline; fase omessa: intero
  piano.

### EX-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute 003
```

- **Descrizione:** procede fino alla fine della fase corrente e si ferma dopo la
  sua chiusura.
- **Implicazioni:** un confine di sotto-fase non è un punto di stop. L'opzione
  non aggiunge commit, ma se il WIP risolto è on (da override o §3) i commit
  avvengono comunque: per escluderli tutti vedi EX-09. Lo scope resta RUNNING e
  `resume 003` continua con la fase successiva.
- **Default applicati:** WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline; fase omessa: intero
  piano.

### EX-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute 003
```

- **Descrizione:** attiva il WIP come override dello scope; l'autonomia si
  risolve da override, §3 o default.
- **Implicazioni:** commit di ogni sotto-fase e chiusura di fase completate, più
  un unico commit `wip(<id>)` a rotazione aggiornato a ogni checkpoint
  dell'unità aperta: un crash perde al più il lavoro dall'ultimo checkpoint. Con
  autonomia `false` si ferma comunque dopo ogni chiusura di fase.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute 003
```

- **Descrizione:** disattiva il WIP per questo scope.
- **Implicazioni:** niente commit WIP. Se l'autonomia risolta è `true` (per
  esempio da §3) i commit di completamento restano; se è `false` non c'è alcun
  commit.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute 003
```

- **Descrizione:** tutto lo scope, con il massimo dei commit.
- **Implicazioni:** commit di completamento per ogni sotto-fase e fase, più il
  WIP a rotazione ai checkpoint. Entrambi restano come override dello scope.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute 003
```

- **Descrizione:** si ferma dopo ogni chiusura di fase, ma committa.
- **Implicazioni:** commit di unità e fasi completate e WIP a rotazione;
  `resume 003` riparte dalla fase successiva con gli stessi override.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute 003
```

- **Descrizione:** tutto lo scope, solo commit di completamento.
- **Implicazioni:** viene committato solo lavoro completato, verificato e
  revisionato. A un'interruzione il lavoro parziale resta nel working tree e
  `resume` lo riconcilia con la base dell'unità.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

- **Descrizione:** si ferma dopo ogni chiusura di fase, senza commit.
- **Implicazioni:** è l'unico modo per escludere tutti i commit automatici,
  qualunque cosa dica §3; solo un handoff crea comunque il suo commit. Il report
  avvisa del lavoro non committato e suggerisce il comando.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; fase omessa: intero piano.

### EX-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessuna esecuzione. Execute usa sempre il livello salvato
  nel piano e non esiste ancora un comando per cambiarlo.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EX-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come EX-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EX-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come EX-10. Un esecutore forte non ottiene più autonomia di
  quella prevista dal livello salvato.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EX-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

- **Descrizione:** sostituisce il roster del piano e aggiorna le assegnazioni
  rimanenti.
- **Implicazioni:** il nuovo roster viene salvato e vale anche per le esecuzioni
  successive; non serve una revisione del piano. Se un nuovo implementatore è
  giudicato più debole del livello `executor-power` registrato, il supervisore
  ricalibra le sue unità prima del dispatch. Un agente assegnato non disponibile
  può essere sostituito solo da una posizione uguale o inferiore (agent-1 al
  posto di agent-2, mai il contrario), con la sostituzione registrata;
  altrimenti l'unità diventa un handoff BLOCKED. Revisioni obbligatorie e
  revisioni del piano spettano solo ad agent-1.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; nessuna deadline; fase omessa: intero piano.

### EX-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute 003
```

- **Descrizione:** un solo agente implementa e revisiona tutto.
- **Implicazioni:** il roster del piano diventa quell'agente; ogni revisione,
  incluse le chiusure di fase, è etichettata self-review.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; nessuna deadline; fase omessa: intero piano.

### EX-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

- **Descrizione:** esegue lo scope e prepara l'handoff entro le 17:30.
- **Implicazioni:** controlla l'ora prima di ogni unità, passo e comando lungo,
  non avvia lavoro che finirebbe dopo la scadenza e limita i comandi lunghi con
  `timeout`. Alla scadenza esegue l'handoff (trigger `deadline`): checkpoint,
  commit `handoff(request-by-user): …` anche con i commit disattivati, comando
  di ripresa, stop. Se lo scope finisce prima, termina normalmente. La deadline
  vale solo per questa run: non diventa override dello scope e non passa a
  `resume`. È best effort: può sforare di poco.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; fase omessa: intero piano.

## Execute verify

```text
/plan-execute-verify [<opzioni>] execute verify [<piano>] [V<NNN>]
```

Applica le correzioni del report più recente del piano selezionato o attivo, o
del report `V<NNN>` indicato. Ogni correzione è un'unità `V<NNN>-C<n>`; una
correzione che tocca una fase completata la riapre e ne riesegue la chiusura
`P<N>` con gate completi e revisione del supervisore. Correzioni BLOCKED o
sottospecificate richiedono prima un raffinamento del supervisore. Scope e
opzioni si salvano come in Execute: override dello scope, mai §3. Le correzioni
di un audit su `000_adhoc` non usano questa modalità: diventano richieste Task o
Bug.

### EV-01 · nessuna opzione

```text
/plan-execute-verify execute verify 003
```

- **Descrizione:** applica le correzioni del report più recente del piano 003
  con le impostazioni risolte come in EX-01.
- **Implicazioni:** con i default si ferma dopo la chiusura di ogni fase
  riaperta e non fa commit. Un finding diventa FIXED solo con evidenza; il
  verdetto storico del report non cambia.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline; report omesso: il più
  recente.

### EV-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute verify 003 V002
```

- **Descrizione:** applica tutte le correzioni del report V002.
- **Implicazioni:** commit di ogni correzione completata
  (`correction(V002-C1): …`) e di ogni chiusura di fase riaperta. L'opzione
  resta come override dello scope.
- **Default applicati:** WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline.

### EV-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute verify 003
```

- **Descrizione:** applica le correzioni fermandosi dopo la chiusura di ogni
  fase riaperta.
- **Implicazioni:** nessun commit di completamento da questa opzione; il WIP
  risolto on committa comunque. `resume 003` continua le correzioni rimanenti.
- **Default applicati:** WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; nessuna deadline; report omesso: il più
  recente.

### EV-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute verify 003
```

- **Descrizione:** attiva il WIP per questo scope di correzioni.
- **Implicazioni:** commit di ogni correzione e fase riaperta completate, più il
  WIP a rotazione ai checkpoint; l'autonomia si risolve da override, §3 o
  default.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute verify 003
```

- **Descrizione:** disattiva il WIP per questo scope di correzioni.
- **Implicazioni:** commit di completamento solo se l'autonomia risolta è
  `true`.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute verify 003
```

- **Descrizione:** tutte le correzioni, con il massimo dei commit.
- **Implicazioni:** commit di completamento per correzioni e fasi riaperte, più
  il WIP a rotazione.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute verify 003
```

- **Descrizione:** si ferma dopo ogni fase riaperta, ma committa.
- **Implicazioni:** commit di correzioni e fasi riaperte completate e WIP a
  rotazione.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute verify 003
```

- **Descrizione:** tutte le correzioni, solo commit di completamento.
- **Implicazioni:** il lavoro interrotto resta nel working tree, non in un
  commit.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute verify 003
```

- **Descrizione:** si ferma dopo ogni fase riaperta, senza commit.
- **Implicazioni:** nessun commit automatico; il report suggerisce il comando
  di commit.
- **Default applicati:** livello salvato nel piano; roster del piano; nessuna
  deadline; report omesso: il più recente.

### EV-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessuna correzione applicata. Le correzioni sono già scritte
  da Verify per il livello del piano.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EV-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come EV-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EV-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come EV-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### EV-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute verify 003
```

- **Descrizione:** sostituisce il roster del piano per le correzioni e per le
  esecuzioni successive.
- **Implicazioni:** come EX-13: roster salvato, ricalibrazione se un
  implementatore è più debole del livello registrato, sostituzioni solo verso
  posizioni uguali o inferiori, revisioni solo di agent-1.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; nessuna deadline; report omesso: il più recente.

### EV-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute verify 003
```

- **Descrizione:** un solo agente applica e revisiona le correzioni.
- **Implicazioni:** roster del piano sostituito da quell'agente; ogni revisione
  è self-review.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; nessuna deadline; report omesso: il più recente.

### EV-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute verify 003
```

- **Descrizione:** applica le correzioni e prepara l'handoff entro le 17:30.
- **Implicazioni:** come EX-15; la correzione aperta resta OPEN con il suo
  checkpoint e `resume 003` continua le correzioni.
- **Default applicati:** autonomia dall'override dello scope (stesso selettore),
  poi §3, poi `false`; WIP dall'override dello scope, poi §3, poi off; livello
  salvato nel piano; roster del piano; report omesso: il più recente.

## Task

```text
/plan-execute-verify [<opzioni>] task <descrizione>
```

Un singolo cambiamento piccolo. Non accetta selettori: si collega a un piano
reale solo se la richiesta lo nomina (numero, nome o percorso) o cambia
chiaramente scope, contratti o file di un piano attivo; altrimenti usa
`docs/plans/000_adhoc/tasks.md`. Il mini-piano persistente è calibrato sul
livello del piano collegato (`low` in `000_adhoc`). Opzioni e prefisso valgono
solo per questa invocazione e sono registrati nella voce di ledger; non cambiano
mai §3 né lo scope salvato, e `full-autonomous:true` non autorizza altre fasi
del piano. Una richiesta molto più grande di una piccola unità viene prima
pianificata dal supervisore.

Prima di toccare il codice, agent-1 scrive o valida il mini-piano nella voce di
ledger. Con `full-autonomous:false` (il default) la run si ferma una volta con
la voce `PROPOSED` e ti mostra il mini-piano: puoi modificarlo nel file, poi
approvi rispondendo nella stessa sessione o con `/plan-execute-verify resume
000_adhoc T-A004`. Serve l'ID della voce: un `resume` senza ID non approva mai.
File cambiati nel frattempo o tue modifiche vengono rivalidati da agent-1 prima
del codice; l'approvazione esegue solo quella voce. Per rifiutare la proposta
dillo nella stessa sessione, oppure imposta a mano lo stato della voce a
`WITHDRAWN` con il motivo: la voce non viene mai cancellata né ripresa. La voce
`PROPOSED` non è committata, e il report lo segnala. Con `full-autonomous:true`
non c'è stop, ma la validazione resta: una sessione debole che non raggiunge
agent-1 si blocca prima di scrivere codice. Nessuna combinazione dà un task
senza stop e senza commit di completamento: `false` si ferma, `true` committa.

### TA-01 · nessuna opzione

```text
/plan-execute-verify task aggiungi l'opzione --json al comando export
```

- **Descrizione:** implementa il cambiamento con test nominati e lo chiude con
  evidenze; `--json` resta testo della descrizione.
- **Implicazioni:** collegato a un piano vale il suo §3 (nessun override di
  scope): con `true` in §3 il task viene committato. In `000_adhoc` valgono i
  default: nessun commit, e il report lo segnala suggerendo il comando. Con
  l'autonomia risolta a `false` (default) si ferma per la tua approvazione dopo
  il mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; roster del piano collegato, altrimenti legacy
  Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato: `000_adhoc`, salvo
  che la richiesta cambi chiaramente un piano attivo.

### TA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa il task e lo committa.
- **Implicazioni:** commit locale `task(T-A<NNN>): …` dopo gate e revisioni
  obbligatorie; un gate o una revisione non risolti impediscono il commit.
  L'impostazione è registrata solo nella voce di ledger. Nessuno stop per
  l'approvazione: agent-1 valida il mini-piano e il lavoro prosegue.
- **Default applicati:** WIP dal §3 del piano collegato, altrimenti off; livello
  del piano collegato, `low` in `000_adhoc`; roster del piano collegato,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### TA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa il task senza commit di completamento da questa
  opzione.
- **Implicazioni:** il task è un'unità singola, quindi lo stop a fine fase non
  si applica. Se il WIP risolto è on (dal §3 del piano collegato), il commit
  avviene comunque. Si ferma per la tua approvazione dopo il mini-piano validato
  da agent-1, poi prosegue.
- **Default applicati:** WIP dal §3 del piano collegato, altrimenti off; livello
  del piano collegato, `low` in `000_adhoc`; roster del piano collegato,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### TA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** attiva il WIP per questo task.
- **Implicazioni:** commit del task completato e commit WIP a rotazione a ogni
  checkpoint (handoff, operazioni rischiose, blocchi). Con l'autonomia risolta a
  `false` (default) si ferma per la tua approvazione dopo il mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; livello del piano collegato, `low` in `000_adhoc`; roster del piano
  collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano
  nominato: `000_adhoc`, salvo che la richiesta cambi chiaramente un piano
  attivo.

### TA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** disattiva il WIP per questo task.
- **Implicazioni:** commit di completamento solo se l'autonomia risolta è `true`
  (esplicita o dal §3 del piano collegato). Con l'autonomia risolta a `false`
  (default) si ferma per la tua approvazione dopo il mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; livello del piano collegato, `low` in `000_adhoc`; roster del piano
  collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano
  nominato: `000_adhoc`, salvo che la richiesta cambi chiaramente un piano
  attivo.

### TA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa e committa il task, con WIP ai checkpoint.
- **Implicazioni:** commit di completamento più WIP a rotazione. Nessuno stop
  per l'approvazione: agent-1 valida il mini-piano e il lavoro prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### TA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa il task con commit dovuti al WIP.
- **Implicazioni:** commit del task completato e WIP a rotazione, come TA-06. Si
  ferma per la tua approvazione dopo il mini-piano validato da agent-1, poi
  prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### TA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa il task e lo committa solo alla fine.
- **Implicazioni:** nessun commit WIP; il lavoro interrotto resta nel working
  tree, con l'unità OPEN e il suo checkpoint. Nessuno stop per l'approvazione:
  agent-1 valida il mini-piano e il lavoro prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### TA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit task aggiungi l'opzione --json al comando export
```

- **Descrizione:** completa il task senza alcun commit.
- **Implicazioni:** ignora anche un §3 con commit attivi; il report suggerisce
  il comando di commit. Si ferma per la tua approvazione dopo il mini-piano
  validato da agent-1, poi prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### TA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low task aggiungi l'opzione --json al comando export
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessuna modifica. Il mini-piano segue sempre il livello del
  piano collegato, `low` in `000_adhoc`.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### TA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium task aggiungi l'opzione --json al comando export
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come TA-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### TA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high task aggiungi l'opzione --json al comando export
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come TA-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### TA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku task aggiungi l'opzione --json al comando export
```

- **Descrizione:** assegna gli agenti per questo task.
- **Implicazioni:** il roster vale solo per l'invocazione ed è registrato nella
  voce di ledger; il roster salvato del piano non cambia. Con l'autonomia
  risolta a `false` (default) si ferma per la tua approvazione dopo il
  mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### TA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model task aggiungi l'opzione --json al comando export
```

- **Descrizione:** un solo agente implementa e revisiona il task.
- **Implicazioni:** ogni revisione è self-review; vale solo per questa
  invocazione. Con l'autonomia risolta a `false` (default) si ferma per la tua
  approvazione dopo il mini-piano. La validazione di agent-1 è una self-review
  etichettata.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### TA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 task aggiungi l'opzione --json al comando export
```

- **Descrizione:** esegue il task e prepara l'handoff entro le 17:30.
- **Implicazioni:** se il task non si chiude in tempo, alla scadenza la voce
  resta OPEN con il suo checkpoint, viene creato il commit di handoff anche con
  i commit disattivati e il report propone, per esempio, `/plan-execute-verify
  resume 000_adhoc T-A004`. La deadline non viene registrata come impostazione
  futura. Con l'autonomia risolta a `false` (default) si ferma per la tua
  approvazione dopo il mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; roster del piano collegato, altrimenti legacy
  Opus/Sonnet/Haiku; nessun piano nominato: `000_adhoc`, salvo che la richiesta
  cambi chiaramente un piano attivo.

## Bug

```text
/plan-execute-verify [<opzioni>] bug <descrizione>
```

Un singolo difetto: riproduzione con risultato atteso e reale, causa radice,
test di regressione che prima fallisce, fix, regressione completa pertinente.
Collegamento al piano, mini-piano e opzioni seguono le regole di Task; il
ledger è `bugs.md` e l'identità è `B-A<NNN>`. Se la riproduzione fallisce, il
bug registra tentativi e blocco invece di indovinare un fix.

Lo stop per l'approvazione, quando c'è, arriva dopo riproduzione, causa radice e
mini-piano, prima del test di regressione; agent-1 valida anche la causa radice.
Prima dell'approvazione non viene modificato alcun file tracciato.

### BU-01 · nessuna opzione

```text
/plan-execute-verify bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** riproduce il difetto, scrive il test di regressione, corregge
  e chiude con evidenze.
- **Implicazioni:** collegato a un piano vale il suo §3; in `000_adhoc` valgono
  i default: nessun commit, con avviso e comando suggerito. Con l'autonomia
  risolta a `false` (default) si ferma per la tua approvazione dopo diagnosi e
  mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; roster del piano collegato, altrimenti legacy
  Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato: `000_adhoc`, salvo
  che la richiesta cambi chiaramente un piano attivo.

### BU-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa il fix e lo committa.
- **Implicazioni:** commit locale `bug(B-A<NNN>): …` solo dopo regressione e
  revisioni obbligatorie; registrato solo nella voce di ledger. Nessuno stop per
  l'approvazione: agent-1 valida il mini-piano e il lavoro prosegue.
- **Default applicati:** WIP dal §3 del piano collegato, altrimenti off; livello
  del piano collegato, `low` in `000_adhoc`; roster del piano collegato,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### BU-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa il fix senza commit di completamento da questa
  opzione.
- **Implicazioni:** se il WIP risolto è on (dal §3 del piano collegato), il
  commit avviene comunque. Si ferma per la tua approvazione dopo diagnosi e
  mini-piano validato da agent-1, poi prosegue.
- **Default applicati:** WIP dal §3 del piano collegato, altrimenti off; livello
  del piano collegato, `low` in `000_adhoc`; roster del piano collegato,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### BU-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** attiva il WIP per questo bug.
- **Implicazioni:** commit del fix completato e WIP a rotazione ai checkpoint.
  Con l'autonomia risolta a `false` (default) si ferma per la tua approvazione
  dopo diagnosi e mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; livello del piano collegato, `low` in `000_adhoc`; roster del piano
  collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano
  nominato: `000_adhoc`, salvo che la richiesta cambi chiaramente un piano
  attivo.

### BU-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** disattiva il WIP per questo bug.
- **Implicazioni:** commit di completamento solo se l'autonomia risolta è
  `true`. Con l'autonomia risolta a `false` (default) si ferma per la tua
  approvazione dopo diagnosi e mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; livello del piano collegato, `low` in `000_adhoc`; roster del piano
  collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; nessun piano
  nominato: `000_adhoc`, salvo che la richiesta cambi chiaramente un piano
  attivo.

### BU-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa e committa il fix, con WIP ai checkpoint.
- **Implicazioni:** commit di completamento più WIP a rotazione. Nessuno stop
  per l'approvazione: agent-1 valida il mini-piano e il lavoro prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### BU-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa il fix con commit dovuti al WIP.
- **Implicazioni:** come BU-06. Si ferma per la tua approvazione dopo diagnosi e
  mini-piano validato da agent-1, poi prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### BU-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa il fix e lo committa solo alla fine.
- **Implicazioni:** il lavoro interrotto resta nel working tree, con l'unità
  OPEN e il suo checkpoint. Nessuno stop per l'approvazione: agent-1 valida il
  mini-piano e il lavoro prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### BU-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** completa il fix senza alcun commit.
- **Implicazioni:** ignora anche un §3 con commit attivi; il report suggerisce
  il comando di commit. Si ferma per la tua approvazione dopo diagnosi e
  mini-piano validato da agent-1, poi prosegue.
- **Default applicati:** livello del piano collegato, `low` in `000_adhoc`;
  roster del piano collegato, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; nessun piano nominato: `000_adhoc`, salvo che la richiesta cambi
  chiaramente un piano attivo.

### BU-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessuna modifica. Il mini-piano segue il livello del piano
  collegato, `low` in `000_adhoc`.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### BU-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come BU-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### BU-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come BU-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### BU-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** assegna gli agenti per questo bug.
- **Implicazioni:** solo per l'invocazione, registrato nella voce di ledger; il
  roster del piano non cambia. Con l'autonomia risolta a `false` (default) si
  ferma per la tua approvazione dopo diagnosi e mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### BU-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** un solo agente riproduce, corregge e revisiona.
- **Implicazioni:** ogni revisione è self-review; vale solo per questa
  invocazione. Con l'autonomia risolta a `false` (default) si ferma per la tua
  approvazione dopo diagnosi e mini-piano. La validazione di agent-1 è una
  self-review etichettata.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; nessuna deadline; nessun piano nominato:
  `000_adhoc`, salvo che la richiesta cambi chiaramente un piano attivo.

### BU-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 bug export termina con codice 0 se manca la configurazione
```

- **Descrizione:** corregge il bug e prepara l'handoff entro le 17:30.
- **Implicazioni:** come TA-15; la ripresa proposta è del tipo
  `/plan-execute-verify resume 000_adhoc B-A002`. Con l'autonomia risolta a
  `false` (default) si ferma per la tua approvazione dopo diagnosi e mini-piano.
- **Default applicati:** autonomia dal §3 del piano collegato, altrimenti
  `false`; WIP dal §3 del piano collegato, altrimenti off; livello del piano
  collegato, `low` in `000_adhoc`; roster del piano collegato, altrimenti legacy
  Opus/Sonnet/Haiku; nessun piano nominato: `000_adhoc`, salvo che la richiesta
  cambi chiaramente un piano attivo.

## Verify

```text
/plan-execute-verify [<opzioni>] verify [<piano>] [<fase, sotto-fase o voce>]
```

Audit basato su evidenze: scrive il report in `verify/`, il registro dei
finding, le righe di correzione in STATE.md §11 e correzioni di stato
veritiere. Non modifica mai codice di produzione e non applica fix, nemmeno in
autonomia. Selettori: piano, `phase_02`, `1.2`, `§ 1.2`, una voce `T-A<NNN>` o
`B-A<NNN>`, `000_adhoc` da solo o con una voce. Opzioni e prefisso valgono solo
per questo audit e sono registrati nel report. Il verdetto è PASS, PASS WITH
FINDINGS, FAIL o INCOMPLETE. Le correzioni sono scritte per il livello
`executor-power` del piano; in `000_adhoc` diventano comandi Task o Bug pronti.

### VE-01 · nessuna opzione

```text
/plan-execute-verify verify 003
```

- **Descrizione:** verifica l'intero piano 003 e salva il report.
- **Implicazioni:** l'autonomia si risolve da §3 o dal default: con `true` in §3
  l'audit committa i propri artefatti, altrimenti nessun commit. Il report
  indica il comando per applicare le correzioni, che non partono mai da sole.
- **Default applicati:** autonomia da §3, altrimenti `false`; WIP irrilevante
  per l'audit; livello del piano per le correzioni; roster del piano, altrimenti
  legacy Opus/Sonnet/Haiku; nessuna deadline; fase o voce omessa: intero piano.

### VE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true verify 003 phase_02
```

- **Descrizione:** verifica la fase logica 1 e committa l'audit.
- **Implicazioni:** commit solo degli artefatti di audit e di stato, con il
  verdetto nel soggetto, per esempio
  `verify(V001): complete audit; FAIL, 1 blocker`. Anche un FAIL viene
  committato: registra un'ispezione conclusa, non un'implementazione
  verificata. Modifiche di produzione non committate non vengono mai incluse.
- **Default applicati:** WIP irrilevante per l'audit; livello del piano per le
  correzioni; roster del piano, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline.

### VE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false verify 003
```

- **Descrizione:** audit senza commit.
- **Implicazioni:** nessun commit anche se §3 ha `true`; report e stato restano
  da committare a mano.
- **Default applicati:** WIP irrilevante per l'audit; livello del piano per le
  correzioni; roster del piano, altrimenti legacy Opus/Sonnet/Haiku; nessuna
  deadline; fase o voce omessa: intero piano.

### VE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit verify 003
```

- **Descrizione:** opzione accettata, senza effetto sui commit dell'audit.
- **Implicazioni:** il solo WIP non committa mai un audit; i commit dipendono
  solo dall'autonomia risolta. Il valore è registrato nel report.
- **Default applicati:** autonomia da §3, altrimenti `false`; livello del piano
  per le correzioni; roster del piano, altrimenti legacy Opus/Sonnet/Haiku;
  nessuna deadline; fase o voce omessa: intero piano.

### VE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit verify 003
```

- **Descrizione:** opzione accettata, senza effetto sull'audit.
- **Implicazioni:** come VE-04; un §3 con `true` fa comunque committare
  l'audit.
- **Default applicati:** autonomia da §3, altrimenti `false`; livello del piano
  per le correzioni; roster del piano, altrimenti legacy Opus/Sonnet/Haiku;
  nessuna deadline; fase o voce omessa: intero piano.

### VE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit verify 003
```

- **Descrizione:** audit con commit degli artefatti.
- **Implicazioni:** come VE-02; il WIP non aggiunge commit.
- **Default applicati:** livello del piano per le correzioni; roster del piano,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; fase o voce omessa:
  intero piano.

### VE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit verify 003
```

- **Descrizione:** audit senza commit.
- **Implicazioni:** come VE-03; il WIP non committa audit.
- **Default applicati:** livello del piano per le correzioni; roster del piano,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; fase o voce omessa:
  intero piano.

### VE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit verify 003
```

- **Descrizione:** audit con commit degli artefatti.
- **Implicazioni:** come VE-02.
- **Default applicati:** livello del piano per le correzioni; roster del piano,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; fase o voce omessa:
  intero piano.

### VE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit verify 003
```

- **Descrizione:** audit senza commit.
- **Implicazioni:** come VE-03.
- **Default applicati:** livello del piano per le correzioni; roster del piano,
  altrimenti legacy Opus/Sonnet/Haiku; nessuna deadline; fase o voce omessa:
  intero piano.

### VE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessun audit. Le correzioni seguono sempre il livello del
  piano.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### VE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come VE-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### VE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high verify 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come VE-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### VE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku verify 003
```

- **Descrizione:** assegna gli agenti per questo audit.
- **Implicazioni:** solo per questo audit, registrato nel report; il roster
  salvato del piano non cambia.
- **Default applicati:** autonomia da §3, altrimenti `false`; WIP irrilevante
  per l'audit; livello del piano per le correzioni; nessuna deadline; fase o
  voce omessa: intero piano.

### VE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model verify 000_adhoc B-A002
```

- **Descrizione:** un solo agente verifica la voce di ledger B-A002.
- **Implicazioni:** ogni revisione è self-review; vale solo per questo audit.
  Le correzioni risultanti diventano comandi Task o Bug pronti.
- **Default applicati:** autonomia `false`, perché `000_adhoc` non ha §3; WIP
  irrilevante per l'audit; correzioni come comandi Task o Bug a livello `low`;
  nessuna deadline.

### VE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 verify 003
```

- **Descrizione:** esegue l'audit e lo sospende entro le 17:30 se non finisce
  prima.
- **Implicazioni:** alla scadenza l'audit resta OPEN con il suo checkpoint nel
  report e nell'indice; nessun commit, con avviso e comando suggerito. La
  ripresa proposta è del tipo `/plan-execute-verify resume 003 V002`.
- **Default applicati:** autonomia da §3, altrimenti `false`; WIP irrilevante
  per l'audit; livello del piano per le correzioni; roster del piano, altrimenti
  legacy Opus/Sonnet/Haiku; fase o voce omessa: intero piano.

## Resume

```text
/plan-execute-verify [<opzioni>] resume [<piano>] [<id-unità>]
```

Recupera prima il lavoro registrato, in quest'ordine: audit aperto o commit di
audit pendente, transazione di completamento pendente, unità OPEN nella sua
modalità, implementazione sospesa, bozza di piano DRAFT. Poi, senza ID unità,
continua lo scope di esecuzione salvato (NOT_STARTED, RUNNING o BLOCKED) come
farebbe Execute. Con un ID unità (`N.M`, `P<N>`, `V<NNN>`, `V<NNN>-C<n>`,
`T-A<NNN>`, `B-A<NNN>`) si ferma dopo il recupero e la chiusura di quell'unità;
su `000_adhoc` si ferma dopo la voce recuperata. Non avvia mai un'unità TODO,
non allarga lo scope e non riscrive impostazioni o roster salvati. L'unità
ripresa usa impostazioni e roster registrati su di essa; lo scope continuato usa
i suoi override, poi §3. Opzioni e prefisso espliciti prevalgono su entrambi
solo per questa invocazione, e i commit seguono la modalità del lavoro ripreso.
Una voce task o bug `PROPOSED` si riprende solo nominandone l'ID, per esempio
`resume 000_adhoc T-A004`, e così la approvi; senza ID non viene mai toccata, ma
il report la elenca con il comando di approvazione.

### RE-01 · nessuna opzione

```text
/plan-execute-verify resume 003
```

- **Descrizione:** recupera il lavoro interrotto del piano 003 e continua lo
  scope salvato.
- **Implicazioni:** valgono le impostazioni registrate. Un'unità BLOCKED
  riprende solo se il blocco è risolto, altrimenti il report indica blocco,
  responsabile e domanda. Se non resta nulla da riprendere, il report indica la
  prossima unità eleggibile e il comando per avviarla, senza avviarla.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; WIP con la stessa catena, default
  off; livello del piano; roster registrato sull'unità ripresa, altrimenti del
  piano; nessuna deadline; ID unità omesso: recupero, poi continuazione dello
  scope salvato.

### RE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true resume 003
```

- **Descrizione:** recupera e continua lo scope in autonomia, solo per questa
  invocazione.
- **Implicazioni:** unità ripresa e scope continuato procedono senza stop di
  fase e committano secondo la loro modalità (un audit ripreso committa solo i
  propri artefatti). Gli override salvati non cambiano: un `resume` successivo
  senza opzioni torna alle impostazioni registrate. Con `resume 003 1.2` si
  ferma comunque dopo l'unità 1.2.
- **Default applicati:** WIP con la stessa catena, default off; livello del
  piano; roster registrato sull'unità ripresa, altrimenti del piano; nessuna
  deadline; ID unità omesso: recupero, poi continuazione dello scope salvato.

### RE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false resume 003
```

- **Descrizione:** recupera e continua fermandosi dopo la prossima chiusura di
  fase, solo per questa invocazione.
- **Implicazioni:** nessun commit di completamento da questa opzione; il WIP
  risolto on committa comunque. Le impostazioni salvate non cambiano.
- **Default applicati:** WIP con la stessa catena, default off; livello del
  piano; roster registrato sull'unità ripresa, altrimenti del piano; nessuna
  deadline; ID unità omesso: recupero, poi continuazione dello scope salvato.

### RE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit resume 003
```

- **Descrizione:** attiva il WIP solo per questa invocazione.
- **Implicazioni:** commit delle unità completate e WIP a rotazione ai
  checkpoint; nessun effetto su un audit ripreso. L'override salvato dello scope
  non cambia.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; livello del piano; roster registrato
  sull'unità ripresa, altrimenti del piano; nessuna deadline; ID unità omesso:
  recupero, poi continuazione dello scope salvato.

### RE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit resume 003
```

- **Descrizione:** disattiva il WIP solo per questa invocazione.
- **Implicazioni:** commit di completamento solo se l'autonomia risolta per
  questa run è `true`.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; livello del piano; roster registrato
  sull'unità ripresa, altrimenti del piano; nessuna deadline; ID unità omesso:
  recupero, poi continuazione dello scope salvato.

### RE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit resume 003
```

- **Descrizione:** recupera e continua in autonomia con WIP, solo per questa
  invocazione.
- **Implicazioni:** commit di completamento più WIP a rotazione; gli override
  salvati restano invariati.
- **Default applicati:** livello del piano; roster registrato sull'unità
  ripresa, altrimenti del piano; nessuna deadline; ID unità omesso: recupero,
  poi continuazione dello scope salvato.

### RE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit resume 003
```

- **Descrizione:** recupera e continua fino alla prossima chiusura di fase, con
  WIP, solo per questa invocazione.
- **Implicazioni:** commit di unità e fasi completate e WIP a rotazione.
- **Default applicati:** livello del piano; roster registrato sull'unità
  ripresa, altrimenti del piano; nessuna deadline; ID unità omesso: recupero,
  poi continuazione dello scope salvato.

### RE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit resume 003
```

- **Descrizione:** recupera e continua in autonomia senza WIP, solo per questa
  invocazione.
- **Implicazioni:** solo commit di completamento; il lavoro interrotto resta nel
  working tree.
- **Default applicati:** livello del piano; roster registrato sull'unità
  ripresa, altrimenti del piano; nessuna deadline; ID unità omesso: recupero,
  poi continuazione dello scope salvato.

### RE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit resume 000_adhoc B-A002
```

- **Descrizione:** riprende la voce di ledger B-A002 senza commit e si ferma
  dopo di essa.
- **Implicazioni:** nessun commit, anche se la voce aveva registrato commit
  attivi; la volta successiva valgono di nuovo le impostazioni registrate.
- **Default applicati:** livello `low` in `000_adhoc`; roster registrato nella
  voce di ledger B-A002; nessuna deadline.

### RE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low resume 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** nessun recupero. Resume non cambia mai il livello del
  piano.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### RE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium resume 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come RE-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### RE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high resume 003
```

- **Descrizione:** rifiutato: `executor-power` è solo di Plan.
- **Implicazioni:** come RE-10.
- **Default applicati:** nessuno: l'invocazione viene rifiutata prima di
  risolvere le impostazioni.

### RE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

- **Descrizione:** usa questo roster per il recupero e la continuazione, solo
  per questa invocazione.
- **Implicazioni:** registrato con l'invocazione; il roster salvato del piano e
  quello registrato sull'unità ripresa non cambiano.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; WIP con la stessa catena, default
  off; livello del piano; nessuna deadline; ID unità omesso: recupero, poi
  continuazione dello scope salvato.

### RE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model resume 003
```

- **Descrizione:** un solo agente recupera e continua, solo per questa
  invocazione.
- **Implicazioni:** ogni revisione è self-review; nessuna assegnazione salvata
  cambia.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; WIP con la stessa catena, default
  off; livello del piano; nessuna deadline; ID unità omesso: recupero, poi
  continuazione dello scope salvato.

### RE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 resume 003
```

- **Descrizione:** recupera e continua il lavoro, con handoff entro le 17:30.
- **Implicazioni:** come EX-15 per il lavoro ripreso; la deadline vale solo per
  questa invocazione e un `resume` successivo non la eredita.
- **Default applicati:** autonomia registrata sull'unità ripresa; per lo scope
  continuato override, poi §3, poi `false`; WIP con la stessa catena, default
  off; livello del piano; roster registrato sull'unità ripresa, altrimenti del
  piano; ID unità omesso: recupero, poi continuazione dello scope salvato.

## Handoff

```text
/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]
/plan-execute-verify --deadline=dd-mm-yyyy_hh_mm handoff
```

Ferma il lavoro in corso il prima possibile, o entro la deadline (ora locale
della macchina che esegue l'agente; una deadline passata vale "subito"). Di
solito si invia durante una run. L'agente non avvia nulla di nuovo, chiude
l'unità aperta solo se servono circa 10 minuti (controlli e revisione inclusi),
altrimenti si ferma al prossimo confine di passo e registra i comandi non
eseguiti. Poi salva il checkpoint con l'azione successiva esatta, segna la run
`HANDOFF`, rilascia l'ownership, crea il commit di handoff per il lavoro sul
codice, propone il comando di ripresa e si ferma, anche con
`full-autonomous:true`. Il commit `handoff(request-by-user): …` contiene l'unità
aperta e ogni unità chiusa ancora non committata, ciascuna messa in stage con
una patch separata, così le modifiche fatte tra un'unità e l'altra restano
fuori; non viene mai amendato e lascia attivi gli hook. Una richiesta di stop
non viene mai rifiutata: opzioni, prefisso e selettori inutili sono ignorati e
segnalati.

È best effort: l'agente vede il messaggio solo tra una chiamata di tool e
l'altra, non interrompe un proprio comando già in corso, e una sessione inattiva
non si risveglia alla deadline. Imposta la deadline prima del momento reale:
spegni il PC alle 18:00, usa `--deadline=31-10-2026_17_30`.

| Lavoro interrotto | Cosa resta | Commit | Comando di ripresa proposto |
|-------------------|------------|--------|-----------------------------|
| Execute, Execute verify | Unità OPEN con checkpoint; scope RUNNING | Handoff | `/plan-execute-verify resume 003` |
| Task, Bug su un piano | Unità OPEN in STATE.md, voce di ledger collegata | Handoff | `/plan-execute-verify resume 003 T-A004` |
| Task, Bug in `000_adhoc` | Voce di ledger OPEN con checkpoint | Handoff | `/plan-execute-verify resume 000_adhoc B-A002` |
| Verify | Audit OPEN con checkpoint | Nessuno, con avviso | `/plan-execute-verify resume 003 V002` |
| Plan | Checkpoint della bozza DRAFT | Nessuno, con avviso | `/plan-execute-verify resume 004` |
| Onboard | Nulla di nuovo | Nessuno | `/plan-execute-verify onboard` |
| Resume | Come la modalità del lavoro ripreso | Come quella modalità | Come quella modalità |
| Stile delegato | Il coordinatore smette di distribuire, attende o ferma i worker e riconcilia il loro diff | Come sopra | Come sopra |
| Sessione inattiva | Checkpoint e commit del lavoro non committato del piano o ledger scritto per ultimo; se non c'è nulla, lo dice | Handoff, se c'è lavoro sul codice | Come sopra |

### HA-01 · nessuna opzione

```text
/plan-execute-verify handoff
```

- **Descrizione:** ferma la run in corso il prima possibile.
- **Implicazioni:** unità aperta chiusa solo se bastano circa 10 minuti,
  altrimenti stop al prossimo confine di passo; checkpoint, run `HANDOFF`,
  ownership rilasciata; commit `handoff(request-by-user): …` per il lavoro sul
  codice anche con i commit disattivati; comando di ripresa; stop. Annulla una
  deadline data in precedenza.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** il commit di handoff per il lavoro sul codice avviene
  comunque, qualunque sia il valore; nessuna impostazione salvata cambia.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02: la coppia è ignorata e il commit di handoff
  avviene comunque.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02: la coppia è ignorata e il commit di handoff
  avviene comunque.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02: la coppia è ignorata e il commit di handoff
  avviene comunque.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-02: la coppia è ignorata e il commit di handoff
  avviene comunque.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** il livello `executor-power` del piano non cambia.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-10.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high handoff
```

- **Descrizione:** opzione ignorata e segnalata; l'handoff parte subito.
- **Implicazioni:** come HA-10.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku handoff
```

- **Descrizione:** prefisso ignorato e segnalato; l'handoff parte subito.
- **Implicazioni:** il roster salvato e quello registrato sull'unità non
  cambiano; l'handoff lo esegue la sessione che sta lavorando.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model handoff
```

- **Descrizione:** prefisso ignorato e segnalato; l'handoff parte subito.
- **Implicazioni:** come HA-13.
- **Default applicati:** senza deadline, handoff immediato; target: la run in
  corso, o da sessione inattiva il piano o ledger scritto per ultimo.

### HA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 handoff
```

- **Descrizione:** la run in corso continua e fa l'handoff entro le 17:30; le
  due forme sono equivalenti.
- **Implicazioni:** sostituisce una deadline precedente. Alla scadenza esegue la
  stessa procedura di HA-01 con trigger `deadline`. Una deadline passata, non
  valida o in conflitto con un'altra vale come handoff immediato; anche su una
  sessione inattiva l'handoff è immediato.
- **Default applicati:** target: la run in corso, o da sessione inattiva il
  piano o ledger scritto per ultimo.

## Combinazioni

La coppia autonomia/WIP, `executor-power` e il prefisso agenti si combinano
liberamente, nell'ordine che preferisci prima della modalità; gli effetti si
sommano caso per caso.

```text
/plan-execute-verify full-autonomous:true --wip-commit executor-power:medium agent-1:opus,agent-2:sonnet plan aggiungi esportazione CSV
```

PL-06 + PL-11 + PL-13: §3 salva autonomia on, WIP on, livello `medium` e il
roster.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet full-autonomous:true --no-wip-commit execute 003 phase_02
```

EX-08 + EX-13, limitati alla fase logica 1 (`phase_02.md`), inclusa la sua
chiusura `P1`.

```text
/plan-execute-verify agent:my-model full-autonomous:false --no-wip-commit task correggi il messaggio di errore del login
```

TA-09 + TA-14: un solo agente, nessun commit, nulla salvato nel piano.

```text
/plan-execute-verify full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

RE-02 + RE-13: tutto vale solo per questa invocazione.

```text
/plan-execute-verify --deadline=31-10-2026_17_30 full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

EX-15 + EX-02 + EX-13: tutto lo scope in autonomia con il roster sostituito, e
handoff entro le 17:30.
