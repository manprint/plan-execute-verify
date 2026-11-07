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
  `full-autonomous:true`, WIP on, `executor-power:low` e gli agenti di default
  agent-1 Opus, agent-2 Sonnet, agent-3 Haiku;
- un `execute 003` precedente, lanciato senza opzioni, sia stato fermato con
  `handoff` dopo la chiusura della fase 1 (1.1, 1.2 e P1, già committate),
  prima che la sotto-fase 2.1 iniziasse: nessuna unità è aperta e nessun codice
  è non committato. Lo scope salvato di 003 è `RUNNING`, con prossima unità 2.1,
  quindi `resume 003` ha lavoro da continuare;
- il piano 003 abbia un report di audit, `V001`, con correzioni pronte da
  applicare; un nuovo audit riceva `V002`;
- un nuovo piano riceva il numero `004`;
- i task e i bug degli esempi non nominino un piano, quindi finiscano nel ledger
  ad-hoc `docs/plans/000_adhoc/`, che contiene già i task fino a `T-A003` e il
  bug `B-A002`, lasciato aperto da una sessione precedente: un nuovo task riceva
  `T-A004` e un nuovo bug `B-A003`. Il piano 003 non ha né unità aperte né
  lavoro non committato, quindi l'unico candidato di un `handoff` mandato a una
  sessione inattiva è `000_adhoc` con `B-A002`;
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
  (`V001`, `V002`, …); ogni fix che propone è una correzione. Con
  `full-autonomous:true`, il default, la run le applica subito dopo l'audit;
  con `false` si applicano poi con `execute verify`.
- **Handoff**: uno stop ordinato che salva tutto ciò che serve per continuare
  più tardi.
- **Decisione autonoma**: con `full-autonomous:true`, una domanda che l'agente
  altrimenti ti farebbe. L'agente valuta le opzioni, sceglie quella che
  consiglia per l'obiettivo e registra motivi, rischio e come tornare indietro;
  il report finale le elenca tutte.

## Le opzioni e i loro default

| Opzione | Cosa fa | Default | Accettata da |
|---|---|---|---|
| `full-autonomous:true` / `:false` | `true`: va avanti finché il lavoro selezionato è finito, senza fermarsi e senza chiedere: ogni domanda diventa una decisione autonoma di agent-1, registrata con le alternative valutate, e committa in locale ogni parte completata. `false`: si ferma dopo ogni fase (Task e Bug: una volta, per farti approvare il mini-piano), ti fa le domande e non fa commit di completamento | `true` | Tutte le modalità; Plan la salva per le run successive; Onboard e Handoff la ignorano |
| `--wip-commit` / `--no-wip-commit` | Committa i progressi: unità finite, fasi chiuse e un commit "work in progress" a rotazione ai checkpoint. `--no-wip-commit` lo disattiva; i commit di completamento restano con l'autonomia `true` | on | Tutte le modalità; Plan la salva per le run successive; nessun effetto in Onboard; in Verify riguarda le correzioni; Handoff la ignora |
| `executor-power:low` / `medium` / `high` | Dice al pianificatore quanto sono capaci i modelli esecutori: `low` dà unità piccole con istruzioni dettagliate; `high` dà unità più grandi di cui l'esecutore decide il design interno | `low` | Solo Plan |
| `agent-1:<modello>,agent-2:<modello>,…` | Sceglie il modello per ogni ruolo: agent-1 è il supervisore (progetta, rivede, approva); gli altri implementano | L'elenco salvato nel piano, altrimenti agent-1 Opus, agent-2 Sonnet, agent-3 Haiku | Tutte le modalità; Handoff lo ignora |
| `agent:<modello>` | Un solo modello fa tutto e rivede il proprio lavoro | Come sopra | Tutte le modalità; Handoff lo ignora |
| `--deadline=dd-mm-yyyy_hh_mm` | Vincolante: la run finisce il lavoro in corso, salva lo stato, committa il lavoro sul codice e chiude il report entro quell'ora locale, lasciando una riserva di almeno 10 minuti per l'handoff. Non viene salvata in §3 e non passa al comando di ripresa | nessuna | Tutte le modalità |

Dove vengono conservate le opzioni:

- **Plan** le salva come default del piano per le run successive, con i valori
  risolti: anche quelli di default (autonomia `true`, WIP on) vengono scritti
  nel piano.
- **Execute** le conserva per quello scope: `resume` le riusa, e non cambiano
  mai i default del piano. **Execute verify** le conserva per il suo passaggio
  di correzioni, che gira accanto allo scope salvato senza sostituirlo.
- **Task**, **Bug**, **Verify** e **Resume** le usano solo per quella run.
- **Onboard** non salva mai nulla; **Handoff** ignora tutto tranne la deadline.
- Una **deadline** vale sempre solo per la propria run.
- Un valore già registrato, anche `false` o WIP off, non viene riscritto dai
  nuovi default: i default valgono solo dove non c'è nulla.

## Cosa viene committato

| `full-autonomous` | WIP | Unità di codice e fasi finite | Commit WIP ai checkpoint | Audit e correzioni (Verify) |
|---|---|---|---|---|
| `false` | off | No | No | No |
| `false` | on | Sì | Sì | No |
| `true` | off | Sì | No | Sì: audit, poi correzioni |
| `true` (default) | on (default) | Sì | Sì | Sì: audit, poi correzioni, anche con WIP |

Plan e Onboard non fanno mai commit. Un handoff fa un commit per il lavoro sul
codice anche con i commit disattivati, salvo che non ci sia nulla da committare
o che un hook di commit lo rifiuti: in quel caso il report mostra il comando di
commit. Con `true`, una correzione di Verify viene committata quando è finita,
come una qualunque unità di codice; con `false` l'audit non committa mai e non
parte nessuna correzione. I commit sono sempre locali, sul branch corrente: non
viene mai fatto push.

## Matrice riassuntiva

Ogni cella riporta l'ID del caso e il suo effetto in poche parole.

| # | Opzioni | Onboard | Plan | Execute | Execute verify | Task | Bug | Verify | Resume | Handoff |
|---|---|---|---|---|---|---|---|---|---|---|
| 01 | nessuna opzione | ON-01 solo ispezione | PL-01 nessuna domanda, default salvati | EX-01 continua fino alla fine, commit + WIP | EV-01 correzioni accanto allo scope, commit + WIP | TA-01 nessuno stop, commit + WIP | BU-01 nessuno stop, commit + WIP | VE-01 audit committato, poi correzioni | RE-01 recupera e continua fino alla fine, commit + WIP | HA-01 stop subito, handoff di B-A002 |
| 02 | `full-autonomous:true` | ON-02 nessun effetto | PL-02 nessuna domanda, default salvati | EX-02 tutto, commit + WIP | EV-02 correzioni accanto allo scope, commit + WIP | TA-02 nessuno stop, commit + WIP | BU-02 nessuno stop, commit + WIP | VE-02 audit committato, poi correzioni | RE-02 tutto, commit + WIP | HA-02 ignorata, stop subito |
| 03 | `full-autonomous:false` | ON-03 nessun effetto | PL-03 chiede le domande | EX-03 stop dopo P2, commit WIP | EV-03 stop per fase riaperta, commit WIP | TA-03 approvazione, poi commit WIP | BU-03 approvazione, poi commit WIP | VE-03 audit senza commit, nessuna correzione | RE-03 stop dopo P2, commit WIP | HA-03 ignorata, stop subito |
| 04 | `--wip-commit` | ON-04 nessun effetto | PL-04 nessuna domanda, default salvati | EX-04 tutto, commit + WIP | EV-04 correzioni accanto allo scope, commit + WIP | TA-04 nessuno stop, commit + WIP | BU-04 nessuno stop, commit + WIP | VE-04 audit committato, poi correzioni con WIP | RE-04 tutto, commit + WIP | HA-04 ignorata, stop subito |
| 05 | `--no-wip-commit` | ON-05 nessun effetto | PL-05 nessuna domanda, WIP off | EX-05 tutto, commit senza WIP | EV-05 correzioni accanto allo scope, commit senza WIP | TA-05 nessuno stop, commit senza WIP | BU-05 nessuno stop, commit senza WIP | VE-05 audit committato, poi correzioni senza WIP | RE-05 tutto, commit senza WIP | HA-05 ignorata, stop subito |
| 06 | `full-autonomous:true --wip-commit` | ON-06 nessun effetto | PL-06 nessuna domanda, default salvati | EX-06 tutto, commit + WIP | EV-06 correzioni accanto allo scope, commit + WIP | TA-06 nessuno stop, commit + WIP | BU-06 nessuno stop, commit + WIP | VE-06 audit committato, poi correzioni con WIP | RE-06 tutto, commit + WIP | HA-06 ignorata, stop subito |
| 07 | `full-autonomous:false --wip-commit` | ON-07 nessun effetto | PL-07 chiede le domande | EX-07 stop dopo P2, commit + WIP | EV-07 stop per fase riaperta, commit + WIP | TA-07 approvazione, poi commit + WIP | BU-07 approvazione, poi commit + WIP | VE-07 audit senza commit, nessuna correzione | RE-07 stop dopo P2, commit + WIP | HA-07 ignorata, stop subito |
| 08 | `full-autonomous:true --no-wip-commit` | ON-08 nessun effetto | PL-08 nessuna domanda, WIP off | EX-08 tutto, commit senza WIP | EV-08 correzioni accanto allo scope, commit senza WIP | TA-08 nessuno stop, commit senza WIP | BU-08 nessuno stop, commit senza WIP | VE-08 audit committato, poi correzioni senza WIP | RE-08 tutto, commit senza WIP | HA-08 ignorata, stop subito |
| 09 | `full-autonomous:false --no-wip-commit` | ON-09 nessun effetto | PL-09 chiede le domande, WIP off | EX-09 stop dopo P2, nessun commit | EV-09 stop per fase riaperta, nessun commit | TA-09 approvazione, nessun commit | BU-09 approvazione, nessun commit | VE-09 nessun commit, nessuna correzione | RE-09 stop dopo P2, nessun commit | HA-09 ignorata, stop subito |
| 10 | `executor-power:low` | ON-10 rifiutato | PL-10 unità piccole e dettagliate | EX-10 rifiutato | EV-10 rifiutato | TA-10 rifiutato | BU-10 rifiutato | VE-10 rifiutato | RE-10 rifiutato | HA-10 ignorata, stop subito |
| 11 | `executor-power:medium` | ON-11 rifiutato | PL-11 unità medie | EX-11 rifiutato | EV-11 rifiutato | TA-11 rifiutato | BU-11 rifiutato | VE-11 rifiutato | RE-11 rifiutato | HA-11 ignorata, stop subito |
| 12 | `executor-power:high` | ON-12 rifiutato | PL-12 unità per risultato | EX-12 rifiutato | EV-12 rifiutato | TA-12 rifiutato | BU-12 rifiutato | VE-12 rifiutato | RE-12 rifiutato | HA-12 ignorata, stop subito |
| 13 | `agent-1:opus,agent-2:sonnet,agent-3:haiku` | ON-13 questi ispettori | PL-13 elenco salvato | EX-13 sostituisce elenco | EV-13 sostituisce elenco | TA-13 solo questa run | BU-13 solo questa run | VE-13 audit e correzioni con questo elenco | RE-13 solo questa run | HA-13 ignorata, stop subito |
| 14 | `agent:my-model` | ON-14 un solo modello | PL-14 un solo modello | EX-14 un solo modello | EV-14 un solo modello | TA-14 un solo modello | BU-14 un solo modello | VE-14 un solo modello | RE-14 un solo modello | HA-14 ignorata, stop subito |
| 15 | `--deadline=31-10-2026_17_30` | ON-15 stop entro deadline | PL-15 bozza DRAFT salvata alla deadline | EX-15 handoff alla deadline, commit | EV-15 correzioni fino alla deadline, handoff | TA-15 chiude o handoff alla deadline | BU-15 chiude o handoff alla deadline | VE-15 audit chiuso, poi handoff alla deadline | RE-15 handoff alla deadline, commit | HA-15 continua fino al taglio, poi handoff; sessione inattiva: subito |

