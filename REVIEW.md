# REVIEW — plan-execute-verify (analisi statica, 2026-11-07)

Revisione completa della skill al commit `44211df` (branch `claude`).
Solo analisi: nessun file della skill è stato modificato. Ogni punto riporta
file e riga, l'evidenza e una proposta di correzione; la decisione su cosa
sistemare resta da prendere insieme.

## 1. Ambito e metodo

Letti per intero: `SKILL.md`, tutti i `references/*.md` (19 file),
`README.md`, `install-claude.sh`; letti a campione `README_IT.md`,
`USAGE_EXAMPLE.md`, `USAGE_EXAMPLE_IT.md` (sezioni iniziali, matrice
riassuntiva, casi EX-03, EX-10, ON-10, TA-03, VE-01, VE-03, EV-01, RE-01,
RE-03, RE-09, HA-01, HA-15, "Combining options").

Controlli meccanici eseguiti (tutti superati salvo dove indicato):

| Controllo | Esito |
|-----------|-------|
| Link relativi in tutti i `.md` | OK (gli unici due "mancanti" sono `STATE.md` e `phase_01.md` dentro il template di overview.md: falsi positivi) |
| Parità README EN/IT: intestazioni, righe di tabella, blocchi di codice | 21/21 · 48/48 · 38/38 |
| Parità USAGE_EXAMPLE EN/IT: intestazioni, casi `###`, comandi `/plan-execute-verify` nei blocchi | 154/154 · 135/135 · 150/150, stessi comandi (differiscono solo le descrizioni tradotte) |
| Snippet awk di execution-contract §6 passo 4 (match esatto `1.2` vs `1.20`) | OK su gawk 5.2.1: 1 match atteso, 1 ottenuto |
| Raggiungibilità dei reference da SKILL.md o dai manuali di modo | OK; `worked-example.md` è linkato solo dal README (voluto) |
| Confronto template STATE.md formato 1 (commit `240a6f5`) e formato 2 (HEAD) | Vedi finding 2 |
| `git diff --check`, struttura della skill | Non rieseguiti (già dichiarati nel README) |

L'URL di installazione `https://github.com/manprint/plan-execute-analyze.git`
coincide con il remote `origin` di questo repository (`git remote -v`): il
nome del repo differisce dal nome della skill, ma l'indirizzo è corretto.

## 2. Finding con conseguenze operative (alta priorità)

### F1 — Il valore di `PEV-Plan` non è definito in modo univoco

- `references/execution-contract.md:441` — "Use a stable identity: plan folder
  ID (or `000_adhoc`)"; `:449` — trailer `PEV-Plan: <plan-id>`.
- `references/execution-contract.md:456-457` — nei subject `<plan>` è "the
  folder number (`003`, or `000_adhoc`)".
- `references/output-template.md:207` — intestazione STATE `Plan <NNN>`.
- `references/worked-example.md:219` — `PEV-Plan: 003_plan-RateLimit`
  (nome completo della cartella).

Conseguenza: il passo 4 di §6 risolve il commit di chiusura con un confronto di
stringa esatto su tutti e quattro i trailer. Se una sessione scrive `003` e la
successiva cerca `003_plan-RateLimit` (o viceversa), zero match viene letto
come "closure pending" e si produce un commit duplicato; lo stesso vale per il
lookup `PEV-Includes` dell'handoff. È il punto più rischioso trovato.

Proposta: fissare una forma canonica (consiglio il solo numero `003`, coerente
con subject e intestazione STATE; `000_adhoc` resta tale) e dichiararla in
§6 accanto al blocco trailer; allineare worked-example.md:219 e il PROTOCOL.md
(output-template.md §4 punto 7). Nessun cambio di formato STATE. Serve anche
un fallback: `SKILL.md:112` ammette un percorso esplicito dell'utente, quindi
un piano può vivere in una cartella senza prefisso `<NNN>`; per quel caso il
numero non esiste e né `PEV-Plan` né `<plan>` nei subject sono definiti.
Opzioni: usare il basename della cartella, oppure esigere comunque il prefisso
numerico anche su percorso esplicito.

