# plan-execute-verify — esempi d'uso

[English](USAGE_EXAMPLE.md) · [README in italiano](README_IT.md)

Questa guida mostra ogni modalità di `/plan-execute-verify` con ogni opzione, un
caso alla volta. Ogni caso riporta il comando, cosa fa, cosa aspettarsi e tutte
le impostazioni usate da quella run, comprese quelle che non hai scritto.

## Come leggere questa guida

- **Le modalità** dicono cosa fare: `onboard`, `plan`, `execute`, `execute
  verify`, `task`, `bug`, `verify`, `resume`, `handoff`.
- **Le opzioni** vanno prima della modalità e cambiano il modo in cui lavora:
  `full-autonomous:true|false`, `--wip-commit`, `--no-wip-commit`,
  `executor-power:low|medium|high`, un elenco di agenti e
  `--deadline=dd-mm-yyyy_hh_mm`.
- Ogni modalità ha gli stessi 15 casi: nessuna opzione, ogni opzione da sola, le
  quattro coppie autonomia × WIP (insieme decidono i commit), i tre livelli di
  executor-power, le due forme dell'elenco agenti e una deadline. Le opzioni si
  combinano liberamente: vedi [Combinare le opzioni](#combinare-le-opzioni).
- Ogni caso termina con **Impostazioni di questa run**: ogni impostazione, il
  suo valore e da dove viene: *dal tuo comando*, *default*, *dal piano 003* o
  *dal lavoro ripreso*.

## La situazione degli esempi

Ogni caso parte da questa stessa situazione; nessun caso la modifica per il successivo. Tutti gli esempi presuppongono che:

- il piano `003` (`docs/plans/003_plan-RateLimit/`) sia stato creato senza
  opzioni, quindi le sue impostazioni salvate sono i default:
  `full-autonomous:false`, WIP off, `executor-power:low` e gli agenti di default
  agent-1 Opus, agent-2 Sonnet, agent-3 Haiku;
- il piano 003 sia in esecuzione: un `execute 003` precedente, lanciato senza
  opzioni, si sia fermato dopo una fase, quindi `resume 003` abbia lavoro da
  continuare;
- il piano 003 abbia un report di audit, `V001`, con correzioni pronte da
  applicare; un nuovo audit riceva `V002`;
- un nuovo piano riceva il numero `004`;
- i task e i bug degli esempi non nominino un piano, quindi finiscano nel ledger
  ad-hoc `docs/plans/000_adhoc/`, che contiene già i task fino a `T-A003` e il
  bug `B-A002`, lasciato aperto da una sessione precedente: un nuovo task riceva
  `T-A004` e un nuovo bug `B-A003`;
- `opus`, `sonnet`, `haiku` e `my-model` stiano per nomi di modelli supportati
  dal tuo host;
- `--deadline=31-10-2026_17_30` indichi il 31 ottobre 2026 alle 17:30, ora
  locale.

## Le parole usate in questa guida

- **Piano**: una cartella in `docs/plans/` che descrive una funzionalità passo
  per passo e registra l'avanzamento in `STATE.md`.
- **Fase, sotto-fase, unità**: una fase è un gruppo di passi collegati; una
  sotto-fase ne è un pezzo piccolo; ogni fase termina con un controllo chiamato
  chiusura (`P1`, `P2`, …). Ogni pezzo su cui l'agente lavora in un colpo solo è
  un'unità.
- **Esecuzione**: la parte di piano che un `execute` deve svolgere. `resume` la
  continua; un `execute` diverso la sostituisce.
- **Task, bug, ledger**: piccole modifiche e correzioni fuori dalle fasi di un
  piano. Ognuna riceve un ID (`T-A004`, `B-A002`) e una voce in un elenco
  chiamato ledger: `tasks.md` o `bugs.md`, nella cartella del piano o in
  `docs/plans/000_adhoc/`.
- **Mini-piano**: il breve piano di un task o di un fix, scritto nella sua voce
  del ledger prima di toccare il codice.
- **Agenti, supervisore, self-review**: i modelli che fanno il lavoro. agent-1 è
  il supervisore: progetta, rivede e approva. Quando un modello rivede il
  proprio lavoro, la revisione è indicata come self-review.
- **Checkpoint**: una nota salvata su dove si trova il lavoro e cosa fare dopo,
  così un'altra sessione può continuare.
- **Commit WIP**: un commit "work in progress" che salva il lavoro non finito a
  un checkpoint e viene aggiornato man mano.
- **Audit, correzione**: `verify` controlla il lavoro finito e scrive un report
  (`V001`, `V002`, …); ogni fix che propone è una correzione, applicata poi con
  `execute verify`.
- **Handoff**: uno stop ordinato che salva tutto ciò che serve per continuare
  più tardi.

## Le opzioni e i loro default

| Opzione | Cosa fa | Default | Accettata da |
|---|---|---|---|
| `full-autonomous:true` / `:false` | `true`: va avanti finché il lavoro selezionato è finito e committa in locale ogni parte completata. `false`: si ferma dopo ogni fase (Task e Bug: una volta, per farti approvare il mini-piano) e non fa commit di completamento | `false` | Tutte le modalità; Plan la salva per le run successive; Onboard e Handoff la ignorano |
| `--wip-commit` / `--no-wip-commit` | Committa i progressi: unità finite, fasi chiuse e un commit "work in progress" a rotazione ai checkpoint. `--no-wip-commit` lo disattiva | off | Tutte le modalità; Plan la salva per le run successive; nessun effetto in Onboard e Verify; Handoff la ignora |
| `executor-power:low` / `medium` / `high` | Dice al pianificatore quanto sono capaci i modelli esecutori: `low` dà unità piccole con istruzioni dettagliate; `high` dà unità più grandi di cui l'esecutore decide il design interno | `low` | Solo Plan |
| `agent-1:<modello>,agent-2:<modello>,…` | Sceglie il modello per ogni ruolo: agent-1 è il supervisore (progetta, rivede, approva); gli altri implementano | L'elenco salvato nel piano, altrimenti agent-1 Opus, agent-2 Sonnet, agent-3 Haiku | Tutte le modalità; Handoff lo ignora |
| `agent:<modello>` | Un solo modello fa tutto e rivede il proprio lavoro | Come sopra | Tutte le modalità; Handoff lo ignora |
| `--deadline=dd-mm-yyyy_hh_mm` | Si ferma in modo ordinato entro quell'ora locale: salva lo stato, committa il lavoro sul codice e mostra il comando di ripresa. Impostala un po' prima di quando devi davvero fermarti | nessuna | Tutte le modalità |

Dove vengono conservate le opzioni:

- **Plan** le salva come default del piano per le run successive.
- **Execute** ed **Execute verify** le conservano per quell'esecuzione: `resume`
  le riusa, e non cambiano mai i default del piano.
- **Task**, **Bug**, **Verify** e **Resume** le usano solo per quella run.
- **Onboard** non salva mai nulla; **Handoff** ignora tutto tranne la deadline.
- Una **deadline** vale sempre solo per la propria run.

## Cosa viene committato

| `full-autonomous` | WIP | Unità di codice e fasi finite | Commit WIP ai checkpoint | Audit finito |
|---|---|---|---|---|
| `false` | off | No | No | No |
| `false` | on | Sì | Sì | No |
| `true` | off | Sì | No | Sì, solo file di audit |
| `true` | on | Sì | Sì | Sì, solo file di audit |

Plan e Onboard non fanno mai commit. Un handoff fa un commit per il lavoro sul
codice anche con i commit disattivati, salvo che non ci sia nulla da committare
o che un hook di commit lo rifiuti: in quel caso il report mostra il comando di
commit. I commit sono sempre locali, sul branch corrente: non viene mai fatto
push.

## Matrice riassuntiva

Ogni cella riporta l'ID del caso e il suo effetto in poche parole.

| # | Opzioni | Onboard | Plan | Execute | Execute verify | Task | Bug | Verify | Resume | Handoff |
|---|---|---|---|---|---|---|---|---|---|---|
| 01 | nessuna opzione | ON-01 solo ispezione | PL-01 default salvati | EX-01 stop per fase, nessun commit | EV-01 stop per fase, nessun commit | TA-01 approvazione, nessun commit | BU-01 approvazione, nessun commit | VE-01 nessun commit | RE-01 stop per fase, nessun commit | HA-01 stop subito |
| 02 | `full-autonomous:true` | ON-02 nessun effetto | PL-02 default salvati | EX-02 tutto, commit | EV-02 tutto, commit | TA-02 nessuno stop, commit | BU-02 nessuno stop, commit | VE-02 report committato | RE-02 tutto, commit | HA-02 ignorata, stop subito |
| 03 | `full-autonomous:false` | ON-03 nessun effetto | PL-03 default salvati | EX-03 stop per fase, nessun commit | EV-03 stop per fase, nessun commit | TA-03 approvazione, nessun commit | BU-03 approvazione, nessun commit | VE-03 nessun commit | RE-03 stop per fase, nessun commit | HA-03 ignorata, stop subito |
| 04 | `--wip-commit` | ON-04 nessun effetto | PL-04 default salvati | EX-04 stop per fase, commit + WIP | EV-04 stop per fase, commit + WIP | TA-04 approvazione, commit + WIP | BU-04 approvazione, commit + WIP | VE-04 nessun commit | RE-04 stop per fase, commit + WIP | HA-04 ignorata, stop subito |
| 05 | `--no-wip-commit` | ON-05 nessun effetto | PL-05 default salvati | EX-05 stop per fase, nessun commit | EV-05 stop per fase, nessun commit | TA-05 approvazione, nessun commit | BU-05 approvazione, nessun commit | VE-05 nessun commit | RE-05 stop per fase, nessun commit | HA-05 ignorata, stop subito |
| 06 | `full-autonomous:true --wip-commit` | ON-06 nessun effetto | PL-06 default salvati | EX-06 tutto, commit + WIP | EV-06 tutto, commit + WIP | TA-06 nessuno stop, commit + WIP | BU-06 nessuno stop, commit + WIP | VE-06 report committato | RE-06 tutto, commit + WIP | HA-06 ignorata, stop subito |
| 07 | `full-autonomous:false --wip-commit` | ON-07 nessun effetto | PL-07 default salvati | EX-07 stop per fase, commit + WIP | EV-07 stop per fase, commit + WIP | TA-07 approvazione, commit + WIP | BU-07 approvazione, commit + WIP | VE-07 nessun commit | RE-07 stop per fase, commit + WIP | HA-07 ignorata, stop subito |
| 08 | `full-autonomous:true --no-wip-commit` | ON-08 nessun effetto | PL-08 default salvati | EX-08 tutto, commit | EV-08 tutto, commit | TA-08 nessuno stop, commit | BU-08 nessuno stop, commit | VE-08 report committato | RE-08 tutto, commit | HA-08 ignorata, stop subito |
| 09 | `full-autonomous:false --no-wip-commit` | ON-09 nessun effetto | PL-09 default salvati | EX-09 stop per fase, nessun commit | EV-09 stop per fase, nessun commit | TA-09 approvazione, nessun commit | BU-09 approvazione, nessun commit | VE-09 nessun commit | RE-09 solo B-A002, nessun commit | HA-09 ignorata, stop subito |
| 10 | `executor-power:low` | ON-10 rifiutato | PL-10 unità piccole e dettagliate | EX-10 rifiutato | EV-10 rifiutato | TA-10 rifiutato | BU-10 rifiutato | VE-10 rifiutato | RE-10 rifiutato | HA-10 ignorata, stop subito |
| 11 | `executor-power:medium` | ON-11 rifiutato | PL-11 unità medie | EX-11 rifiutato | EV-11 rifiutato | TA-11 rifiutato | BU-11 rifiutato | VE-11 rifiutato | RE-11 rifiutato | HA-11 ignorata, stop subito |
| 12 | `executor-power:high` | ON-12 rifiutato | PL-12 unità per risultato | EX-12 rifiutato | EV-12 rifiutato | TA-12 rifiutato | BU-12 rifiutato | VE-12 rifiutato | RE-12 rifiutato | HA-12 ignorata, stop subito |
| 13 | `agent-1:opus,agent-2:sonnet,agent-3:haiku` | ON-13 questi ispettori | PL-13 elenco salvato | EX-13 sostituisce elenco | EV-13 sostituisce elenco | TA-13 solo questa run | BU-13 solo questa run | VE-13 solo questa run | RE-13 solo questa run | HA-13 ignorata, stop subito |
| 14 | `agent:my-model` | ON-14 un solo modello | PL-14 un solo modello | EX-14 un solo modello | EV-14 un solo modello | TA-14 un solo modello | BU-14 un solo modello | VE-14 un solo modello | RE-14 un solo modello | HA-14 ignorata, stop subito |
| 15 | `--deadline=31-10-2026_17_30` | ON-15 stop entro deadline | PL-15 bozza salvata alla deadline | EX-15 handoff alla deadline | EV-15 handoff alla deadline | TA-15 handoff alla deadline | BU-15 handoff alla deadline | VE-15 audit in pausa alla deadline | RE-15 handoff alla deadline | HA-15 stop entro la deadline |

## Alla fine di ogni run

Ogni run, in ogni modalità e comunque finisca, chiude il report con due
suggerimenti: il comando per continuare e come fermarsi. Sono solo suggerimenti:
l'agente non li esegue mai da solo, nemmeno con `full-autonomous:true`.

```text
Prossimo passo
- Continua: `/plan-execute-verify resume 003` — prosegue con la sotto-fase 2.1
- Fermati: `/plan-execute-verify handoff` — committa 1.1, 1.2 e P1, ancora non committati; poi chiudi la sessione
```

- **Continua** è un solo comando esatto, pronto da copiare, senza opzioni: le
  impostazioni già registrate viaggiano con `resume`. Una run completamente
  nuova è indicata come nuova, con le impostazioni che userà. Se manca una
  decisione, dice "rispondi a …, poi …". Se non c'è seguito, lo dice.
- **Fermati** suggerisce `handoff` solo se resta lavoro sul codice non
  committato; altrimenti dice che non c'è niente da salvare e puoi chiudere la
  sessione. Bozze di piano, report di audit, task proposti e
  `docs/onboarding.md` non vengono mai committati da un handoff: sono elencati
  con un comando di commit suggerito.

## Comandi rifiutati

Questi comandi vengono rifiutati prima di fare qualsiasi cosa, in ogni modalità
tranne `handoff`. Un rifiuto non passa mai a un'altra modalità; il report
suggerisce il comando corretto quando la correzione è chiara.

| Comando | Perché |
|---|---|
| `/plan-execute-verify full-autonomous:yes execute 003` | Solo `true` o `false` |
| `/plan-execute-verify full-autonomous:true full-autonomous:false execute 003` | Autonomia indicata due volte |
| `/plan-execute-verify --wip-commit --no-wip-commit execute 003` | Opzioni WIP in conflitto |
| `/plan-execute-verify executor-power:max plan aggiungi export CSV` | Livello non valido |
| `/plan-execute-verify executor-power:low executor-power:high plan aggiungi export CSV` | Livello indicato due volte |
| `/plan-execute-verify executor-power:high execute 003` | Lo accetta solo Plan (casi 10–12 delle altre modalità) |
| `/plan-execute-verify --deadline=31-10-26_17_30 execute 003` | Formato errato: `dd-mm-yyyy_hh_mm` |
| `/plan-execute-verify --deadline=31-02-2026_17_30 execute 003` | Quella data non esiste |
| `/plan-execute-verify --deadline=31-10-2026_17_30 --deadline=31-10-2026_18_00 execute 003` | Deadline indicata due volte |
| `/plan-execute-verify --fast execute 003` | Opzione sconosciuta |
| `/plan-execute-verify agent:opus,agent-2:sonnet execute 003` | Le due forme dell'elenco agenti mescolate |
| `/plan-execute-verify agent-1:opus,agent-3:haiku execute 003` | I numeri devono partire da 1 senza buchi |
| `/plan-execute-verify agent-1:opus,agent-1:sonnet execute 003` | Stesso numero due volte |
| `/plan-execute-verify agent-1:opus,agent-2: execute 003` | Nome del modello mancante |

Altre due regole proteggono dagli errori di battitura. Un'opzione scritta dopo
la modalità, dentro una descrizione, come `task correggi l'export
--deadline=31-10-2026_17_30`, non viene applicata: l'agente chiede prima di
iniziare se la intendevi come opzione, che va prima della modalità. Un comando
che chiede solo di continuare, come `/plan-execute-verify continue 003`, non
crea mai un piano: viene eseguito come `resume 003`, oppure l'agente chiede cosa
intendevi.

Le sole opzioni, come `/plan-execute-verify full-autonomous:true`, non
selezionano lavoro. Anche argomenti mancanti o selettori non validi sono errori.
`handoff` fa eccezione: non rifiuta mai una richiesta di stop, ignora e segnala
ciò che non usa, e una deadline non valida o doppia vale "fermati subito".

## Onboard

```text
/plan-execute-verify [<opzioni>] onboard [<piano>]
```

Onboard legge il repository e gli eventuali piani, poi ti dice a che punto è il
lavoro e cosa fare dopo. Scrive solo `docs/onboarding.md`: niente codice,
nessuna modifica ai piani, nessun commit, e non avvia nulla da solo. Aggiungi il
numero di un piano per concentrarti su quello.

### ON-01 · nessuna opzione

```text
/plan-execute-verify onboard
```

**Cosa fa:** Mappa il repository e i suoi piani, mostra a che punto è il lavoro
e suggerisce il comando successivo.

**Cosa aspettarsi:** Scrive solo `docs/onboarding.md`, non committato. Non tocca
codice o piani e non avvia nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: on (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: on (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: off (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit onboard
```

**Cosa fa:** Come senza opzioni: l'opzione è accettata ma non cambia nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: off (dal tuo comando; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low onboard
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello di ciascun piano.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium onboard
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello di ciascun piano.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high onboard
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello di ciascun piano.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku onboard
```

**Cosa fa:** Ispeziona con gli agenti che indichi; agent-1 fa la lettura
architetturale.

**Cosa aspettarsi:** L'elenco vale solo per questa ispezione; quelli salvati nei
piani non cambiano. Il report dice quale agente ha davvero ispezionato.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa ispezione)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model onboard
```

**Cosa fa:** Un solo modello, my-model, fa tutta l'ispezione.

**Cosa aspettarsi:** Non viene salvato nulla. Le letture architetturali incerte
sono segnate come non riviste da un modello più forte.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa ispezione)
- Deadline: nessuna (default)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### ON-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 onboard
```

**Cosa fa:** Onboarding normale che si ferma entro le 17:30.

**Cosa aspettarsi:** L'onboarding è breve e di sola lettura. Alla deadline si
ferma senza scrivere altro; rilancia `onboard` più tardi.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: off (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito; in ogni caso
  entro le 17:30
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

## Plan

```text
/plan-execute-verify [<opzioni>] plan <descrizione>
```

Plan progetta una funzionalità prima di scrivere codice: studia il repository,
approfondisce le domande aperte e scrive un piano a fasi in
`docs/plans/<NNN>_plan-<Nome>/` (panoramica, file di fase, `STATE.md`). Non
scrive codice di produzione e non fa mai commit. Le opzioni date qui diventano i
default del piano per le run successive. Puoi anche omettere la parola `plan`:
basta la descrizione.

### PL-01 · nessuna opzione

```text
/plan-execute-verify plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano con tutti i default.

**Cosa aspettarsi:** Le run di `execute` successive si fermano dopo ogni fase e
non fanno commit, salvo diversa scelta al momento. Plan non scrive codice e non
fa mai commit; il report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Un successivo `execute 004` senza opzioni esegue tutto il
piano e committa ogni unità completata. Plan non scrive codice e non fa mai
commit; il report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive si fermano dopo ogni fase e non fanno
commit di completamento (è anche il default). Plan non scrive codice e non fa
mai commit; il report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive committano unità, fasi e checkpoint di
avanzamento, e si fermano comunque dopo ogni fase. Plan non scrive codice e non
fa mai commit; il report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: on (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive non fanno commit WIP (è anche il
default). Plan non scrive codice e non fa mai commit; il report suggerisce il
comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive vanno fino in fondo e committano tutto:
unità completate e checkpoint. Plan non scrive codice e non fa mai commit; il
report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: on (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive si fermano dopo ogni fase, ma committano
lavoro finito e checkpoint. Plan non scrive codice e non fa mai commit; il
report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: on (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive vanno fino in fondo, committando ogni
unità finita, senza commit WIP. Plan non scrive codice e non fa mai commit; il
report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: off (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questa scelta come suo default.

**Cosa aspettarsi:** Le run successive si fermano dopo ogni fase e non fanno
alcun commit. Plan non scrive codice e non fa mai commit; il report suggerisce
il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: off (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Scrive il piano per modelli esecutori meno capaci (il default).

**Cosa aspettarsi:** Molte unità piccole con istruzioni passo passo ed esempi
già pronti per le parti difficili.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Scrive il piano per modelli esecutori di livello medio.

**Cosa aspettarsi:** Meno unità, con contratti e passi precisi; l'esecutore
completa i dettagli di routine.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `medium` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Scrive il piano per modelli esecutori forti.

**Cosa aspettarsi:** Unità più grandi descritte dal risultato; l'esecutore
decide il design interno e lo registra, mentre interfacce, test e regole restano
fissati dal supervisore. Usalo solo se tutti gli esecutori sono forti.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `high` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questo elenco di agenti.

**Cosa aspettarsi:** agent-1 (opus) progetta, rivede e approva; le unità vanno
ad agent-2 (sonnet) e agent-3 (haiku). Le run successive usano questo elenco,
salvo che tu ne indichi un altro.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; salvati
  nel piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano con un solo modello per tutti i ruoli.

**Cosa aspettarsi:** my-model pianifica, implementa e rivede il proprio lavoro;
le revisioni sono segnate come self-review.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; salvati nel piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Pianifica normalmente; alle 17:30 salva la bozza e si ferma.

**Cosa aspettarsi:** La bozza resta non committata; si continua con `resume
004`. Se il piano è pronto prima, termina normalmente. La deadline non viene
salvata nel piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default; salvata come default del
  piano 004)
- Commit WIP: off (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, o a una domanda a cui solo tu puoi
  rispondere; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

## Execute

```text
/plan-execute-verify [<opzioni>] execute [<piano>] [<fase o sotto-fase>]
```

Execute implementa un piano esistente unità per unità, con test e revisioni, e
tiene aggiornato `STATE.md`. Senza fase esegue tutto il piano; con una fase
(`execute 003 phase_02`, `execute 003 1.2`) resta al suo interno. Le opzioni
date qui valgono per questa esecuzione: `resume` le riusa, e non cambiano mai i
default del piano.

### EX-01 · nessuna opzione

```text
/plan-execute-verify execute 003
```

**Cosa fa:** Esegue il piano 003 con le impostazioni salvate del piano 003.

**Cosa aspettarsi:** Si ferma dopo la prima fase che chiude e non fa commit; si
continua con `resume 003`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute 003
```

**Cosa fa:** Esegue il piano 003, senza pause tra le fasi, e committa ogni parte
finita, senza commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. `resume` mantiene queste
opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità e fase completata

### EX-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute 003
```

**Cosa fa:** Esegue il piano 003, fermandosi dopo ogni fase, e non committa
nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. `resume`
mantiene queste opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, fermandosi dopo ogni fase, e committa comunque
ogni parte finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. `resume` mantiene
queste opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: ogni unità e fase completata, più un commit WIP a
  rotazione a ogni checkpoint

### EX-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, fermandosi dopo ogni fase, e non committa
nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. `resume`
mantiene queste opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, senza pause tra le fasi, e committa ogni parte
finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. `resume` mantiene queste
opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità e fase completata, più un commit WIP a
  rotazione a ogni checkpoint

### EX-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, fermandosi dopo ogni fase, e committa comunque
ogni parte finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. `resume` mantiene
queste opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: ogni unità e fase completata, più un commit WIP a
  rotazione a ogni checkpoint

### EX-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, senza pause tra le fasi, e committa ogni parte
finita, senza commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. `resume` mantiene queste
opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità e fase completata

### EX-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

**Cosa fa:** Esegue il piano 003, fermandosi dopo ogni fase, e non committa
nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. `resume`
mantiene queste opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

**Cosa fa:** Esegue il piano 003 con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. Questo elenco sostituisce quello salvato nel
piano 003.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando;
  sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute 003
```

**Cosa fa:** Esegue il piano 003 con un solo modello per tutto.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Sostituisce l'elenco salvato nel piano
003.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

**Cosa fa:** Esegue il piano 003 fino alle 17:30 al massimo, poi si ferma in
modo ordinato.

**Cosa aspettarsi:** Prima delle 17:30 finisce o mette in pausa l'unità in
corso, salva lo stato, fa un commit di handoff per il codice e mostra il comando
di ripresa. Se il lavoro finisce prima, termina normalmente. Un `resume`
successivo non eredita la deadline.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: l'intero piano 003 (nessuna fase indicata)
- Dove si ferma: dopo la chiusura di ogni fase; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: le modifiche restano non committate; alla
  deadline, un commit di handoff per il codice non finito

## Execute verify

```text
/plan-execute-verify [<opzioni>] execute verify [<piano>] [<report>]
```

Execute verify applica le correzioni elencate in un report di audit (di default
il più recente del piano) e ricontrolla le fasi coinvolte. Applica solo quelle
correzioni, non nuovo lavoro del piano. Indica un ID di report, per esempio
`execute verify 003 V002`, per sceglierne un altro. In questo esempio il piano
003 è ancora in esecuzione, quindi l'agente chiede prima se sostituire
quell'esecuzione con le correzioni; i casi seguenti presuppongono che tu
risponda sì, e `resume 003` poi continua le correzioni.

### EV-01 · nessuna opzione

```text
/plan-execute-verify execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente con le
impostazioni salvate del piano 003.

**Cosa aspettarsi:** Si ferma dopo la prima fase che chiude e non fa commit; si
continua con `resume 003`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, senza pause
tra le fasi, e committa ogni parte finita, senza commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi quando tutte le correzioni sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata

### EV-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, fermandosi
dopo ogni fase, e non committa nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. Queste opzioni
restano valide finché proseguono queste correzioni; i default del piano non
cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, fermandosi
dopo ogni fase, e committa comunque ogni parte finita e un commit WIP ai
checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, fermandosi
dopo ogni fase, e non committa nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. Queste opzioni
restano valide finché proseguono queste correzioni; i default del piano non
cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, senza pause
tra le fasi, e committa ogni parte finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi quando tutte le correzioni sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, fermandosi
dopo ogni fase, e committa comunque ogni parte finita e un commit WIP ai
checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, senza pause
tra le fasi, e committa ogni parte finita, senza commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi quando tutte le correzioni sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata

### EV-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente, fermandosi
dopo ogni fase, e non committa nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. Queste opzioni
restano valide finché proseguono queste correzioni; i default del piano non
cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente con gli
agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. Questo elenco sostituisce quello salvato nel
piano 003.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando;
  sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente con un solo
modello per tutto.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Sostituisce l'elenco salvato nel piano
003.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EV-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente fino alle
17:30 al massimo, poi si ferma in modo ordinato.

**Cosa aspettarsi:** Prima delle 17:30 finisce o mette in pausa l'unità in
corso, salva lo stato, fa un commit di handoff per il codice e mostra il comando
di ripresa. Se il lavoro finisce prima, termina normalmente. Un `resume`
successivo non eredita la deadline.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: prima chiede conferma per sostituire l'esecuzione in corso del
  piano 003; poi dopo la chiusura di ogni fase riaperta; in ogni caso entro le
  17:30
- Commit fatti da questa run: nessuno: le modifiche restano non committate; alla
  deadline, un commit di handoff per il codice non finito

## Task

```text
/plan-execute-verify [<opzioni>] task <descrizione>
```

Task fa una piccola modifica. Prima di toccare il codice, agent-1 scrive o
controlla un breve piano della modifica (il mini-piano) e lo salva in
`docs/plans/000_adhoc/tasks.md`, o nel ledger del piano se la richiesta ne
nomina uno. Con `full-autonomous:false`, il default, poi si ferma perché tu lo
legga: approvi rispondendo nella stessa sessione o con `resume 000_adhoc
T-A004`; rifiuti dicendolo o segnando la voce `WITHDRAWN`. Con
`full-autonomous:true` non c'è stop. Tutto ciò che segue `task` è la
descrizione, anche testo come `--json`; solo un testo con la forma di un'opzione
di questa skill, come `--deadline=…`, fa chiedere conferma all'agente.

### TA-01 · nessuna opzione

```text
/plan-execute-verify task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, e lo implementa con i test.

**Cosa aspettarsi:** Un commit locale per la modifica quando test e revisioni
passano. Nessuno stop per l'approvazione, ma agent-1 controlla comunque prima il
mini-piano. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il task completato

### TA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Committa la modifica e un commit WIP ai checkpoint, anche
senza piena autonomia. Per approvare rispondi nella stessa sessione o lancia il
comando `resume` mostrato nel report. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, e lo implementa con i test.

**Cosa aspettarsi:** Committa la modifica e un commit WIP ai checkpoint. Nessuno
stop per l'approvazione, ma agent-1 controlla comunque prima il mini-piano. Le
opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Committa la modifica e un commit WIP ai checkpoint, anche
senza piena autonomia. Per approvare rispondi nella stessa sessione o lancia il
comando `resume` mostrato nel report. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, e lo implementa con i test.

**Cosa aspettarsi:** Un commit locale per la modifica quando test e revisioni
passano. Nessuno stop per l'approvazione, ma agent-1 controlla comunque prima il
mini-piano. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il task completato

### TA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, aspetta la tua approvazione, poi lo implementa con i
test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Gestisce la modifica con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) controlla il mini-piano e rivede il
risultato. L'elenco vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Un solo modello, my-model, gestisce la modifica da solo.

**Cosa aspettarsi:** Scrive e controlla il proprio mini-piano e rivede il
proprio lavoro; entrambi sono segnati come self-review. Con l'autonomia di
default si ferma comunque per la tua approvazione.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### TA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Gestisce la modifica e si ferma in modo ordinato entro le 17:30.

**Cosa aspettarsi:** Se sta già aspettando la tua approvazione, non succede
altro. Se sta implementando, si mette in pausa, salva il lavoro in un commit di
handoff e mostra il comando di ripresa.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: le modifiche restano non committate; alla
  deadline, un commit di handoff per il codice non finito

## Bug

```text
/plan-execute-verify [<opzioni>] bug <descrizione>
```

Bug corregge un difetto: riproduce il problema, trova la causa, scrive un test
che fallisce, corregge il codice e rilancia i test. Se non riesce a riprodurre
il bug, registra i tentativi invece di indovinare un fix. Con
`full-autonomous:false` si ferma per la tua approvazione dopo la diagnosi e il
mini-piano, prima del test e del fix. Le voci finiscono in
`docs/plans/000_adhoc/bugs.md`, salvo che la richiesta nomini un piano.

### BU-01 · nessuna opzione

```text
/plan-execute-verify bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, e scrive un test che fallisce, corregge il codice e
rilancia i test.

**Cosa aspettarsi:** Un commit locale per il fix quando test e revisioni
passano. Nessuno stop per l'approvazione, ma agent-1 controlla comunque prima il
mini-piano. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il fix completato

### BU-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Committa il fix e un commit WIP ai checkpoint, anche senza
piena autonomia. Per approvare rispondi nella stessa sessione o lancia il
comando `resume` mostrato nel report. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione a
  ogni checkpoint

### BU-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, e scrive un test che fallisce, corregge il codice e
rilancia i test.

**Cosa aspettarsi:** Committa il fix e un commit WIP ai checkpoint. Nessuno stop
per l'approvazione, ma agent-1 controlla comunque prima il mini-piano. Le
opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione a
  ogni checkpoint

### BU-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Committa il fix e un commit WIP ai checkpoint, anche senza
piena autonomia. Per approvare rispondi nella stessa sessione o lancia il
comando `resume` mostrato nel report. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione a
  ogni checkpoint

### BU-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, e scrive un test che fallisce, corregge il codice e
rilancia i test.

**Cosa aspettarsi:** Un commit locale per il fix quando test e revisioni
passano. Nessuno stop per l'approvazione, ma agent-1 controlla comunque prima il
mini-piano. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica
- Commit fatti da questa run: il fix completato

### BU-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano, lo fa
controllare ad agent-1, aspetta la tua approvazione, poi scrive un test che
fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessun commit: la modifica resta non committata e il report
suggerisce il comando di commit. Per approvare rispondi nella stessa sessione o
lancia il comando `resume` mostrato nel report. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello del piano collegato, `low` in 000_adhoc.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Gestisce il fix con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) controlla il mini-piano e rivede il
risultato. L'elenco vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Un solo modello, my-model, gestisce il fix da solo.

**Cosa aspettarsi:** Scrive e controlla il proprio mini-piano e rivede il
proprio lavoro; entrambi sono segnati come self-review. Con l'autonomia di
default si ferma comunque per la tua approvazione.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### BU-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Gestisce il fix e si ferma in modo ordinato entro le 17:30.

**Cosa aspettarsi:** Se sta già aspettando la tua approvazione, non succede
altro. Se sta implementando, si mette in pausa, salva il lavoro in un commit di
handoff e mostra il comando di ripresa.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo diagnosi e mini-piano, per la tua approvazione;
  poi alla fine della modifica; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: le modifiche restano non committate; alla
  deadline, un commit di handoff per il codice non finito

## Verify

```text
/plan-execute-verify [<opzioni>] verify [<piano>] [<fase, sotto-fase o voce>]
```

Verify fa l'audit di un piano, o di una sua parte (`verify 003 phase_02`,
`verify 003 1.2`, `verify 000_adhoc T-A004`), rispetto alla sua specifica:
comportamento, test, revisioni, stato e commit. Scrive un report datato con i
problemi trovati e le correzioni pronte, ma non tocca mai il codice. Le
correzioni si applicano con `execute verify`.

### VE-01 · nessuna opzione

```text
/plan-execute-verify verify 003
```

**Cosa fa:** Fa l'audit dell'intero piano 003 rispetto alla sua specifica.

**Cosa aspettarsi:** Scrive un report datato con i problemi trovati e le
correzioni pronte, e non tocca il codice. Il report resta non committato; alla
fine c'è il comando per applicare le correzioni, se ce ne sono.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true verify 003
```

**Cosa fa:** Fa l'audit del piano 003 e committa il report e lo stato del piano.

**Cosa aspettarsi:** Vengono committati solo i file di audit, mai codice. Il WIP
non aggiunge nulla per un audit. Le correzioni non vengono mai applicate in
automatico.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: il report di audit e lo stato del piano, mai
  codice

### VE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`; il
WIP non committa mai gli audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`; il
WIP non committa mai gli audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: on (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`; il
WIP non committa mai gli audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 e committa il report e lo stato del piano.

**Cosa aspettarsi:** Vengono committati solo i file di audit, mai codice. Il WIP
non aggiunge nulla per un audit. Le correzioni non vengono mai applicate in
automatico.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: il report di audit e lo stato del piano, mai
  codice

### VE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`; il
WIP non committa mai gli audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 e committa il report e lo stato del piano.

**Cosa aspettarsi:** Vengono committati solo i file di audit, mai codice. Il WIP
non aggiunge nulla per un audit. Le correzioni non vengono mai applicate in
automatico.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: il report di audit e lo stato del piano, mai
  codice

### VE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`; il
WIP non committa mai gli audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high verify 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku verify 003
```

**Cosa fa:** Fa l'audit del piano 003 con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) controlla i punti critici. L'elenco vale
solo per questo audit.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model verify 000_adhoc B-A002
```

**Cosa fa:** Un solo modello fa l'audit della voce di bug ad-hoc B-A002.

**Cosa aspettarsi:** Ogni revisione è una self-review, solo per questo audit. Le
correzioni diventano comandi `task` o `bug` pronti.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (default)
- Commit WIP: off (default; nessun effetto: gli audit non hanno commit WIP)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: la voce di bug ad-hoc B-A002
- Dove si ferma: quando l'audit è completo
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 verify 003
```

**Cosa fa:** Fa l'audit del piano 003 e si mette in pausa entro le 17:30 se non
ha finito.

**Cosa aspettarsi:** Alla deadline l'audit resta aperto con un checkpoint e
senza commit; si continua con il comando `resume` mostrato, per esempio `resume
003 V002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal piano 003, che usa il default)
- Commit WIP: off (dal piano 003, che usa il default; nessun effetto: gli audit
  non hanno commit WIP)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: il report resta non committato

## Resume

```text
/plan-execute-verify [<opzioni>] resume [<piano>] [<unità>]
```

Resume continua il lavoro interrotto o salvato. Prima completa il recupero di
ciò che era rimasto a metà (un'unità aperta, un commit pendente, un audit
aperto, una bozza di piano), poi continua l'esecuzione salvata del piano. Indica
un'unità per continuare solo quella (`resume 003 1.2`, `resume 000_adhoc
T-A004`); indicare un task o bug proposto lo approva. Le opzioni date qui
valgono solo per questa run; altrimenti il lavoro mantiene le impostazioni con
cui era partito.

### RE-01 · nessuna opzione

```text
/plan-execute-verify resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo con le impostazioni registrate su quel lavoro.

**Cosa aspettarsi:** Si ferma dopo la prima fase che chiude e non fa commit; si
continua con `resume 003`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, senza pause tra le fasi, e committa ogni parte finita, senza
commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità completata, come nella sua modalità

### RE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, fermandosi dopo ogni fase, e non committa nulla: committi tu
quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. Queste opzioni
valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, fermandosi dopo ogni fase, e committa comunque ogni parte
finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Queste opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: ogni unità completata, come nella sua modalità,
  più un commit WIP a rotazione a ogni checkpoint

### RE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, fermandosi dopo ogni fase, e non committa nulla: committi tu
quando vuoi.

**Cosa aspettarsi:** Solo un handoff fa comunque il suo commit. Queste opzioni
valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, senza pause tra le fasi, e committa ogni parte finita e un
commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità completata, come nella sua modalità,
  più un commit WIP a rotazione a ogni checkpoint

### RE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, fermandosi dopo ogni fase, e committa comunque ogni parte
finita e un commit WIP ai checkpoint.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Queste opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: ogni unità completata, come nella sua modalità,
  più un commit WIP a rotazione a ogni checkpoint

### RE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo, senza pause tra le fasi, e committa ogni parte finita, senza
commit WIP.

**Cosa aspettarsi:** I commit sono locali e mai pushati. Si ferma prima solo per
un blocco reale, una richiesta di stop o una deadline. Queste opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: quando tutto il lavoro selezionato è finito, o a un blocco
  reale
- Commit fatti da questa run: ogni unità completata, come nella sua modalità

### RE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit resume 000_adhoc B-A002
```

**Cosa fa:** Continua solo il bug ad-hoc B-A002, senza commit, e si ferma dopo
di esso.

**Cosa aspettarsi:** Le opzioni valgono solo per questa run, anche se la voce
aveva i commit attivi; la volta successiva tornano le impostazioni registrate.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: solo la voce di bug ad-hoc B-A002
- Dove si ferma: dopo la voce B-A002
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low resume 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium resume 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high resume 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. L'elenco vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo con un solo modello per tutto.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### RE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 resume 003
```

**Cosa fa:** Continua il lavoro interrotto del piano 003, poi l'esecuzione che
stava svolgendo fino alle 17:30 al massimo, poi si ferma in modo ordinato.

**Cosa aspettarsi:** Prima delle 17:30 finisce o mette in pausa l'unità in
corso, salva lo stato, fa un commit di handoff per il codice e mostra il comando
di ripresa. Se il lavoro finisce prima, termina normalmente. Un `resume`
successivo non eredita la deadline.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: piano 003: prima il lavoro interrotto, poi l'esecuzione che stava
  svolgendo
- Dove si ferma: dopo la chiusura di ogni fase; in ogni caso entro le 17:30
- Commit fatti da questa run: nessuno: le modifiche restano non committate; alla
  deadline, un commit di handoff per il codice non finito

## Handoff

```text
/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]
```

Handoff ferma il lavoro in modo ordinato. Non avvia nulla di nuovo, finisce
l'unità in corso solo se bastano circa 10 minuti, salva lo stato, fa un commit
per il lavoro sul codice (anche con i commit disattivati), mostra il comando per
riprendere e si ferma. Mandalo durante una run, oppure dai una deadline.
Funziona al meglio delle possibilità: l'agente legge il messaggio solo tra un
passo e l'altro, quindi imposta la deadline un po' prima di quando devi davvero
fermarti, per esempio alle 17:30 se spegni alle 18:00.

### HA-01 · nessuna opzione

```text
/plan-execute-verify handoff
```

**Cosa fa:** Ferma il lavoro adesso, in modo ordinato.

**Cosa aspettarsi:** Non avvia nulla di nuovo e finisce l'unità in corso solo se
bastano circa 10 minuti. Salva lo stato, fa un commit di handoff per il codice,
mostra il comando di ripresa e si ferma. Mandato durante una run, annulla anche
una deadline precedente. Mandato a una sessione inattiva, salva il lavoro che
quella sessione ha modificato per ultimo, mai lavoro di un'altra sessione
attiva.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true`, ignorato da Handoff, che lo segnala
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false`, ignorato da Handoff, che lo segnala
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: on, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: off, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true`, ignorato da Handoff, che lo segnala
- Commit WIP: on, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false`, ignorato da Handoff, che lo segnala
- Commit WIP: on, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true`, ignorato da Handoff, che lo segnala
- Commit WIP: off, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false`, ignorato da Handoff, che lo segnala
- Commit WIP: off, ignorato da Handoff, che lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `low`, ignorato da Handoff, che lo segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `medium`, ignorato da Handoff, che lo segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `high`, ignorato da Handoff, che lo segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: elenco agenti ignorato da Handoff, che lo segnala
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Una richiesta di stop non viene mai rifiutata. Il commit di
handoff per il codice avviene comunque, e nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: elenco agenti ignorato da Handoff, che lo segnala
- Deadline: nessuna (default)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: il prima possibile
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

### HA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 handoff
```

**Cosa fa:** Lascia continuare la run in corso e la ferma in modo ordinato entro
le 17:30. Le due forme sono equivalenti.

**Cosa aspettarsi:** Sostituisce una deadline precedente. Alle 17:30 fa quello
che fa `handoff` da solo. Una deadline passata o non valida significa "fermati
subito"; lo stesso vale per una sessione inattiva.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: la run in corso; in una sessione inattiva, il piano o ledger
  modificato per ultimo
- Dove si ferma: entro le 17:30
- Commit fatti da questa run: un commit di handoff per il lavoro sul codice,
  anche con i commit disattivati (nessuno se non c'è nulla da committare);
  nessuno per Plan, Verify o Onboard

## Combinare le opzioni

Le opzioni si combinano liberamente, in qualsiasi ordine, prima della modalità;
ognuna mantiene l'effetto descritto nel suo caso. Solo `executor-power` ha un
limite: la accetta soltanto Plan.

```text
/plan-execute-verify full-autonomous:true --wip-commit executor-power:medium agent-1:opus,agent-2:sonnet plan aggiungi export CSV
```

PL-06 + PL-11 + PL-13: il nuovo piano salva autonomia true, WIP on, livello
`medium` e questo elenco di agenti.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet full-autonomous:true --no-wip-commit execute 003 phase_02
```

EX-08 + EX-13, limitato alla fase in `phase_02.md` (fase logica 1, sotto-fasi
1.1, 1.2 e la sua chiusura P1).

```text
/plan-execute-verify agent:my-model full-autonomous:false --no-wip-commit task correggi il messaggio di errore del login
```

TA-09 + TA-14: un solo modello, uno stop per approvazione, nessun commit, nulla
salvato nei piani.

```text
/plan-execute-verify full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

RE-02 + RE-13: tutto vale solo per questa run.

```text
/plan-execute-verify --deadline=31-10-2026_17_30 full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

EX-15 + EX-02 + EX-13: tutto il piano, in autonomia, con questo elenco di
agenti, e uno stop ordinato entro le 17:30.