## Alla fine di ogni run

Ogni run, in ogni modalità e comunque finisca, chiude il report con tre parti:
la modalità con tutte le sue impostazioni effettive, il comando per continuare e
come fermarsi. Sono solo suggerimenti: l'agente non li esegue mai da solo,
nemmeno con `full-autonomous:true`.

```text
Prossimo passo
- Modalità: execute 003, fino alla chiusura di P2 · full-autonomous:false (dal tuo comando) · WIP on (dal piano 003) · executor-power low (dal piano 003) · deadline nessuna (default) · roster default (dal piano 003) · style delegated (default)
- Continua: `/plan-execute-verify resume 003` — prosegue con la sotto-fase 3.1; girerà con full-autonomous:false · WIP on, le impostazioni dello scope salvato
- Fermati: nulla da salvare; chiudi la sessione
```

- **Modalità** dice cosa ha fatto la run, su quale piano o ambito, e ogni
  impostazione con la sua origine: *dal tuo comando*, *default*, *dal piano
  003* o *dal lavoro ripreso*. Compare sempre, anche dopo un rifiuto (mostra
  ciò che ha letto) o un handoff.
- **Continua** è un solo comando esatto, pronto da copiare. Senza opzioni: le
  impostazioni già registrate viaggiano con `resume`, e la riga dice con quali
  giri. Una run completamente nuova è indicata come nuova, con le impostazioni
  che userà. Se manca un'informazione che solo tu puoi dare, dice "rispondi a …,
  poi …". Se non c'è seguito, lo dice.
- **Fermati** suggerisce `handoff` solo se resta lavoro sul codice non
  committato, una chiusura in sospeso o un ownership di questa sessione;
  altrimenti dice che non c'è niente da salvare e puoi chiudere la sessione.
  Bozze di piano, report di audit, task proposti e `docs/onboarding.md` non
  vengono mai committati da un handoff: sono elencati con un comando di commit
  suggerito.

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
--deadline=31-10-2026_17_30`: con `full-autonomous:true`, il default, l'agente
non chiede nulla. Una deadline valida in fondo alla descrizione viene presa come
deadline della run, perché fermarsi prima non fa perdere lavoro; gli altri
token restano testo; il report dice come li ha letti. Con
`full-autonomous:false` l'agente chiede prima di iniziare se la intendevi come
opzione, che va prima della modalità. Due token vengono letti anche lì: una
deadline dopo `handoff` e un token `full-autonomous:true|false` che chiude il
comando, descrizione di task o bug compresa, che vale come opzione; scriverlo
sia prima della modalità sia in fondo è un duplicato e viene rifiutato.

Un comando che chiede solo di continuare, come `/plan-execute-verify continue
003`, non crea mai un piano: viene eseguito come `resume 003`. Senza selettore,
`continue` da solo: con `true` riprende l'unico lavoro ripristinabile, se ce n'è
esattamente uno, altrimenti avvia un nuovo piano; con `false` l'agente chiede se
intendevi riprendere o creare un nuovo piano.

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

Le opzioni valgono solo per questa ispezione: non vengono salvate e non fanno
committare nulla. Dove non ne dai, i default sono `full-autonomous:true` e WIP
on. L'unica differenza visibile è come si risolve una scelta tra candidati: con
`true` Onboard non ti fa domande (decide agent-1 e il report elenca la scelta
come decisione autonoma), con `false` può lasciarti la scelta nel report.

### ON-01 · nessuna opzione

```text
/plan-execute-verify onboard
```

**Cosa fa:** Mappa il repository e i suoi piani, mostra a che punto è il lavoro
e suggerisce il comando successivo.

**Cosa aspettarsi:** Scrive solo `docs/onboarding.md`, non committato. Non tocca
codice o piani e non avvia nulla. Con il default `true` non ti fa domande: se
deve scegliere tra candidati (qui il piano 003 e il bug B-A002 di 000_adhoc),
decide agent-1 e il report elenca la scelta come decisione autonoma.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

**Cosa aspettarsi:** `true` è già il default. Onboard non fa mai commit e non
avvia lavoro, quindi autonomia e WIP non hanno effetto, e non viene salvato
nulla. Una scelta tra candidati la prende agent-1 e il report la elenca come
decisione autonoma.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

**Cosa fa:** Come senza opzioni: l'opzione è accettata e Onboard fa le stesse
cose; cambia solo come si risolve una scelta tra candidati.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto sul lavoro, e non viene salvato nulla. Con
`false` una scelta tra candidati (qui il piano 003 e il bug B-A002 di
000_adhoc) non la prende agent-1: te la lascia nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; nessun effetto:
  Onboard ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

**Cosa aspettarsi:** WIP on è già il default. Onboard non fa mai commit e non
avvia lavoro, quindi autonomia e WIP non hanno effetto, e non viene salvato
nulla. Con il default `true` non ti fa domande: una scelta tra candidati la
prende agent-1 e il report la elenca come decisione autonoma.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
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
autonomia e WIP non hanno effetto, e non viene salvato nulla: lo spegnimento
del WIP vale solo per questa ispezione e non tocca i piani. Con il default
`true` non ti fa domande: una scelta tra candidati la prende agent-1 e il
report la elenca come decisione autonoma.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
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

**Cosa fa:** Come senza opzioni: le opzioni sono accettate ma non cambiano
nulla.

**Cosa aspettarsi:** Sono entrambi i default. Onboard non fa mai commit e non
avvia lavoro, quindi autonomia e WIP non hanno effetto, e non viene salvato
nulla. Una scelta tra candidati la prende agent-1 e il report la elenca come
decisione autonoma.

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

**Cosa fa:** Come `full-autonomous:false` da solo: le opzioni sono accettate e
Onboard fa le stesse cose; cambia solo come si risolve una scelta tra
candidati.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto sul lavoro, e non viene salvato nulla. Con
`false` una scelta tra candidati (qui il piano 003 e il bug B-A002 di
000_adhoc) non la prende agent-1: te la lascia nel report.

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

**Cosa fa:** Come senza opzioni: le opzioni sono accettate ma non cambiano
nulla.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto, e non viene salvato nulla: lo spegnimento
del WIP vale solo per questa ispezione e non tocca i piani. Una scelta tra
candidati la prende agent-1 e il report la elenca come decisione autonoma.

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

**Cosa fa:** Come `full-autonomous:false` da solo: le opzioni sono accettate e
Onboard fa le stesse cose; cambia solo come si risolve una scelta tra
candidati.

**Cosa aspettarsi:** Onboard non fa mai commit e non avvia lavoro, quindi
autonomia e WIP non hanno effetto sul lavoro, e non viene salvato nulla: lo
spegnimento del WIP vale solo per questa ispezione e non tocca i piani. Con
`false` una scelta tra candidati (qui il piano 003 e il bug B-A002 di
000_adhoc) non la prende agent-1: te la lascia nel report.

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

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
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

**Cosa fa:** Onboarding normale che finisce, report compreso, entro le 17:30.

**Cosa aspettarsi:** L'onboarding è breve e di sola lettura. La deadline è
vincolante: il limite di lavoro è le 17:30 meno una riserva di almeno 10 minuti
e non parte nessuna lettura che lo supererebbe. Il report esce prima delle
17:30 e non c'è altro da salvare oltre a ciò che `docs/onboarding.md` già
contiene. Se l'ispezione non basta, si ferma senza scrivere altro e senza
commit, nemmeno di handoff, e il report lo dice; rilancia `onboard` più tardi.
La deadline vale solo per questa run e non viene salvata.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; nessun effetto: Onboard
  ispeziona soltanto)
- Commit WIP: on (default; nessun effetto)
- Potenza degli esecutori: non usata: ogni piano mantiene il proprio livello
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; solo per
  ispezionare)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, vincolante, solo per questa
  run (dal tuo comando)
- Obiettivo: tutti i piani e i ledger ad-hoc, come inventario (nessun piano
  indicato)
- Dove si ferma: dopo il report; non avvia mai il lavoro suggerito; in ogni caso
  entro le 17:30, report compreso
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

## Plan

```text
/plan-execute-verify [<opzioni>] plan <descrizione>
```

Plan progetta una funzionalità prima di scrivere codice: studia il repository,
approfondisce le domande aperte e scrive un piano a fasi in
`docs/plans/<NNN>_plan-<Nome>/` (panoramica, file di fase, `STATE.md`). Non
scrive codice di produzione, non fa mai commit e non avvia l'esecuzione. Le
opzioni date qui diventano i default del piano per le run successive: Plan
scrive sempre nel §3 di `STATE.md` i valori risolti, quindi un piano nuovo
salva `full-autonomous:true` e commit WIP attivi, salvo che tu dica altro.

Con l'autonomia `true` (il default) Plan non ti chiede nulla: ogni scelta che
altrimenti toccherebbe a te la decide agent-1 come decisione autonoma `D<n>`
(alternative, motivazione, rischio, controllo che smaschererebbe una scelta
sbagliata, come tornare indietro). Il report le elenca tutte e la run si ferma
al piano pronto. Con `false` Plan ti fa le domande come prima e si ferma a
quella a cui solo tu puoi rispondere. Puoi anche omettere la parola `plan`:
basta la descrizione.

### PL-01 · nessuna opzione

```text
/plan-execute-verify plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano con tutti i default, senza farti domande.

**Cosa aspettarsi:** Le scelte ancora aperte le prende agent-1 come decisioni
autonome `D<n>`, elencate nel report; la run si ferma al piano pronto. Il §3
del piano 004 registra autonomia `true`, commit WIP on ed esecutori `low`. Un
successivo `execute 004` senza opzioni va fino in fondo, senza fermarsi dopo
ogni fase, con commit a ogni sotto-fase, chiusura di fase e chiusura del piano
e commit WIP ai checkpoint. Plan non scrive codice e non fa mai commit; il
report suggerisce il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano senza farti domande e registra questa scelta come
suo default.

**Cosa aspettarsi:** Come PL-01, perché `true` è anche il default: decisioni
autonome `D<n>` nel report e stop al piano pronto. La differenza è che il
valore è registrato come tuo. Un successivo `execute 004` senza opzioni esegue
tutto il piano senza fermarsi dopo ogni fase e committa ogni unità completata.
Plan non scrive codice e non fa mai commit; il report suggerisce il comando per
committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano, ti chiede ciò che solo tu puoi decidere e salva
`false` come suo default.

**Cosa aspettarsi:** Se resta una domanda su requisiti, compromessi visibili o
autorità, la run si ferma lì con le opzioni e una raccomandazione; le unità che
ne dipendono restano BLOCKED finché non rispondi. Se non resta nulla da
chiedere, il piano arriva pronto. Le scelte tecniche le fa comunque il
supervisore. Un successivo `execute 004` senza opzioni si ferma dopo la
chiusura di ogni fase (P<N>); i commit WIP sono on (default), quindi unità
completate, chiusure di fase e checkpoint vengono committati come WIP. Plan non
scrive codice e non fa mai commit; il report suggerisce il comando per
committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; salvata come default
  del piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
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

**Cosa fa:** Crea il piano senza farti domande e registra i commit WIP come suo
default.