### F2 — La migrazione 1→2 è sottospecificata rispetto al vero formato 1

- `references/execution-contract.md:685` — la riga di migrazione elenca:
  spostare §0 in PROTOCOL.md, creare history.md, aggiungere i campi §1
  `acting as`, `Stop latch: none`, `Last closure`, aggiungere la riga PLAN.
- Il vero formato 1 (template in `240a6f5:references/output-template.md`) ha
  §1 "Current unit and scope" come elenco di 13 campi con nomi diversi
  (Saved execution scope, Invocation, Type, ID / attempt, Status, Intent,
  Assigned, File / unit heading, Current step, Next action, Next eligible
  plan unit, Unit base, Repo state), §2 "Feature context and readiness" con
  prosa su goal/decisioni/ricerca, §3 con campi "Full autonomous (plan
  default)" ecc. La migrazione non dice come mappare questi campi nel layout
  compatto né dove finisce il contenuto di §2 (history.md? scartato?).
- I file STATE.md scritti dalle versioni intermedie (`273c72f`, `d6bee7b`)
  hanno già il layout snello ma nessuna riga `Format:`; per
  `execution-contract.md:672-673` sono formato 1 e la migrazione viene
  applicata di nuovo. La riga non è dichiarata idempotente ("se assente").

Punto a favore: i numeri di sezione 1–12 sono rimasti gli stessi tra i due
layout, quindi la mappatura è fattibile.

Il contenuto corretto della riga sarebbe: "riscrivi §1 e §3 nel layout del
formato 2 mappando i campi (tabella), sposta §2 goal/decisioni in history.md
(o in overview.md se mancante), applica ogni passo solo se assente".

Il problema è dove metterlo. La convenzione del progetto (`CLAUDE.md` e
`execution-contract.md:689-690`) vieta di modificare una riga di migrazione
già scritta. Ma una riga 2→3 di "normalizzazione" non ripara una 1→2
difettosa: le migrazioni si applicano in ordine, quindi su un vero STATE
formato 1 la 1→2 incompleta gira comunque prima della 2→3, e il contenuto
perso (vecchio §2) non è più recuperabile. La scelta è quindi tra:

- rompere la convenzione una volta, ora, modificando la riga 1→2 (difendibile:
  il formato 2 ha tre commit di vita, `31b17bf`, e difficilmente esistono
  STATE reali già migrati con la riga attuale);
- lasciare la riga com'è e accettare che i piani formato 1 autentici vadano
  migrati a mano, documentandolo nei README.

La decisione spetta a te; segnalo solo che l'opzione "formato 3" da sola non
risolve il caso.

### F3 — `execute verify` sostituisce lo scope RUNNING del piano; `verify` (V6) no

- `references/invocation.md:159-163` e `execution-contract.md:85-89` —
  un selettore Execute/Execute verify diverso sostituisce lo scope salvato;
  con `true` lo fa come decisione autonoma.
- `references/mode-verify.md:179-180` — il pass V6 applica le stesse
  correzioni "The saved execution scope stays unchanged".
- `USAGE_EXAMPLE.md`, matrice: "EV-01 replaces running scope" accanto a
  "VE-01 … saved execution scope not change".

Conseguenza: lo stesso lavoro (le correzioni di V001) ha effetti collaterali
diversi a seconda del comando. Con il comando esplicito gli override dello
scope del piano vanno persi e, finite le correzioni, next-step riga 14 impone
un "new scope" (`execute 003` che riparte dai default di §3) invece di
`resume 003`. Sotto il default `true` la sostituzione avviene senza domanda.

Proposta (scelta di design, da decidere): far girare `execute verify` come
invocazione propria senza toccare uno scope RUNNING/BLOCKED (come V6), oppure
salvare lo scope sostituito e ripristinarlo a correzioni concluse. In ogni
caso allineare invocation.md, execution-contract §1, mode-execute E2/E5,
PROTOCOL.md punto 1, README/README_IT e i casi EV-xx di USAGE_EXAMPLE.