**Cosa aspettarsi:** Come PL-01, perché i commit WIP sono già on di default:
decisioni autonome `D<n>` nel report e stop al piano pronto. Un successivo
`execute 004` senza opzioni va fino in fondo, committa ogni sotto-fase, chiusura
di fase e chiusura del piano e aggiunge commit WIP ai checkpoint. Plan non
scrive codice e non fa mai commit; il report suggerisce il comando per
committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano senza farti domande e salva i commit WIP spenti come
suo default.

**Cosa aspettarsi:** Decisioni autonome `D<n>` nel report e stop al piano
pronto. Un successivo `execute 004` senza opzioni va fino in fondo e committa
ogni sotto-fase, chiusura di fase e chiusura del piano, ma non fa commit WIP ai
checkpoint: `--no-wip-commit` spegne solo quelli, non i commit di
completamento. Plan non scrive codice e non fa mai commit; il report suggerisce
il comando per committare i file del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: off (dal tuo comando; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano senza farti domande e registra come tue entrambe le
scelte.

**Cosa aspettarsi:** Entrambi i valori coincidono con i default, quindi la run è
come PL-01: decisioni autonome `D<n>` nel report e stop al piano pronto. Un
successivo `execute 004` senza opzioni va fino in fondo, committa ogni
sotto-fase, chiusura di fase e chiusura del piano e aggiunge commit WIP ai
checkpoint. Plan non scrive codice e non fa mai commit; il report suggerisce il
comando per committare i file del piano.

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
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano, ti chiede ciò che solo tu puoi decidere e salva
entrambe le scelte come suoi default.

**Cosa aspettarsi:** Come PL-03, la run si ferma a ogni domanda a cui solo tu
puoi rispondere, con le unità dipendenti BLOCKED finché non rispondi. Un
successivo `execute 004` senza opzioni si ferma dopo la chiusura di ogni fase;
committa come WIP le unità completate e le chiusure di fase, più i checkpoint.
Plan non scrive codice e non fa mai commit; il report suggerisce il comando per
committare i file del piano.

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

**Cosa fa:** Crea il piano senza farti domande e registra come tue entrambe le
scelte.

**Cosa aspettarsi:** Decisioni autonome `D<n>` nel report e stop al piano
pronto. Un successivo `execute 004` senza opzioni va fino in fondo e committa
ogni sotto-fase, chiusura di fase e chiusura del piano, senza commit WIP.
Plan non scrive codice e non fa mai commit; il report suggerisce il comando per
committare i file del piano.

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
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano, ti chiede ciò che solo tu puoi decidere e salva
entrambe le scelte come suoi default.

**Cosa aspettarsi:** Come PL-03, la run si ferma a ogni domanda a cui solo tu
puoi rispondere, con le unità dipendenti BLOCKED finché non rispondi. Un
successivo `execute 004` senza opzioni si ferma dopo la chiusura di ogni fase e
non fa alcun commit. Plan non scrive codice e non fa mai commit; il report
suggerisce il comando per committare i file del piano.

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

**Cosa aspettarsi:** Molte unità piccole (di solito 3-6 sotto-fasi per fase) con
istruzioni passo passo ed esempi già pronti per le parti difficili. Autonomia e
commit WIP restano ai default: nessuna domanda, decisioni autonome `D<n>` nel
report e stop al piano pronto.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Scrive il piano per modelli esecutori di livello medio.

**Cosa aspettarsi:** Meno unità (di solito 2-4 sotto-fasi per fase), con
contratti e passi precisi; l'esecutore completa i dettagli di routine. Autonomia
e commit WIP restano ai default: nessuna domanda, decisioni autonome `D<n>` nel
report e stop al piano pronto.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `medium` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Scrive il piano per modelli esecutori forti.

**Cosa aspettarsi:** Unità più grandi descritte dal risultato (di solito 1-3
sotto-fasi per fase); l'esecutore decide il design interno e lo registra,
mentre interfacce, test e regole restano fissati dal supervisore. Usalo solo se
tutti gli esecutori sono forti. Autonomia e commit WIP restano ai default:
nessuna domanda, decisioni autonome `D<n>` nel report e stop al piano pronto.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `high` (dal tuo comando; salvata nel piano 004; la
  cambia solo una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano e salva questo elenco di agenti.

**Cosa aspettarsi:** agent-1 (opus) progetta, rivede e approva, e decide le
scelte aperte come decisioni autonome `D<n>`, elencate nel report; le unità
vanno ad agent-2 (sonnet) e agent-3 (haiku). La run si ferma al piano pronto.
Le run successive usano questo elenco, salvo che tu ne indichi un altro.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; salvati
  nel piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide agent-1
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Crea il piano con un solo modello per tutti i ruoli.

**Cosa aspettarsi:** my-model pianifica, implementa e rivede il proprio lavoro;
le revisioni sono segnate come self-review. Le scelte aperte le decide lo stesso
modello nel ruolo di agent-1, come decisioni autonome `D<n>` elencate nel
report. La run si ferma al piano pronto.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; salvati nel piano 004)
- Deadline: nessuna (default)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto; non ti chiede nulla, le scelte aperte
  le decide my-model
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

### PL-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 plan aggiungi limiti di richieste per utente
```

**Cosa fa:** Pianifica normalmente; al taglio, almeno 10 minuti prima delle
17:30, salva la bozza e si ferma.

**Cosa aspettarsi:** La deadline è vincolante con qualsiasi impostazione:
nessuna ricerca, revisione o decisione parte se finirebbe oltre il taglio, e
il report è pronto entro le 17:30. La bozza (ricerca e pianificazione, con
roster e impostazioni) resta non committata: Plan non fa mai commit, nemmeno
all'handoff. Il report suggerisce `resume 004`, che non ripete l'opzione. Se il
piano è pronto prima del taglio, la run termina normalmente, con le decisioni
autonome `D<n>` nel report. La deadline non viene salvata nel §3 del piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default; salvata come default del
  piano 004)
- Commit WIP: on (default; salvati come default del piano 004)
- Potenza degli esecutori: `low` (default; salvata nel piano 004; la cambia solo
  una revisione del piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; salvati nel
  piano 004)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: un nuovo piano, numero 004, in `docs/plans/004_plan-<Nome>/`
- Dove si ferma: quando il piano è pronto, senza chiederti nulla; in ogni caso
  entro le 17:30, con un taglio di almeno 10 minuti prima
- Commit fatti da questa run: nessuno: questa modalità non fa mai commit

## Execute

```text
/plan-execute-verify [<opzioni>] execute [<piano>] [<fase o sotto-fase>]
```

Execute implementa un piano esistente unità per unità, con test e revisioni, e
tiene aggiornato `STATE.md`. Senza fase esegue tutto il piano; con una fase
(`execute 003 phase_02`, `execute 003 1.2`) resta al suo interno. Lo stesso
selettore su un'esecuzione già in corso (`RUNNING`) o bloccata la continua, non
la sostituisce: qui il piano 003 ha un'esecuzione in corso, fermata da un
handoff prima della sotto-fase 2.1, e ogni caso la riprende da lì. Un selettore
diverso la sostituirebbe (con `false` te lo chiede prima, con `true` decide da
solo e lo annota in `history.md`). Le opzioni date qui valgono per questa
esecuzione: `resume` le riusa, e non cambiano mai i default del piano. Con
`full-autonomous:true` (il default, anche nel piano 003) l'esecuzione attraversa
tutto l'ambito senza fermarsi alle fasi; con `false` si ferma dopo ogni chiusura
di fase.

### EX-01 · nessuna opzione

```text
/plan-execute-verify execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, con le
impostazioni salvate del piano 003.

**Cosa aspettarsi:** L'esecuzione salvata del piano 003 è l'intero piano e il
selettore è lo stesso: la continua dalla 2.1, non la sostituisce. Non si ferma
tra una sotto-fase e l'altra né tra una fase e l'altra: chiude ogni fase e poi
la chiusura del piano. Fa un commit a ogni sotto-fase, chiusura di fase e
chiusura del piano, più commit WIP ai checkpoint; nessun push. Si ferma prima
solo per un blocco reale, un handoff, una deadline o la fine della sessione. Le
domande diventano decisioni autonome di agent-1, elencate nel report, che arriva
una volta sola alla fine con il blocco Continue/Stop.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, senza
pause tra le fasi.

**Cosa aspettarsi:** Come EX-01: `true` è già il valore del piano, quindi cambia
solo da dove viene. Commit a ogni sotto-fase, chiusura di fase e chiusura del
piano, più commit WIP ai checkpoint; nessun push. Le domande diventano decisioni
autonome, elencate nel report. `resume` mantiene queste opzioni per questa
esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 e si ferma dopo la
chiusura della fase 2 (P2).

**Cosa aspettarsi:** Le sotto-fasi della fase 2 vanno una dopo l'altra senza
pause, poi la chiusura P2 con i suoi controlli completi; a quel punto salva un
checkpoint, mostra il report e si ferma (non è un handoff, quindi nessun commit
di handoff). `resume 003` continua dalla fase 3. Se serve una decisione che solo
tu puoi prendere, si ferma e te la chiede. Il WIP resta on dal piano, quindi
ogni sotto-fase e P2 vengono comunque committate, più commit WIP ai checkpoint;
nessun push. `resume` mantiene queste opzioni per questa esecuzione; i default
del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: dopo la chiusura della fase 2 (P2), o prima a un blocco reale
  o a una decisione che solo tu puoi prendere
- Commit fatti da questa run: uno a ogni sotto-fase e alla chiusura P2, più
  commit WIP ai checkpoint

### EX-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, senza
pause tra le fasi, con i commit WIP.

**Cosa aspettarsi:** Come EX-01: il piano ha già il WIP on, quindi cambia solo
da dove viene. Commit a ogni sotto-fase, chiusura di fase e chiusura del piano,
più commit WIP ai checkpoint; nessun push. Le domande diventano decisioni
autonome, elencate nel report. `resume` mantiene queste opzioni per questa
esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, senza
pause tra le fasi e senza commit WIP.

**Cosa aspettarsi:** L'autonomia resta `true` dal piano, quindi non si ferma
alle fasi. Committa ogni parte finita (sotto-fase, chiusura di fase, chiusura
del piano) ma non salva il lavoro in corso ai checkpoint: finché un'unità non
chiude, le sue modifiche restano solo su disco. Nessun push. Le domande
diventano decisioni autonome, elencate nel report. `resume` mantiene queste
opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano; nessun commit WIP

### EX-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, senza
pause tra le fasi, con i commit WIP.

**Cosa aspettarsi:** Come EX-01, con entrambe le impostazioni date da te. Commit
a ogni sotto-fase, chiusura di fase e chiusura del piano, più commit WIP ai
checkpoint; nessun push. Le domande diventano decisioni autonome, elencate nel
report. `resume` mantiene queste opzioni per questa esecuzione; i default del
piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 e si ferma dopo la
chiusura della fase 2 (P2), committando.

**Cosa aspettarsi:** Come EX-03, con entrambe le impostazioni date da te: le
sotto-fasi della fase 2 vanno senza pause, poi la chiusura P2, il checkpoint e
il report, e si ferma (nessun commit di handoff). `resume 003` continua dalla
fase 3. Se serve una decisione che solo tu puoi prendere, si ferma e te la
chiede. Commit a ogni sotto-fase e a P2, più commit WIP ai checkpoint; nessun
push. `resume` mantiene queste opzioni per questa esecuzione; i default del
piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: on (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: dopo la chiusura della fase 2 (P2), o prima a un blocco reale
  o a una decisione che solo tu puoi prendere
- Commit fatti da questa run: uno a ogni sotto-fase e alla chiusura P2, più
  commit WIP ai checkpoint

### EX-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, senza
pause tra le fasi e senza commit WIP.

**Cosa aspettarsi:** Come EX-05, con entrambe le impostazioni date da te.
Committa ogni parte finita (sotto-fase, chiusura di fase, chiusura del piano)
ma non salva il lavoro in corso ai checkpoint. Nessun push. Le domande
diventano decisioni autonome, elencate nel report. `resume` mantiene queste
opzioni per questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano; nessun commit WIP

### EX-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 e si ferma dopo la
chiusura della fase 2 (P2), senza committare nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Le sotto-fasi della fase 2 vanno senza pause, poi la
chiusura P2, il checkpoint e il report, e si ferma. Con l'autonomia `false` e
il WIP off nessun commit è autorizzato: le modifiche e i file del piano restano
non committati, e la riga Fermati del report rimanda a `handoff`, l'unico che
farebbe comunque il suo commit, unità per unità. Se serve una decisione che solo
tu puoi prendere, si ferma e te la chiede. `resume` mantiene queste opzioni per
questa esecuzione; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; mantenuta da `resume`
  per questa esecuzione)
- Commit WIP: off (dal tuo comando; mantenuti da `resume` per questa esecuzione)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: dopo la chiusura della fase 2 (P2), o prima a un blocco reale
  o a una decisione che solo tu puoi prendere
- Commit fatti da questa run: nessuno: le modifiche restano non committate

### EX-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003 e continua l'esecuzione dalla 2.1.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003 e continua l'esecuzione dalla 2.1.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute 003
```

**Cosa fa:** Rifiutato: solo Plan accetta `executor-power`.

**Cosa aspettarsi:** Non parte nulla. Ripeti il comando senza l'opzione: la run
usa il livello salvato del piano 003 e continua l'esecuzione dalla 2.1.

**Impostazioni di questa run:**

Nessuna: il comando viene rifiutato prima di fare qualsiasi cosa.

Senza quell'opzione, lo stesso comando usa:

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, con gli
agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. Questo elenco sostituisce quello salvato nel
piano 003. Il resto è come EX-01: nessuna pausa tra le fasi, commit a ogni
sotto-fase, chiusura di fase e chiusura del piano, più commit WIP ai
checkpoint; nessun push. Le domande diventano decisioni autonome, elencate nel
report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando;
  sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine, con un
solo modello per tutto.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Sostituisce l'elenco salvato nel
piano 003. Il resto è come EX-01: nessuna pausa tra le fasi, commit a
ogni sotto-fase, chiusura di fase e chiusura del piano, più commit WIP ai
checkpoint; nessun push. Le domande diventano decisioni autonome, elencate nel
report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; sostituisce quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: solo a piano completo (chiusura `PLAN`), a un blocco reale, a
  un handoff o a una deadline; mai tra una fase e l'altra
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint

### EX-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alle 17:30 al
massimo, poi si ferma in modo ordinato.

**Cosa aspettarsi:** La deadline vale sempre, anche con `full-autonomous:true`.
Lavora senza pause tra le fasi, ma non inizia nulla che possa finire oltre il
limite: le 17:30 meno una riserva di almeno 10 minuti. A quel punto chiude
l'unità in corso solo se bastano circa 10 minuti; altrimenti si ferma al passo
successivo, senza lasciare file a metà. Salva lo stato, fa un commit di handoff
per il codice rimasto aperto (nessun commit vuoto) e mostra il comando di
ripresa, `resume 003`, entro le 17:30. Le unità chiuse prima del limite restano
committate come negli altri casi (commit a ogni sotto-fase e chiusura di fase,
più commit WIP ai checkpoint). Se il piano finisce prima del limite, termina
normalmente, senza handoff. Un `resume` successivo non eredita la deadline e non
ripete opzioni.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: l'intero piano 003 (nessuna fase indicata), da dove si era
  fermato: sotto-fase 2.1
- Dove si ferma: a piano completo, a un blocco reale, o al limite della
  deadline; in ogni caso entro le 17:30
- Commit fatti da questa run: uno a ogni sotto-fase, chiusura di fase e
  chiusura del piano, più commit WIP ai checkpoint; alla deadline, un commit di
  handoff per il codice non finito

## Execute verify

```text
/plan-execute-verify [<opzioni>] execute verify [<piano>] [<report>]
```

Execute verify applica le correzioni elencate in un report di audit (di default
il più recente del piano) e ricontrolla le fasi coinvolte. Applica solo quelle
correzioni, non nuovo lavoro del piano. Indica un ID di report, per esempio
`execute verify 003 V002`, per sceglierne un altro. In questo esempio il piano
003 ha un'esecuzione ancora in corso: un `execute 003` fermato con `handoff`
dopo la fase 1, con prossima unità 2.1, nessuna unità aperta e nessun codice non
committato. Le correzioni non sostituiscono mai quell'esecuzione: girano come
passaggio a sé accanto a essa, le opzioni date qui restano solo su quel
passaggio, e l'esecuzione del piano 003 resta registrata con prossima unità
2.1. Non c'è nulla da chiudere prima. Finite le correzioni, `resume 003` la
continua da lì; un passaggio interrotto da uno stop o da una deadline viene
prima finito da `resume 003`.

### EV-01 · nessuna opzione

```text
/plan-execute-verify execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente con
le impostazioni salvate del piano 003, senza chiederti nulla.

**Cosa aspettarsi:** L'agente lascia com'è l'esecuzione salvata del piano 003
(prossima unità 2.1) e applica le correzioni READY di V001, ognuna con
la sua validazione mirata; una correzione che tocca una fase già chiusa la
riapre, e alla chiusura rifà i controlli completi e la revisione. Commit
locali, mai pushati: uno per ogni correzione completata e per ogni chiusura di
fase riaperta, più commit WIP ai checkpoint. Le correzioni BLOCKED e i rilievi
che solo tu puoi accettare restano aperti e finiscono nel report. Si ferma
solo quando le correzioni pronte sono finite o per un blocco reale.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute verify 003
```

**Cosa fa:** Come EV-01, ma con l'autonomia scritta nel comando: applica le
correzioni pronte senza pause tra le fasi, accanto all'esecuzione salvata.

**Cosa aspettarsi:** L'esecuzione salvata del piano 003 resta com'è. I commit
sono locali e mai pushati: uno per ogni correzione completata e fase
ricontrollata, più commit WIP ai checkpoint (WIP è on nel piano 003). Si ferma
prima solo per un blocco reale, una richiesta di stop o una deadline. Queste
opzioni restano valide finché proseguono queste correzioni; i default del piano
non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente accanto
all'esecuzione salvata, e si ferma dopo la chiusura di ogni fase riaperta.

**Cosa aspettarsi:** L'esecuzione salvata del piano 003 (prossima unità 2.1)
resta com'è: l'agente applica le correzioni e si ferma dopo la chiusura di ogni
fase riaperta, con un checkpoint e un report; `resume 003` continua da lì. Il
WIP è on nel piano 003, quindi ogni correzione completata e ogni chiusura di
fase riaperta vengono committate, più commit WIP ai checkpoint. I commit sono
locali e mai pushati. Queste opzioni restano valide finché proseguono queste
correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente senza
pause tra le fasi, con i commit WIP scritti nel comando.

**Cosa aspettarsi:** Il piano 003 ha già WIP on, quindi il comportamento è
quello di EV-01, e l'esecuzione salvata del piano 003 resta com'è. I commit
sono locali e mai pushati: uno per ogni correzione completata e fase
ricontrollata, più commit WIP ai checkpoint. Queste opzioni restano valide
finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente senza
pause tra le fasi, committando solo ciò che è finito, senza commit WIP.

**Cosa aspettarsi:** L'autonomia resta `true` dal piano 003, e
l'esecuzione salvata del piano 003 resta com'è. I commit sono locali e mai
pushati: uno per ogni correzione completata e fase ricontrollata, nessuno ai
checkpoint. Queste opzioni restano valide finché proseguono queste correzioni;
i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: off (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata;
  nessun commit WIP

### EV-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente senza
pause tra le fasi, con autonomia e commit WIP scritti nel comando.

**Cosa aspettarsi:** Come EV-04: sia l'autonomia sia il WIP coincidono con il
piano 003, ma qui li hai scritti tu. L'esecuzione salvata del piano 003 resta
com'è. I commit sono locali e mai pushati: uno per ogni correzione completata
e fase ricontrollata, più commit WIP ai checkpoint. Si ferma prima solo per un
blocco reale, una richiesta di stop o una deadline. Queste opzioni restano
valide finché proseguono queste correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: on (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente accanto
all'esecuzione salvata, e si ferma dopo la chiusura di ogni fase riaperta, con
commit WIP.

**Cosa aspettarsi:** L'esecuzione salvata del piano 003 (prossima unità 2.1)
resta com'è: l'agente applica le correzioni di V001 e si ferma dopo la chiusura
di ogni fase riaperta; `resume 003` continua da lì. I commit sono locali e mai
pushati: uno per ogni correzione completata e fase ricontrollata, più commit WIP
ai checkpoint. Queste opzioni restano valide finché proseguono queste
correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: on (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: dopo la chiusura di ogni fase riaperta
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente senza
pause tra le fasi, committando solo ciò che è finito, senza commit WIP.

**Cosa aspettarsi:** Come EV-05, con l'autonomia scritta nel comando.
L'esecuzione salvata del piano 003 resta com'è. I commit sono locali e mai
pushati: uno per ogni correzione completata e fase ricontrollata, nessuno ai
checkpoint. Si ferma prima solo per un blocco reale, una richiesta di stop o
una deadline. Queste opzioni restano valide finché proseguono queste
correzioni; i default del piano non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando)
- Commit WIP: off (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata;
  nessun commit WIP

### EV-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute verify 003
```

**Cosa fa:** Applica le correzioni del report di audit più recente accanto
all'esecuzione salvata, si ferma dopo la chiusura di ogni fase riaperta e non
committa nulla: committi tu quando vuoi.

**Cosa aspettarsi:** L'esecuzione salvata del piano 003 (prossima unità 2.1)
resta com'è: l'agente applica le correzioni di V001 e si ferma dopo la chiusura
di ogni fase riaperta; `resume 003` continua da lì. Con autonomia `false` e WIP
off non c'è nessun commit; solo un handoff fa comunque il suo commit. Queste
opzioni restano valide finché proseguono queste correzioni; i default del piano
non cambiano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando)
- Commit WIP: off (dal tuo comando)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni di V001, il report di audit più recente del piano 003
  (nessun report indicato)
- Dove si ferma: dopo la chiusura di ogni fase riaperta
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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente con
gli agenti che indichi, senza chiederti nulla.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. Questo elenco sostituisce quello salvato nel
piano 003. L'autonomia resta `true` dal piano 003: le correzioni girano senza
pause tra le fasi, accanto all'esecuzione salvata. Commit per ogni correzione
completata e fase ricontrollata, più commit WIP ai checkpoint.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando;
  sostituiscono quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente con un
solo modello per tutto, senza chiederti nulla.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Sostituisce l'elenco salvato nel
piano 003. L'autonomia resta `true`
dal piano 003: le correzioni girano senza pause tra le fasi, accanto
all'esecuzione salvata. Commit per ogni correzione
completata e fase ricontrollata, più commit WIP ai checkpoint.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; sostituisce quelli salvati nel piano 003)
- Deadline: nessuna (default)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint

### EV-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute verify 003
```

**Cosa fa:** Applica le correzioni pronte del report di audit più recente fino
alle 17:30 al massimo, poi si ferma in modo ordinato.

**Cosa aspettarsi:** La deadline vale sempre: l'agente non inizia nulla che
superi le 17:30 meno un margine di almeno 10 minuti, chiude l'unità in corso
solo se ci sta, altrimenti si ferma al primo punto sicuro. Salva lo stato, fa un
commit di handoff per il codice non finito, e il report con il comando di
ripresa `resume 003` è pronto entro le 17:30. L'autonomia resta `true` dal
piano 003 e l'esecuzione salvata resta com'è. Le correzioni di V001 non
finite restano aperte con il loro checkpoint. Se il lavoro finisce prima,
termina normalmente. Il `resume` non ripete la deadline.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: le correzioni pronte (READY) di V001, il report di audit più
  recente del piano 003 (nessun report indicato)
- Dove si ferma: quando le correzioni pronte sono finite, o a un blocco reale;
  in ogni caso entro le 17:30
- Commit fatti da questa run: ogni correzione completata e fase ricontrollata,
  più un commit WIP a rotazione a ogni checkpoint; alla deadline, un commit di
  handoff per il codice non finito

## Task

```text
/plan-execute-verify [<opzioni>] task <descrizione>
```

Task fa una piccola modifica. Prima di toccare il codice, agent-1 scrive o
controlla un breve piano della modifica (il mini-piano) e lo salva in
`docs/plans/000_adhoc/tasks.md`, o nel ledger del piano se la richiesta ne
nomina uno. Con `full-autonomous:true`, il default (anche in 000_adhoc), non c'è
nessuno stop per l'approvazione: agent-1 controlla comunque il mini-piano, poi
il task va avanti fino in fondo. Le domande che con `false` faresti tu
diventano decisioni autonome di agent-1, elencate nel report. Una richiesta più
grande di una sola unità non resta un piccolo task: con `true` viene
pianificata ed eseguita nella stessa run, limitata alla modifica richiesta, e il
report dichiara la conversione; con `false` la run si ferma al piano pronto. Con
`full-autonomous:false`, invece, la run si ferma una volta dopo il mini-piano
perché tu lo legga: approvi rispondendo nella stessa sessione o con `resume
000_adhoc T-A004`; rifiuti dicendolo o segnando la voce `WITHDRAWN`. Tutto ciò
che segue `task` è la descrizione, anche testo come `--json`; solo un testo con
la forma di un'opzione di questa skill, come `--deadline=…`, fa chiedere
conferma all'agente. Un token `full-autonomous:true|false` che chiude la
descrizione vale come opzione.

### TA-01 · nessuna opzione

```text
/plan-execute-verify task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione, senza
fermarsi.