## 3. Incongruenze tra file (media priorità)

### F4 — Approvazione Task/Bug: "solo quella voce" vs Resume con `true`

- `references/mode-taskbug.md:67-68` — "Approving handles only that entry:
  other recoverable work is reported with its resume command, not run"
  (senza qualificatore di autonomia).
- `references/mode-resume.md:49-51` — con `false` solo quella voce; con
  `true` "items 1–5 are recovered first, in order"; `:77-80` — in
  `000_adhoc` con `true` si recuperano poi tutte le altre voci.

Proposta: in mode-taskbug.md aggiungere "with `false`"; quality-checklist
Coherence (:116-121) è già allineata a mode-resume.

### F5 — §2 passo 3 con `true` non esclude Verify dalla "chiusura preventiva"

- `references/execution-contract.md:128-133` — con `false` "only Verify has
  the suspension exception"; con `true` "recover and close it first … then
  start the requested work" vale per "a new explicit scope", Verify compreso
  a lettura letterale.
- `references/mode-verify.md:31-36` e `:182-183` — Verify sospende in §12
  sotto entrambe le impostazioni e chiude l'unità sospesa solo a V6.

Proposta: in §2 passo 3 precisare "Verify suspends instead (§12) under either
setting".

### F6 — Audit in `000_adhoc`: il checkpoint dell'audit aperto non ha posto

- `references/mode-verify.md:22-24` — "its verify/index.md records the open
  audit and its checkpoint".
- `references/templates-audit.md:105-124` — il template di verify/index.md ha
  solo Historical reports, Findings, Open blockers: nessuna sezione per audit
  aperto, checkpoint, owner o stop latch.
- `README.md:711-712` — per `000_adhoc` "keeps its recovery information in
  the ledger entry itself"; la cartella `000_adhoc/verify/` non è mai citata.

Proposta: aggiungere a verify/index.md una sezione "Open audit" (report,
unit/attempt, owner, checkpoint, settings, stop reason) e citare
`000_adhoc/verify/` in "Files you will see" di entrambi i README.

### F7 — `full-autonomous:false` in coda a `task`/`bug` è testo letterale

- `references/invocation.md:24-31` — la forma "ultimo token" vale solo per i
  modi senza testo libero; `:10-13` — con autonomia risolta `true` "any other
  such token stays literal text".
- Effetto: `task fix X full-autonomous:false` gira in piena autonomia e
  committa; il report lo dice, ma a cose fatte. README.md:100-104 lo documenta.

Proposta (UX): accettare `full-autonomous:true|false` anche come ultimo token
di `task`/`bug` (è l'unico token che non può essere parte di una descrizione
sensata), oppure rifiutare il comando quando l'ultimo token ha esattamente
quella forma.

### F8 — Contenuto del commit di handoff: history.md e voci PROPOSED

- `references/mode-handoff.md:171-174` — contenuto: modifiche delle unità,
  "STATE.md and the ledgers whole"; history.md non è elencato.
- `references/output-template.md:382-384` (PROTOCOL punto 10) e
  `execution-contract.md:667-668` — history.md entra nel commit.
- `references/next-step.md:93-94` — "A handoff never commits a PROPOSED
  entry", ma un ledger committato "whole" può contenere una voce PROPOSED
  accanto a quella OPEN.

Proposta: aggiungere history.md in H5; riformulare N2 in "never commits a
PROPOSED entry on its own" (o escludere la voce dal patch del ledger).

### F9 — Record `PROPOSED` in §1 scritto senza ownership né migrazioni

- `references/mode-taskbug.md:53-56` — prima dell'approvazione si scrive il
  record §1 con risultato `PROPOSED` nello STATE.md di un piano reale, ma "No
  unit is opened and no ownership is claimed".