**Cosa aspettarsi:** Nessuno stop per l'approvazione: agent-1 controlla il
mini-piano e il lavoro prosegue. Quando test e revisioni passano, un commit
locale per il task, più commit WIP ai checkpoint (nessun push). Le decisioni
autonome, se ce ne sono, stanno nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione.

**Cosa aspettarsi:** Come TA-01, ma l'autonomia è scritta nel comando invece di
arrivare dal default. Nessuno stop per l'approvazione; un commit locale per il
task e commit WIP ai checkpoint. Le decisioni autonome, se ce ne sono, stanno
nel report. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1 e si ferma per la tua approvazione; dopo l'approvazione
lo implementa con i test.

**Cosa aspettarsi:** Si ferma una volta, con la voce T-A004 in stato `PROPOSED`
e non committata: il report mostra il percorso della voce, un riassunto del
mini-piano e il comando di approvazione. Per approvare rispondi nella stessa
sessione o lancia `resume 000_adhoc T-A004` (un `resume` senza l'ID della voce
non approva). Dopo l'approvazione la run riprende con le impostazioni salvate
nella voce: il WIP è on, quindi il lavoro viene committato anche senza piena
autonomia (commit WIP). Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo il mini-piano, per la tua approvazione; poi
  alla fine della modifica
- Commit fatti da questa run: nessuno prima dell'approvazione (la voce
  `PROPOSED` resta non committata); dopo l'approvazione, commit WIP per il
  lavoro finito e ai checkpoint

### TA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione, senza
fermarsi.

**Cosa aspettarsi:** Come TA-01: il WIP è già on per default, qui lo scrivi tu.
Nessuno stop per l'approvazione; un commit locale per il task e commit WIP ai
checkpoint. Le decisioni autonome, se ce ne sono, stanno nel report. Le opzioni
valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione, senza
fermarsi.

**Cosa aspettarsi:** Nessuno stop per l'approvazione. Disattiva solo i commit
WIP: l'autonomia è `true` per default, quindi a fine lavoro, quando test e
revisioni passano, c'è comunque un commit locale per il task, senza commit WIP
ai checkpoint. Le decisioni autonome, se ce ne sono, stanno nel report. Le
opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato (nessun commit WIP)

### TA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione.

**Cosa aspettarsi:** Come TA-01 con entrambe le opzioni scritte nel comando.
Nessuno stop per l'approvazione; un commit locale per il task e commit WIP ai
checkpoint. Le decisioni autonome, se ce ne sono, stanno nel report. Le opzioni
valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1 e si ferma per la tua approvazione; dopo l'approvazione
lo implementa con i test.

**Cosa aspettarsi:** Si ferma una volta, con la voce T-A004 in stato `PROPOSED`
e non committata: nessun commit in questa run. Per approvare rispondi nella
stessa sessione o lancia `resume 000_adhoc T-A004`. Dopo l'approvazione la run
ripresa committa il lavoro come WIP, anche senza piena autonomia: il task
finito e un commit WIP ai checkpoint. Le opzioni valgono solo per questa run.

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
- Commit fatti da questa run: nessuno prima dell'approvazione (la voce
  `PROPOSED` resta non committata); dopo l'approvazione, commit WIP per il
  lavoro finito e ai checkpoint

### TA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1, poi lo implementa con i test e la documentazione.

**Cosa aspettarsi:** Nessuno stop per l'approvazione. Un commit locale per il
task quando test e revisioni passano, senza commit WIP ai checkpoint. Le
decisioni autonome, se ce ne sono, stanno nel report. Le opzioni valgono solo
per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato (nessun commit WIP)

### TA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Scrive un breve piano della modifica (mini-piano), lo fa
controllare ad agent-1 e si ferma per la tua approvazione; dopo l'approvazione
lo implementa con i test.

**Cosa aspettarsi:** Si ferma una volta, con la voce T-A004 in stato `PROPOSED`
e non committata. Per approvare rispondi nella stessa sessione o lancia `resume
000_adhoc T-A004`. Con autonomia e WIP entrambi disattivati non c'è alcun
commit, né ora né dopo l'approvazione: la modifica resta non committata e la
riga Fermati del report offre `handoff`, che la committa come patch a sé. Le
opzioni valgono solo per questa run.

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Gestisce la modifica con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) controlla il mini-piano e rivede il
risultato. Nessuno stop per l'approvazione; un commit locale per il task e
commit WIP ai checkpoint. L'elenco vale solo per questa run e viene registrato
nella voce del ledger, senza cambiare nulla di un piano.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Un solo modello, my-model, gestisce la modifica da solo.

**Cosa aspettarsi:** Scrive e controlla il proprio mini-piano e rivede il
proprio lavoro; entrambi sono segnati come self-review. Con l'autonomia di
default (`true`) non c'è stop per l'approvazione: la modifica va avanti fino al
commit locale del task, più commit WIP ai checkpoint. Le decisioni autonome, se
ce ne sono, stanno nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica (o a
  un blocco reale)
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint

### TA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 task aggiungi l'opzione --json al comando export
```

**Cosa fa:** Gestisce la modifica e si ferma in modo ordinato entro le 17:30.

**Cosa aspettarsi:** Nessuno stop per l'approvazione. Il punto di taglio è le
17:30 meno una riserva di almeno 10 minuti: non parte nulla che lo supererebbe.
Se il task si chiude prima, finisce normalmente con il suo commit locale. Se
no, si ferma al passo successivo, salva il checkpoint nella voce del ledger, fa
un commit di handoff per il codice non finito e mostra il comando di ripresa,
`resume 000_adhoc T-A004`, entro le 17:30. Il comando non ripete opzioni e la
deadline non passa alla run successiva.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/tasks.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per approvazione; alla fine della modifica; in
  ogni caso entro le 17:30
- Commit fatti da questa run: il task completato, più un commit WIP a rotazione
  a ogni checkpoint; se la deadline interrompe il lavoro, un commit di handoff
  per il codice non finito

## Bug

```text
/plan-execute-verify [<opzioni>] bug <descrizione>
```

Bug corregge un difetto: riproduce il problema, trova la causa, scrive un test
che fallisce, corregge il codice e rilancia i test. Se non riesce a riprodurre
il bug, registra i tentativi e si blocca invece di indovinare un fix. Il
default è `full-autonomous:true`, anche in `000_adhoc`: con `true` non c'è
nessuno stop per l'approvazione, agent-1 convalida comunque causa radice e
mini-piano prima di toccare il codice, il fix completato viene committato in
locale e le decisioni autonome finiscono nel report. Con
`full-autonomous:false` si ferma una volta, per la tua approvazione, dopo
riproduzione, causa radice e mini-piano e prima del test di regressione. Le
voci finiscono in `docs/plans/000_adhoc/bugs.md`, salvo che la richiesta
nomini un piano. In questi esempi il nuovo bug è B-A003; B-A002, lasciato
aperto da una sessione precedente, non viene toccato perché nessun comando lo
nomina.

### BU-01 · nessuna opzione

```text
/plan-execute-verify bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessuno stop per l'approvazione, ma agent-1 convalida
comunque causa radice e mini-piano prima di toccare il codice. Quando test e
revisioni passano, un commit locale per il fix completato, più un commit WIP
ai checkpoint; nessun push. Il report elenca le eventuali decisioni autonome.
Se non riesce a riprodurre il bug, registra i tentativi e si ferma con un
blocco invece di indovinare un fix.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale (per esempio un bug non riproducibile)
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** Lo stesso comportamento del default, ma con `true` scritto
esplicitamente: nessuno stop per l'approvazione, ma agent-1 controlla comunque
prima il mini-piano. Un commit locale per il fix completato quando test e
revisioni passano, più un commit WIP ai checkpoint. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1, poi si ferma e aspetta la tua approvazione; dopo
scrive un test che fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Si ferma una volta, dopo riproduzione, causa radice e
mini-piano e prima del test di regressione. Non tocca il codice: scrive solo la
voce B-A003 `PROPOSED` in `bugs.md`, che resta non committata, quindi in questa
run nessun commit. Il report mostra il percorso della voce, il riassunto del
mini-piano e il comando di approvazione. Per approvare rispondi nella stessa
sessione o lancia `/plan-execute-verify resume 000_adhoc B-A003`: l'ID della
voce è obbligatorio. Dopo l'approvazione, con il WIP attivo di default,
committa il fix completato e un commit WIP ai checkpoint. Le opzioni valgono
solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo riproduzione, causa radice e mini-piano, per
  la tua approvazione e prima del test di regressione; poi alla chiusura del
  bug
- Commit fatti da questa run: nessuno prima dell'approvazione (la voce
  `PROPOSED` resta non committata); dopo l'approvazione, il fix completato più
  un commit WIP a rotazione a ogni checkpoint

### BU-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** L'autonomia resta `true` di default, quindi nessuno stop
per l'approvazione. Committa il fix completato e un commit WIP ai checkpoint.
Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** L'autonomia resta `true` di default, quindi nessuno stop
per l'approvazione. Un solo commit locale per il fix completato: l'opzione
spegne i commit WIP, non quello di completamento. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, senza commit WIP