- `references/execution-contract.md:93` — un solo state writer;
  `:673-676` — le migrazioni si applicano "in the same state update that
  claims ownership".
- Non è detto cosa accade se un'altra sessione ha `ownership: active`
  (scrittura concorrente) né se lo STATE è di formato 1 (si scrive un campo
  del formato 2 in un file non migrato).

Proposta: la scrittura PROPOSED richiede che nessun altro writer sia attivo
(altrimenti conflitto, next-step riga 4) e, se serve, viene preceduta dalla
migrazione con una claim/release immediata; oppure il record resta solo nel
ledger finché non si apre l'unità.

### F10 — Riespansione di una fase collassata e momento di espansione

- `references/execution-contract.md:652-655` — a P<N> DONE la fase collassa
  in una riga e perde righe sub-fase, test, documentazione.
- `references/mode-execute.md:138-141` — una correzione "reopens" una fase
  completata; history.md "is never read to resume" (`:667`).
- Non è scritto come riappare la fase in §11 (quali righe, da dove si
  prendono stati e attempt delle sub-fasi), né quando si espande la fase
  successiva (mode-plan.md:232-233 espande la prima al planning; §8 dice
  "expands only open phases").

Proposta: una frase in §8: "a reopened phase re-expands from its phase file
with every sub-phase DONE (closure refs from Git trailers), plus its
correction rows; the next phase expands when its first unit opens".

### F11 — Stop con `false` dopo l'ultima P<N>: PLAN gira comunque

- `references/execution-contract.md:44-47` — con `false` "stops after that
  phase's closure P<N>".
- `:289-292` e `mode-execute.md:113-116` — PLAN "runs right after it, without
  a phase-closure stop".

Proposta: in §1 aggiungere "(after the last P<N>, the PLAN closure runs first)".

### F12 — Lavoro non committato: "suggerisci il comando commit" vs "suggerisci handoff"

- `references/mode-execute.md:153-156` e `execution-contract.md:487-489` —
  con commit disabilitati suggerire "the exact commit command".
- `references/next-step.md:82-88` — la riga Stop suggerisce `handoff`, che
  stage una patch per unità e tiene fuori le modifiche dell'utente.
- Un `git commit` semplice dopo più unità non committate con modifiche
  interposte dell'utente committa hunk misti, vietato da §6 passo 2.

Proposta: E6 e §6 rimandano a N2: il comando commit si suggerisce solo per
file che un handoff non commetterebbe (bozza di piano, audit, voce PROPOSED,
docs/onboarding.md).

## 4. Punti minori e refusi (bassa priorità)

| # | Dove | Problema | Proposta |
|---|------|----------|----------|
| F13 | `references/worked-example.md:54` vs `:188` | La sub-fase 0.1 ha `Agent: agent-3`, la riga di board dice `agent-2` | Allineare (agent-3) |
| F14 | `references/next-step.md:82-88`, `SKILL.md:78-79` | "ownership this session still holds" non può mai essere vero al Next block: ogni run rilascia l'ownership prima del report (`execution-contract.md:99-101`, PROTOCOL punto 12) | Togliere la clausola o dichiararla difensiva |
| F15 | `references/mode-handoff.md:75-78` vs `output-template.md:212` | H1 chiede di registrare anche la "request time" della deadline; il template §1 ha solo `deadline <…>` | Aggiungere `received <time>` alla riga Settings (richiede bump formato) o togliere il requisito |
| F16 | `references/output-template.md:226` | "(unless explicit: autonomy true, WIP on, power low)" è ambiguo: sembra dire che i default valgono *a meno che* esplicito, ma la frase è attaccata a "set by Plan <date>" | Riformulare: "— set by Plan <date>; defaults when not explicit: autonomy true, WIP on, power low" |
| F17 | `references/next-step.md:13` vs `README.md:595` | Il template della riga Mode non prevede `(<source>)` per executor-power, deadline e style; il README stampa `executor-power low (plan)` | Allineare il template |
| F18 | `references/execution-contract.md:253-254` | "a user reply asking to continue" cancella il latch, ma non dice in quale modo prosegue il lavoro | Rimandare alla regola `continue` → `resume` di invocation.md:93-99 |
| F19 | `references/output-template.md:207`, `execution-contract.md:115-117` | `repo <absolute path>` in STATE.md: nessuna regola per clone spostato o path diverso | "Locator: update on ownership claim, never a conflict by itself" |
| F20 | `references/invocation.md:33-34` | Non è detto se un'opzione autonomia in testa più la forma "ultimo token" conta come duplicato | Precisare |
| F21 | `USAGE_EXAMPLE.md:3417` (RE-09) | Unico caso Resume con target diverso (`resume 000_adhoc B-A002`) mentre RE-01…08 e 10…15 usano `resume 003`; la guida promette "the same 15 cases" | Usare `resume 003` anche in RE-09 (e spostare il caso B-A002 in "Combining options"), o dichiarare l'eccezione nell'intestazione Resume; stessa cosa in USAGE_EXAMPLE_IT |
| F22 | `references/output-template.md:348` (PROTOCOL punto 7) | `T-A<n>`/`B-A<n>` contro `T-A<NNN>` ovunque | Uniformare |
| F23 | `README.md:743` / `README_IT.md` | URL del repo `plan-execute-analyze` vs nome skill `plan-execute-verify` | Confermare l'URL |
| F24 | `references/agent-roster.md:19`, `:60-62`, `:84-85` | Roster di default Opus/Sonnet/Haiku: una sessione su un modello fuori roster (es. Fable) in stile `handoff` "implements and reviews nothing" e produce un handoff BLOCKED; funziona solo in stile `delegated` | Scelta di design: documentare meglio nel Quick start ("pass an explicit roster if your model is not opus/sonnet/haiku"), o in stile handoff far valere agent-1 come "la sessione corrente se più forte" |
| F25 | `references/mode-verify.md:39-40` | Audit di un piano con zero unità implementate → PASS banale | Edge case; eventualmente "INCOMPLETE: nothing to audit" |

## 5. Verificato e coerente

Punti controllati di proposito e trovati allineati tra contratto, manuali,
template, checklist e README (EN e IT):

- Tabella autonomia × WIP → commit (execution-contract §1, invocation,
  README "Which commits", USAGE_EXAMPLE "What gets committed", README_IT).
- Precedenza delle impostazioni e persistenza per modo (Plan → §3, Execute →
  override di scope, Task/Bug/Verify/Resume → solo invocazione, Onboard → mai).
- Autonomy loop e stop esaustivi; stop latch; deadline vincolante e "run in
  attesa di un worker non è idle" (H1–H2, §3, quality-checklist, README).
- Chiusure P<N> e PLAN: procedura di fallimento, attempt, subject obbligatori,
  trailer nel blocco finale; `--3way` e reset su branch unborn documentati.
- Snapshot dell'unit base e staging per hunk: i blob del base-tree esistono
  nell'object DB grazie a `write-tree`, quindi il fallback `--3way` ha la
  preimage; il limite di `git gc` è dichiarato.
- Approval gate Task/Bug con `false` (PROPOSED/WITHDRAWN, resume con ID),
  V6 e `execute verify` sulle correzioni, selettori e ambiguità di parsing.
- Compattazione STATE (§8) e history.md append-only; PROTOCOL.md statico.
- Next block: righe N0/N1/N2 e tabella N1 coerenti con i manuali di modo
  (salvo F12, F14, F17).