### BU-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** Entrambe le impostazioni sono esplicite e coincidono con i
default: nessuno stop per l'approvazione, ma agent-1 controlla comunque prima
il mini-piano. Committa il fix completato e un commit WIP ai checkpoint. Le
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
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1, poi si ferma e aspetta la tua approvazione; dopo
scrive un test che fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Si ferma una volta, dopo riproduzione, causa radice e
mini-piano e prima del test di regressione, con la voce B-A003 `PROPOSED` non
committata: in questa run nessun commit. Per approvare rispondi nella stessa
sessione o lancia `/plan-execute-verify resume 000_adhoc B-A003` (l'ID serve).
Dopo l'approvazione committa il fix completato e un commit WIP ai checkpoint.
Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo riproduzione, causa radice e mini-piano, per
  la tua approvazione e prima del test di regressione; poi alla chiusura del
  bug
- Commit fatti da questa run: nessuno prima dell'approvazione (la voce
  `PROPOSED` resta non committata); dopo l'approvazione, il fix completato più
  un commit WIP a rotazione a ogni checkpoint

### BU-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1; senza fermarsi scrive poi un test che fallisce,
corregge il codice e rilancia i test.

**Cosa aspettarsi:** Nessuno stop per l'approvazione, ma agent-1 controlla
comunque prima il mini-piano. Un solo commit locale per il fix completato
quando test e revisioni passano, senza commit WIP. Le opzioni valgono solo per
questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, senza commit WIP

### BU-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Riproduce il bug, ne trova la causa, scrive un mini-piano e lo fa
controllare ad agent-1, poi si ferma e aspetta la tua approvazione; dopo
scrive un test che fallisce, corregge il codice e rilancia i test.

**Cosa aspettarsi:** Si ferma una volta, dopo riproduzione, causa radice e
mini-piano e prima del test di regressione, con la voce B-A003 `PROPOSED` non
committata. Per approvare rispondi nella stessa sessione o lancia
`/plan-execute-verify resume 000_adhoc B-A003` (l'ID serve). Dopo
l'approvazione scrive test e fix, ma con `false` e WIP off non committa mai: la
modifica resta non committata e la riga Fermati del report offre `handoff`, che
la committa come patch a sé. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: una volta, dopo riproduzione, causa radice e mini-piano, per
  la tua approvazione e prima del test di regressione; poi alla chiusura del
  bug
- Commit fatti da questa run: nessuno: né la voce `PROPOSED` né, dopo
  l'approvazione, la modifica vengono committate

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

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

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Gestisce il fix con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) convalida causa radice e mini-piano prima
di toccare il codice e rivede il risultato. Nessuno stop per l'approvazione:
autonomia e WIP restano quelli di default, quindi un commit locale per il fix
completato e un commit WIP ai checkpoint. L'elenco vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Un solo modello, my-model, gestisce il fix da solo.

**Cosa aspettarsi:** Scrive e convalida il proprio mini-piano insieme alla
causa radice e rivede il proprio lavoro; entrambi i passaggi sono segnati come
self-review. Con l'autonomia di default non si ferma per la tua approvazione:
un commit locale per il fix completato e un commit WIP ai checkpoint.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o
  prima solo per un blocco reale
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint

### BU-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 bug export termina con codice 0 se manca la configurazione
```

**Cosa fa:** Gestisce il fix e si ferma in modo ordinato entro le 17:30: la
deadline è vincolante.

**Cosa aspettarsi:** Nessuno stop per l'approvazione. Lavora fino al cutoff
(le 17:30 meno una riserva di almeno 10 minuti) e non avvia nulla che lo
supererebbe. Se il bug si chiude prima, finisce normalmente con il suo commit
di completamento. Altrimenti chiude il passo aperto solo se ci sta, si ferma
al confine del passo successivo, salva un checkpoint nella voce B-A003 (che
resta `OPEN`, con il prossimo passo da verificare) e fa un commit di handoff
con il lavoro non finito. Il report arriva entro le 17:30 con
`/plan-execute-verify resume 000_adhoc B-A003`, un comando che non ripete
nessuna opzione.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: ledger ad-hoc `docs/plans/000_adhoc/bugs.md`, perché la richiesta
  non nomina un piano
- Dove si ferma: nessuno stop per l'approvazione; alla chiusura del bug, o al
  cutoff (le 17:30 meno la riserva) se non è ancora chiuso; il report è
  comunque pronto entro le 17:30
- Commit fatti da questa run: il fix completato, più un commit WIP a rotazione
  a ogni checkpoint; se la deadline interrompe il lavoro, un commit di handoff
  per il codice non finito

## Verify

```text
/plan-execute-verify [<opzioni>] verify [<piano>] [<fase, sotto-fase o voce>]
```

Verify fa l'audit di un piano, o di una sua parte (`verify 003 phase_02`,
`verify 003 1.2`, `verify 000_adhoc T-A004`), rispetto alla sua specifica:
comportamento, test, revisioni, stato e commit. Scrive un report datato con i
problemi trovati e le correzioni pronte; l'audit in sé non tocca mai il codice.

Con `full-autonomous:true`, il default, la run non si ferma al report: lo
committa insieme allo stato (mai codice) e poi applica da sola le correzioni
pronte, come farebbe `execute verify 003 V002`, ma senza un nuovo audit.
L'esecuzione salvata del piano non cambia. Le correzioni bloccate e i finding
che solo tu puoi segnare ACCEPTED restano aperti e vengono riportati; una
domanda che l'audit ti avrebbe fatto diventa una decisione autonoma di agent-1,
elencata nel report. Su `000_adhoc` ogni correzione pronta gira come una voce
Task o Bug. Con `false` non c'è né commit né correzione: il report finisce con
il comando `execute verify 003 V002`, che non viene eseguito. Il report è uno
solo, alla fine della run.

In questo esempio il piano 003 non ha nessuna unità aperta e nessun lavoro non
committato: l'`execute 003` precedente si è fermato con `handoff` prima della
sotto-fase 2.1, e la sua esecuzione salvata (tutto il piano, prossima unità
2.1) è ancora in corso. L'audit quindi non sospende nulla, e `resume 003`
continua da 2.1 anche dopo le correzioni.

### VE-01 · nessuna opzione

```text
/plan-execute-verify verify 003
```

**Cosa fa:** Fa l'audit dell'intero piano 003, committa il report e applica da
sola le correzioni pronte di V002.

**Cosa aspettarsi:** Scrive il report V002 e lo committa: solo file di audit e
stato del piano, mai codice. Subito dopo parte la correzione, senza un nuovo
audit e come farebbe `execute verify 003 V002`: ogni correzione ha la sua
convalida mirata, le fasi riaperte si richiudono con tutti i gate e la
revisione di agent-1, con un commit per ogni correzione completata e per ogni
chiusura di fase riaperta, più commit WIP ai checkpoint. L'esecuzione salvata
del piano 003 non cambia. Le correzioni bloccate e i finding che solo tu puoi
segnare ACCEPTED restano aperti e vengono riportati. Se non ci sono correzioni
pronte, la run finisce dopo il commit dell'audit. Il report è uno solo, alla
fine, con le decisioni autonome e il blocco "Prossimo passo".

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true verify 003
```

**Cosa fa:** Fa l'audit del piano 003, committa il report e applica da sola le
correzioni pronte di V002.

**Cosa aspettarsi:** Identico a VE-01: `true` è già il valore salvato nel piano
003, quindi cambia solo la fonte. L'audit è committato perché l'autonomia è
`true`; il WIP non lo riguarda e aggiunge solo i commit WIP ai checkpoint delle
correzioni.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit e senza correzioni, anche se
il piano salva `true`.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`, e
con `false` nessuna correzione segue. Il WIP non cambia nulla: non committa mai
gli audit. Il report resta non committato e finisce con il comando
`execute verify 003 V002` per applicare le correzioni pronte, che non viene
eseguito.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal piano 003; nessun effetto: gli audit non hanno commit
  WIP e senza correzioni non c'è altro da committare)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo; nessuna correzione segue
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003, committa il report e applica da sola le
correzioni pronte di V002, con il WIP acceso.

**Cosa aspettarsi:** Come VE-01: il piano 003 ha già il WIP acceso, quindi
l'opzione cambia solo la fonte. L'audit è committato perché l'autonomia è
`true` (dal piano), non per il WIP; il WIP aggiunge i commit WIP ai checkpoint
delle correzioni.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal tuo comando; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003, committa il report e applica da sola le
correzioni pronte di V002, senza commit WIP.

**Cosa aspettarsi:** L'audit è committato (l'autonomia è `true`, dal piano) e le
correzioni fanno solo commit di completamento: uno per correzione completata e
uno per ogni chiusura di fase riaperta. `--no-wip-commit` toglie i commit WIP
ai checkpoint, non quelli di completamento. Il resto è come VE-01.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: off (dal tuo comando; per le correzioni niente commit WIP; per
  l'audit non cambia nulla)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; nessun commit WIP; nessun push

### VE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003, committa il report e applica da sola le
correzioni pronte di V002, con il WIP acceso.

**Cosa aspettarsi:** Come VE-04, con entrambe le opzioni scritte nel comando:
audit committato, correzioni con commit di completamento e commit WIP ai
checkpoint, esecuzione salvata invariata.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit e senza correzioni.

**Cosa aspettarsi:** Il WIP non cambia nulla per un audit: un audit si committa
solo con `full-autonomous:true`, e con `false` nessuna correzione segue, quindi
non c'è nemmeno lavoro da salvare come WIP. Il report resta non committato e
finisce con il comando `execute verify 003 V002`, che non viene eseguito.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP e senza correzioni non c'è altro da committare)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo; nessuna correzione segue
- Commit fatti da questa run: nessuno: il report resta non committato

### VE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003, committa il report e applica da sola le
correzioni pronte di V002, senza commit WIP.

**Cosa aspettarsi:** Come VE-05, con entrambe le opzioni scritte nel comando:
audit committato, correzioni con soli commit di completamento, nessun commit
WIP, esecuzione salvata invariata.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; per le correzioni niente commit WIP; per
  l'audit non cambia nulla)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; nessun commit WIP; nessun push

### VE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit verify 003
```

**Cosa fa:** Fa l'audit del piano 003 senza commit e senza correzioni.

**Cosa aspettarsi:** Un audit si committa solo con `full-autonomous:true`, e
con `false` nessuna correzione segue: la run non fa nessun commit. Il report
resta non committato e finisce con il comando `execute verify 003 V002`, che non
viene eseguito.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; nessun effetto: gli audit non hanno commit
  WIP e senza correzioni non c'è altro da committare)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata)
- Dove si ferma: quando l'audit è completo; nessuna correzione segue
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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

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

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku verify 003
```

**Cosa fa:** Fa l'audit del piano 003 con gli agenti che indichi, committa il
report e applica le correzioni pronte di V002 con gli stessi agenti.

**Cosa aspettarsi:** agent-1 (opus) controlla i punti critici dell'audit e
rivede le fasi che le correzioni riaprono. L'elenco vale solo per questa run:
lo trovi nel report e non cambia né il piano 003 né la sua esecuzione salvata.
Per il resto è come VE-01.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report V002 e stato del
  piano, mai codice); un commit per ogni correzione completata e per ogni
  chiusura di fase riaperta; commit WIP ai checkpoint; nessun push

### VE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model verify 000_adhoc B-A002
```

**Cosa fa:** Un solo modello fa l'audit della voce di bug ad-hoc B-A002,
committa il report e applica le correzioni pronte come voci Task o Bug.