- README_IT e USAGE_EXAMPLE_IT strutturalmente sincronizzati; i blocchi di
  subject dei commit sono identici all'EN. L'IT traduce le etichette di
  provenienza nella riga Mode (esplicito, ambito, piano) come consentito da
  next-step.md:8-9; i token in STATE.md restano inglesi (giusto, non sono
  rivolti all'utente).

## 6. Convenzioni da rispettare nelle correzioni

Da `CLAUDE.md` del progetto: una modifica di regola tocca contratto o manuale
di modo, PROTOCOL in `output-template.md`, `quality-checklist.md` ed
entrambi i README. I numeri di sezione di STATE.md non si rinumerano. Solo
F15 (e F2 se si sceglie il formato 3) cambia la struttura di STATE.md e
richiede il bump di `Format: pev-state <n>` con una nuova riga di migrazione;
le righe precedenti non si modificano.

Il README dichiara (`README.md:775-786`) che migrazione, handoff con deadline,
pass V6 e approval gate sono stati controllati solo staticamente. Dopo le
correzioni consiglio un giro end-to-end su un fixture per: migrazione di uno
STATE formato 1 reale e di uno "snello senza header"; handoff con deadline
mentre un worker gira; `verify` con `true` fino a V6; `execute verify` su uno
scope RUNNING (qualunque sia la decisione su F3).

## 7. Ordine suggerito

1. F1 (identità `PEV-Plan`): piccola, rischio reale, nessun bump.
2. F2 (migrazione 1→2) e F9 (PROPOSED senza ownership): entrambe toccano la
   consistenza dello STATE a freddo.
3. F3 (scope di `execute verify`): decisione di design, poi propagazione.
4. F4, F5, F6, F8, F11, F12: correzioni testuali puntuali.
5. F7, F10 e i punti minori.

## 8. Risoluzione (2026-11-07)

Tutti i finding sono stati applicati nei file della skill, senza commit. Il
numero di formato STATE resta `pev-state 2`: nessuna correzione cambia la
struttura di STATE.md. Per ogni finding, la decisione presa e dove vive.

| # | Decisione | File toccati |
|---|-----------|--------------|
| F1 | `<plan-id>` = prefisso di tre cifre della cartella (`003`) o `000_adhoc`, scritto identico in trailer, subject, intestazione STATE e `PEV-Includes`; un percorso esplicito mantiene il prefisso `<NNN>_` (aggiunto se manca), quindi ogni piano ne ha uno | execution-contract §6 (definizione accanto al blocco trailer), SKILL.md (percorso esplicito), output-template (header STATE/PROTOCOL/history `<plan-id>`, PROTOCOL punto 7), worked-example :219 |
| F2 | Riga 1→2 riscritta: idempotente ("ogni passo solo dove manca"), mappatura campo per campo di §1 e §3 nel layout del formato 2, vecchio §2 ridotto a `Readiness` e testo spostato in history.md come voce datata `migration 1 → 2`. Convenzione cambiata: il layout di un numero di formato non cambia mai; una riga esistente si modifica solo per migrare più completamente in quello stesso layout | execution-contract §8 (riga e regola finale), CLAUDE.md del progetto |
| F3 | `execute verify` non imposta, sostituisce né continua lo scope salvato: gira come invocazione propria registrata in §1 (come V6); le sue opzioni valgono per quel passaggio; `resume <plan>` finisce prima un passaggio interrotto (RUNNING/BLOCKED in §1) poi continua lo scope. Scope legacy `report V<NNN>` continuato come passaggio e poi `none` | execution-contract §1/§3, invocation.md, SKILL.md, mode-execute E1/E2/E5, mode-resume R3, mode-handoff H4/H6, output-template (§1 Scope, PROTOCOL punto 1), quality-checklist, next-step righe 11/12, README/README_IT, USAGE_EXAMPLE/IT (intro EV, EV-01..15, matrice, opzioni) |
| F4 | "solo quella voce" qualificato con `false`; con `true` il Resume recupera prima l'altro lavoro (R2) | mode-taskbug.md |
| F5 | Verify è l'eccezione sotto entrambe le impostazioni: sospende (§12), non chiude prima l'unità aperta | execution-contract §2 passo 3 |
| F6 | Sezione `## Open audit` nel template di verify/index.md (report, scope, attempt, owner, settings, checkpoint, stop reason); `000_adhoc/verify/index.md` citato nei README | templates-audit.md, mode-verify.md, README/README_IT |
| F7 | `full-autonomous:true|false` come ultimo token vale anche su `task` e `bug` | invocation.md, execution-contract §1, README/README_IT, USAGE_EXAMPLE/IT (comandi rifiutati, intro Task) |
| F8 | history.md aggiunto al contenuto del commit di handoff; una voce PROPOSED dentro un ledger committato intero è "trasportata, non approvata" | mode-handoff H5, next-step N2 |
| F9 | La scrittura PROPOSED in §1 è uno state update normale: claim di ownership, migrazioni pendenti, rilascio nello stesso stop (`approval stop`); con un altro writer vivo è un conflitto (riga 4) e la proposta resta solo nel ledger | mode-taskbug.md, quality-checklist |
| F10 | Una fase si espande dal file di fase all'apertura della prima unità; una fase DONE riaperta da una correzione si riespande con tutte le sotto-fasi DONE (attempt e riferimento dai trailer Git, `legacy` senza commit) più le righe di correzione | execution-contract §8, PROTOCOL punto 9 |
| F11 | "(after the last P<N> the PLAN closure runs first, §3)" | execution-contract §1 |
| F12 | Con commit disabilitati il report rimanda a `handoff` (riga Stop, N2) per il lavoro sul codice; un comando commit si suggerisce solo per file che un handoff non committa | execution-contract §6 passo 1, mode-execute E6, quality-checklist, README/README_IT, USAGE_EXAMPLE/IT (EX-09, TA-09, BU-09) |
| F13 | Board 0.1 → agent-3 | worked-example.md |
| F14 | Clausola "ownership held by this session" rimossa dalla riga Stop: ogni run rilascia prima del report | SKILL.md, next-step N2, PROTOCOL punto 12, README/README_IT |
| F15 | Tolto il requisito della "request time": si registra solo la deadline | mode-handoff H1 |
| F16 | Riga Plan defaults riformulata: "set by Plan <date>; where the Plan invocation gave no value it wrote autonomy true, WIP on, power low" | output-template §3 |
| F17 | Template riga Mode con `(<source>)` anche per executor-power e roster | next-step.md |
| F18 | Il reply "continua" è gestito come `resume` del lavoro in handoff (invocation.md) | execution-contract §3 |
| F19 | Il path del repo è un locatore: con checkout spostato si verificano branch e baseline, si aggiorna il path nello state update che prende l'ownership, mai un conflitto da solo | execution-contract §2 passo 1, PROTOCOL punto 1 |
| F20 | Opzione autonomia in testa + token in coda (o richiesta in linguaggio naturale di valore opposto) = duplicato rifiutato | invocation.md, execution-contract §1, README/README_IT, USAGE_EXAMPLE/IT |
| F21 | RE-09 ora usa `resume 003` (stop dopo P2, nessun commit); il caso `resume 000_adhoc B-A002` è in "Combining options" (151 comandi nei fence per lingua, prima 150) | USAGE_EXAMPLE/IT (RE-03, RE-09, matrice, Combining) |
| F22 | `T-A<NNN>`/`B-A<NNN>` anche nel PROTOCOL | output-template punto 7 |
| F23 | Nessuna modifica: `git remote -v` conferma l'URL `https://github.com/manprint/plan-execute-analyze.git` | — |
| F24 | Nota nei README: roster esplicito quando il modello della sessione non è Opus/Sonnet/Haiku, perché una sessione fuori roster non implementa né revisiona | README/README_IT (sezione roster) |
| F25 | INCOMPLETE anche quando nello scope non c'è nulla di implementato | mode-verify V4 |

Controlli ripetuti dopo le correzioni: link relativi (solo i due falsi
positivi del template), parità README 21/48/38, parità USAGE_EXAMPLE
154/135/151 con gli stessi comandi, snippet awk OK, `git diff --check` pulito.
Scelta reversibile da valutare: la modifica della convenzione in `CLAUDE.md`
sulla riga di migrazione 1→2 (F2).