**Cosa aspettarsi:** Ogni revisione è una self-review, solo per questa run.
L'audit controlla B-A002 senza sospenderla: la voce resta aperta, con il suo
checkpoint, e il commit dell'audit non include il suo lavoro non committato. Il
commit contiene solo il report, l'indice di verify e il ledger. Poi ogni
correzione pronta gira come una voce Task o Bug del ledger, in ordine di
dipendenze e gravità, senza stop di approvazione, con un commit di
completamento ciascuna e commit WIP ai checkpoint. Una correzione che aspetta
una tua scelta di prodotto diventa una decisione autonoma di agent-1, elencata
nel report.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (default)
- Commit WIP: on (default; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (default per 000_adhoc; un task o bug su un
  piano segue quel piano)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: la voce di bug ad-hoc B-A002, poi le correzioni pronte del suo
  report
- Dove si ferma: quando l'audit è chiuso e le correzioni pronte sono applicate;
  prima solo per un blocco reale o per un tuo `handoff`
- Commit fatti da questa run: il commit dell'audit (report, indice di verify e
  ledger, mai codice); un commit per ogni task o bug di correzione completato;
  commit WIP ai checkpoint; nessun push

### VE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 verify 003
```

**Cosa fa:** Fa l'audit del piano 003 e applica le correzioni pronte, ma si
ferma con un handoff in tempo per le 17:30.

**Cosa aspettarsi:** La deadline è vincolante: il limite di lavoro sono le
17:30 meno una riserva di almeno 10 minuti, e il report è pronto entro le
17:30. Se l'audit si chiude prima del limite, viene committato e la correzione
gira fino al limite; poi chiude l'unità aperta solo se ci sta, altrimenti si
ferma al confine del passo. Fa un commit di handoff per il lavoro di codice non
ancora committato (una correzione di Verify ne ha sempre uno; nessun commit
vuoto), e le correzioni non finite restano aperte con il loro checkpoint. Se
invece l'audit non si chiude in tempo, resta aperto con il checkpoint nel report
e nell'indice, senza commit (un audit non ne fa nemmeno di handoff). Si
continua con il comando `resume` mostrato, per esempio `resume 003 V002`, senza
opzioni.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal piano 003)
- Commit WIP: on (dal piano 003; vale per le correzioni, mai per l'audit)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal piano 003, che usa
  l'elenco di default)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: l'intero piano 003 (nessuna fase o voce indicata), poi le
  correzioni pronte di V002
- Dove si ferma: quando l'audit e le correzioni pronte sono finiti; in ogni caso
  al limite di lavoro, in tempo per le 17:30
- Commit fatti da questa run: il commit dell'audit, se si chiude in tempo; i
  commit delle correzioni completate e WIP ai checkpoint; un commit di handoff
  per il lavoro di codice non ancora committato; nessun commit se l'audit non si
  chiude; nessun push

## Resume

```text
/plan-execute-verify [<opzioni>] resume [<piano>] [<unità>]
```

Resume continua il lavoro interrotto o salvato, senza cambiarlo. Prima
completa il recupero di ciò che era rimasto a metà (un'unità aperta, un commit
pendente, un audit aperto, una bozza di piano), poi continua l'esecuzione
salvata del piano come farebbe `execute`. Con `full-autonomous:true`, il
default dove non c'è un valore registrato, non si ferma a fine sotto-fase né a
fine fase e non ti chiede nulla: ogni domanda diventa una decisione autonoma di
agent-1, che il report elenca. Con `false` si ferma dopo la chiusura della
fase. Indica un'unità per ripartire da quella (`resume 003 1.2`, `resume
000_adhoc T-A004`): con `false` si ferma dopo quell'unità, con `true` va avanti
anche dopo di essa; indicare un task o bug proposto lo approva, mentre
un'unità ancora da fare viene rifiutata (è lavoro nuovo: serve `execute`). Se
il lavoro era stato fermato con `handoff`, `resume` toglie lo stop; la deadline
di quella run non passa alla nuova. Le opzioni date qui valgono solo per questa
run; altrimenti il lavoro mantiene le impostazioni con cui era partito. Ogni
Resume termina con il blocco Next.

Negli esempi con `resume 003`, il piano 003 era stato fermato con `handoff`
dopo la chiusura della fase 1: nessuna unità è aperta e nessun codice è da
committare, quindi non c'è nulla da recuperare e il lavoro riparte dalla
sotto-fase 2.1. Quel lavoro era partito senza opzioni: autonomia `true` e
commit WIP on.

### RE-01 · nessuna opzione

```text
/plan-execute-verify resume 003
```

**Cosa fa:** Recupera il lavoro registrato del piano 003 (qui non c'è nulla da
recuperare), poi continua l'esecuzione salvata dalla sotto-fase 2.1 fino alla
fine del piano, con le impostazioni registrate su quel lavoro.

**Cosa aspettarsi:** Va avanti senza pause tra sotto-fasi e fasi e senza
chiederti nulla: le eventuali domande diventano decisioni autonome di agent-1,
elencate nel report. Fa commit a ogni sotto-fase, chiusura di fase e chiusura
del piano, più commit WIP ai checkpoint; nessun push. Si ferma prima solo per
un blocco reale, una richiesta di stop, una deadline o la fine della sessione
dell'host. Il bug ad-hoc B-A002 resta com'è: `resume 003` riguarda solo il
piano 003. Il report finale termina con il blocco Next.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, senza pause tra le fasi.

**Cosa aspettarsi:** Lo stesso di RE-01: il lavoro registrato era già partito
con autonomia `true`, quindi l'opzione conferma il valore senza cambiarlo.
Commit a ogni sotto-fase, chiusura di fase e chiusura del piano, più commit WIP
ai checkpoint; nessun push. Le decisioni autonome sono elencate nel report. Il
valore vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 e si ferma dopo la
chiusura della fase 2 (P2).

**Cosa aspettarsi:** Il WIP registrato è on, quindi le sotto-fasi finite e la
chiusura P2 sono committate come commit WIP, più i commit WIP ai checkpoint;
nessun commit di completamento oltre a questi. Se serve una tua decisione si
ferma e te la chiede. Lo stop dopo P2 non è un handoff, quindi non c'è commit
di handoff: l'esecuzione salvata resta in corso e si continua con `resume 003`.
Il valore vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla chiusura della fase 2
- Dove si ferma: dopo la chiusura della fase 2 (P2)
- Commit fatti da questa run: commit WIP per le sotto-fasi finite e per P2,
  più commit WIP ai checkpoint

### RE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, senza pause tra le fasi, con i commit WIP attivi.

**Cosa aspettarsi:** Il lavoro registrato aveva già il WIP on, quindi l'opzione
non cambia nulla: commit a ogni sotto-fase, chiusura di fase e chiusura del
piano, più commit WIP ai checkpoint; nessun push. L'autonomia resta quella
registrata (`true`). Il valore vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, senza pause tra le fasi e senza commit WIP.

**Cosa aspettarsi:** L'opzione disattiva solo i commit WIP ai checkpoint: con
autonomia `true` i commit di completamento restano, a ogni sotto-fase, chiusura
di fase e chiusura del piano. Un'interruzione a metà di un'unità non lascia
quindi un commit WIP. L'autonomia resta quella registrata (`true`), quindi non
si ferma dopo ogni fase. Il valore vale solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano; nessun commit WIP

### RE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, senza pause tra le fasi, con i commit WIP attivi.

**Cosa aspettarsi:** Entrambe le opzioni coincidono con i valori registrati,
quindi la run è uguale a RE-01: commit a ogni sotto-fase, chiusura di fase e
chiusura del piano, più commit WIP ai checkpoint; nessun push. Si ferma prima
solo per un blocco reale, una richiesta di stop o una deadline. Le opzioni
valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 e si ferma dopo la
chiusura della fase 2 (P2), con i commit WIP attivi.

**Cosa aspettarsi:** Le sotto-fasi finite e la chiusura P2 sono committate come
commit WIP, più i commit WIP ai checkpoint; nessun commit di completamento
oltre a questi e nessun push. Lo stop dopo P2 non è un handoff, quindi non c'è
commit di handoff: l'esecuzione salvata resta in corso e si continua con
`resume 003`. Le opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: on (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla chiusura della fase 2
- Dove si ferma: dopo la chiusura della fase 2 (P2)
- Commit fatti da questa run: commit WIP per le sotto-fasi finite e per P2,
  più commit WIP ai checkpoint

### RE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, senza pause tra le fasi e senza commit WIP.

**Cosa aspettarsi:** Come RE-05: commit a ogni sotto-fase, chiusura di fase e
chiusura del piano, nessun commit WIP ai checkpoint e nessun push. Si ferma
prima solo per un blocco reale, una richiesta di stop o una deadline. Le
opzioni valgono solo per questa run.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano; nessun commit WIP

### RE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1, si ferma dopo la
chiusura della fase 2 (P2) e non committa nulla: committi tu quando vuoi.

**Cosa aspettarsi:** Le opzioni valgono solo per questa run, anche se il lavoro
ripreso era registrato con autonomia `true` e WIP on; la volta successiva
tornano le impostazioni registrate. Lo stop dopo P2 non è un handoff:
l'esecuzione salvata resta in corso e si continua con `resume 003`. Con
autonomia `false` e WIP off non c'è nessun commit; ogni unità chiusa viene
registrata come non committata con i suoi tree, così un `handoff` successivo
la committa come patch a sé. Le stesse opzioni su una sola voce del ledger
(`resume 000_adhoc B-A002`) sono mostrate in "Combinare le opzioni".

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando; solo per questa run)
- Commit WIP: off (dal tuo comando; solo per questa run)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla chiusura della fase 2
- Dove si ferma: dopo la chiusura della fase 2 (P2)
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

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

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

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

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

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, con gli agenti che indichi.

**Cosa aspettarsi:** agent-1 (opus) rivede e approva; gli altri agenti
implementano le unità assegnate. L'elenco vale solo per questa run: non cambia
l'elenco salvato né le altre impostazioni dell'esecuzione, che restano quelle
registrate (autonomia `true`, quindi nessuna pausa tra le fasi, e WIP on).
Commit a ogni sotto-fase, chiusura di fase e chiusura del piano, più commit WIP
ai checkpoint.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 opus, agent-2 sonnet, agent-3 haiku (dal tuo comando; solo per
  questa run)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alla fine del
piano, con un solo modello per tutto.

**Cosa aspettarsi:** my-model implementa e rivede il proprio lavoro; le
revisioni sono segnate come self-review. Solo per questa run: le altre
impostazioni restano quelle registrate (autonomia `true`, quindi nessuna pausa
tra le fasi, e WIP on). Commit a ogni sotto-fase, chiusura di fase e chiusura
del piano, più commit WIP ai checkpoint.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: my-model in tutti i ruoli; rivede il proprio lavoro (self-review) (dal
  tuo comando; solo per questa run)
- Deadline: nessuna (default)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1 fino alla fine del piano
- Dove si ferma: quando tutto il piano è finito, o a un blocco reale; nessuna
  pausa tra sotto-fasi e fasi
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint

### RE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 resume 003
```

**Cosa fa:** Continua il piano 003 dalla sotto-fase 2.1 fino alle 17:30 al
massimo, poi si ferma in modo ordinato.

**Cosa aspettarsi:** La deadline è vincolante con qualsiasi impostazione: il
punto di taglio è 17:30 meno una riserva di almeno 10 minuti, e non parte
nessuna unità che lo supererebbe. Finché c'è tempo va avanti senza pause tra le
fasi (autonomia `true`), con commit a ogni sotto-fase, chiusura di fase e
chiusura del piano, più commit WIP ai checkpoint. Al punto di taglio chiude
l'unità aperta solo se bastano circa 10 minuti; altrimenti si ferma al confine
di un passo, salva lo stato, fa un commit di handoff per il codice non
finito (nessun commit vuoto se non c'è nulla da committare) e mostra il report
entro le 17:30 con il comando `resume 003`, senza opzioni da ripetere. Se il
lavoro finisce prima, termina normalmente. Un `resume` successivo non eredita
la deadline.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal lavoro ripreso, avviato senza
  opzioni)
- Commit WIP: on (dal lavoro ripreso)
- Potenza degli esecutori: `low` (livello del piano 003; lo imposta solo Plan)
- Agenti: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (dal lavoro ripreso)
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando)
- Obiettivo: piano 003: prima il lavoro registrato (qui niente da recuperare),
  poi l'esecuzione salvata da 2.1, finché c'è tempo
- Dove si ferma: quando tutto il piano è finito, se succede prima; altrimenti
  al punto di taglio (17:30 meno almeno 10 minuti), con il report entro le
  17:30
- Commit fatti da questa run: a ogni sotto-fase, chiusura di fase e chiusura
  del piano, più commit WIP ai checkpoint; al punto di taglio, un commit di
  handoff per il codice non finito

## Handoff

```text
/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]
```

Handoff ferma il lavoro in modo ordinato ed è sempre onorato: vale con
qualsiasi autonomia, commit WIP, potenza e agenti, e non rifiuta mai una
richiesta di stop. Non avvia nulla di nuovo, finisce l'unità aperta solo se
bastano circa 10 minuti, salva lo stato, fa un commit per il lavoro sul codice
(anche con i commit disattivati), mostra il comando per riprendere e si ferma.
Mandalo durante una run, oppure dai una deadline.

La deadline è vincolante con qualsiasi impostazione: l'agente calcola un orario
di taglio (deadline meno una riserva di almeno 10 minuti), non avvia nulla che
lo superi e chiude stato, commit e report entro la deadline. Lo stop non è più
"al meglio delle possibilità": metti l'orario in cui devi davvero essere fermo e
la riserva la tiene l'agente. Una sessione inattiva, senza run in corso, non ha
lavoro da proseguire, quindi lì la deadline significa handoff immediato; una
sessione che attende un subagente o un comando in background non è inattiva.

Nei casi qui sotto la sessione è inattiva: il piano 003 non ha unità aperte né
codice non committato (il suo scope resta RUNNING, prossima unità 2.1), mentre
`000_adhoc` ha il bug B-A002, ancora OPEN.

### HA-01 · nessuna opzione

```text
/plan-execute-verify handoff
```

**Cosa fa:** Ferma il lavoro adesso, in modo ordinato.

**Cosa aspettarsi:** Non chiede nulla. Su una sessione inattiva tratta, uno
dopo l'altro, tutti i candidati con lavoro aperto, chiusura in sospeso o unità
non committate; mai un lavoro di un'altra sessione attiva. Qui il candidato è
uno solo: `000_adhoc` con B-A002. Il piano 003 non è un candidato. Per B-A002
salva lo stato (checkpoint, la voce resta OPEN, risultato `HANDOFF`), rilascia
la proprietà e fa un commit di handoff solo se c'è codice non committato: mai
un commit vuoto. Il messaggio comincia con
`handoff(request-by-user): 000_adhoc/B-A002 stopped …`. Il report mostra il
comando `resume 000_adhoc B-A002`. Mandato durante una run, fermerebbe quella
run e annullerebbe anche una deadline precedente.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata (Handoff vale con qualsiasi
  autonomia)
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto); in una run, la
  run in corso
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002, anche con i commit disattivati (nessuno se non c'è
  nulla da committare); nessun push. Plan e audit non committano mai in un
  handoff (il report suggerisce il comando), Onboard nulla

### HA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** `true` non cambia nulla: il ciclo di autonomia non
riparte, perché l'handoff ferma la run e vale sopra l'autonomia. Stop immediato
su B-A002, commit di handoff solo se c'è codice non committato, report con
`resume 000_adhoc B-A002`. Il valore non viene salvato da nessuna parte.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Con `false` una run normale chiederebbe e si fermerebbe a
fine fase; Handoff non fa domande, nemmeno sul candidato da trattare: ogni
candidato viene gestito. Stop immediato su B-A002, commit di handoff solo se c'è
codice non committato, report con `resume 000_adhoc B-A002`. Nessuna
impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Il WIP on non aggiunge commit WIP: nessuna run è in corso
e non ci sono checkpoint da committare. Resta un solo commit di handoff, fatto
solo se B-A002 ha codice non committato. Stop immediato, report con
`resume 000_adhoc B-A002`. Nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: on (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un solo commit di handoff per il codice non
  ancora committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Il WIP off non impedisce il commit di handoff: la tua
richiesta esplicita lo autorizza comunque, anche con i commit disattivati. Stop
immediato su B-A002, commit solo se c'è codice non committato, report con
`resume 000_adhoc B-A002`. Nessuna impostazione salvata cambia.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: off (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002, anche con WIP off (nessuno se non c'è nulla); nessun
  push

### HA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit handoff
```

**Cosa fa:** Le due opzioni vengono ignorate e segnalate; lo stop parte subito.

**Cosa aspettarsi:** Né il ciclo di autonomia né i commit WIP ripartono: l'unico
commit è quello di handoff, fatto solo se B-A002 ha codice non committato. Stop
immediato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: on (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit handoff
```

**Cosa fa:** Le due opzioni vengono ignorate e segnalate; lo stop parte subito.

**Cosa aspettarsi:** Nessuna domanda e nessuna sosta "a fine fase": Handoff si
ferma subito. Il commit di handoff c'è solo se B-A002 ha codice non committato,
e non ci sono commit WIP aggiuntivi. Report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: on (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit handoff
```

**Cosa fa:** Le due opzioni vengono ignorate e segnalate; lo stop parte subito.

**Cosa aspettarsi:** Il WIP off non impedisce il commit di handoff, e `true`
non fa continuare il lavoro. Stop immediato su B-A002, commit solo se c'è codice
non committato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `true` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: off (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002, anche con WIP off (nessuno se non c'è nulla); nessun
  push

### HA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit handoff
```

**Cosa fa:** Le due opzioni vengono ignorate e segnalate; lo stop parte subito.

**Cosa aspettarsi:** Anche con `false` e WIP off, che altrove significano "nessun
commit", l'handoff fa il suo commit se B-A002 ha codice non committato: lo
autorizza la tua richiesta esplicita. Nessuna domanda, stop immediato, report
con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): `false` (dal tuo comando); Handoff la ignora e
  la segnala
- Commit WIP: off (dal tuo comando); Handoff lo ignora e lo segnala
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002, anche con `false` e WIP off (nessuno se non c'è nulla);
  nessun push

### HA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Fuori da Plan `executor-power` viene rifiutata, ma Handoff
non rifiuta mai una richiesta di stop: la ignora e la segnala. Il livello
salvato nei piani non cambia. Stop immediato su B-A002, commit solo se c'è
codice non committato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `low` (dal tuo comando); Handoff la ignora e la
  segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Come HA-10: non è un errore, viene ignorata e segnalata.
Nessun piano viene ricalibrato. Stop immediato su B-A002, commit solo se c'è
codice non committato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `medium` (dal tuo comando); Handoff la ignora e la
  segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high handoff
```

**Cosa fa:** L'opzione viene ignorata e segnalata; lo stop parte subito.

**Cosa aspettarsi:** Come HA-10: non è un errore, viene ignorata e segnalata.
Nessun piano viene ricalibrato. Stop immediato su B-A002, commit solo se c'è
codice non committato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: `high` (dal tuo comando); Handoff la ignora e la
  segnala
- Agenti: invariati
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku handoff
```

**Cosa fa:** L'elenco agenti viene ignorato e segnalato; lo stop parte subito.

**Cosa aspettarsi:** L'elenco non viene né usato né salvato: l'handoff lo fa la
sessione corrente. Il roster registrato nei piani e nei ledger resta com'è e
torna con il lavoro ripreso. Stop immediato su B-A002, commit solo se c'è codice
non committato, report con `resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: `agent-1:opus,agent-2:sonnet,agent-3:haiku` (dal tuo comando);
  Handoff li ignora e li segnala
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model handoff
```

**Cosa fa:** Il prefisso agente viene ignorato e segnalato; lo stop parte
subito.

**Cosa aspettarsi:** `my-model` non viene usato né salvato: nessun lavoro viene
delegato, e non c'è nessuna revisione da dichiarare. Stop immediato su B-A002,
commit solo se c'è codice non committato, report con
`resume 000_adhoc B-A002`.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: `my-model` (dal tuo comando); Handoff lo ignora e lo segnala
- Deadline: nessuna (default)
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto)
- Dove si ferma: subito, senza avviare lavoro nuovo
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002 (nessuno se non c'è nulla); nessun push

### HA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 handoff
```

**Cosa fa:** Le due forme sono equivalenti. Durante una run la lascerebbe
continuare fino al taglio (17:30 meno la riserva di almeno 10 minuti) e poi
farebbe handoff, report compreso, entro le 17:30. Anche una sessione che attende
un subagente o un comando in background ha una run in corso: il subagente non
viene fermato, riceve il taglio come ora di ritorno se l'host lo permette,
l'agente stampa una riga con deadline e taglio e la run continua fino al taglio.
Qui la sessione è inattiva: nessuna run da lasciar continuare, quindi l'handoff
è immediato.

**Cosa aspettarsi:** Non c'è nulla da programmare: stop subito su B-A002, commit
di handoff solo se c'è codice non committato, report con la deadline registrata
e il comando `resume 000_adhoc B-A002`. Il comando di ripresa non ripete nessuna
opzione: la deadline vale solo per questa run e non viene salvata. Una deadline
passata o non valida ha lo stesso effetto: handoff immediato, segnalato.

**Impostazioni di questa run:**

- Autonomia (`full-autonomous`): non usata
- Commit WIP: non usati
- Potenza degli esecutori: invariata
- Agenti: invariati
- Deadline: 31 ottobre 2026 alle 17:30 ora locale, solo per questa run (dal tuo
  comando); su una sessione inattiva resta solo registrata nel report
- Obiettivo: `000_adhoc`, voce B-A002 (l'unico lavoro aperto); in una run, la
  run in corso
- Dove si ferma: subito (in una run, entro le 17:30)
- Commit fatti da questa run: un commit di handoff per il codice non ancora
  committato di B-A002, anche con i commit disattivati (nessuno se non c'è
  nulla); nessun push

## Combinare le opzioni

Le opzioni si combinano liberamente, in qualsiasi ordine, prima della modalità;
ognuna mantiene l'effetto descritto nel suo caso. Solo `executor-power` ha un
limite: la accetta soltanto Plan.

```text
/plan-execute-verify full-autonomous:true --wip-commit executor-power:medium agent-1:opus,agent-2:sonnet plan aggiungi export CSV
```

PL-06 + PL-11 + PL-13: il nuovo piano salva autonomia true, WIP on, livello
`medium` e questo elenco di agenti. Le domande del piano diventano decisioni
autonome, elencate nel report finale.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet full-autonomous:true --no-wip-commit execute 003 phase_02
```

EX-08 + EX-13, limitato alla fase in `phase_02.md` (sotto-fasi 2.1, 2.2 e la
chiusura P2). Il selettore è diverso dallo scope salvato di 003, ancora
`RUNNING`: lo sostituisce come decisione autonoma, annotata in `history.md`, e
committa le unità completate senza commit WIP.

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
agenti, e un handoff che finisce entro le 17:30, con la riserva di almeno 10
minuti.

```text
/plan-execute-verify full-autonomous:false --no-wip-commit resume 000_adhoc B-A002
```

RE-09 su una sola voce del ledger: continua solo il bug ad-hoc B-A002, senza
commit, e si ferma dopo di esso; la volta successiva tornano le impostazioni
registrate sulla voce. Con il default `true` lo stesso comando recupererebbe
anche le altre voci riprendibili del ledger, in ordine di ledger.
