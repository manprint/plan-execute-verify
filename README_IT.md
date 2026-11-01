# plan-execute-verify

[English](README.md) · [Esempi d'uso](USAGE_EXAMPLE_IT.md)

Una skill per fare onboarding sui repository, pianificare, implementare e
controllare il lavoro su fasi e sotto-fasi. Un agente più capace definisce il
design e rivede il risultato; agenti meno capaci possono implementare anche
modifiche complesse partendo da contratti espliciti, passi numerati e
aspettative sui test.

I piani portano con sé il proprio stato, così il lavoro può proseguire in una
nuova sessione o con un modello diverso. Affidabilità e possibilità di recupero
hanno la precedenza sul risparmio di token.

## Avvio rapido

Su un repository che non conosci, o quando riprendi dopo una pausa, inizia con:

```text
/plan-execute-verify onboard
```

Mappa il progetto, riassume il lavoro già esistente e suggerisce il comando
successivo senza eseguirlo. Questo passo è facoltativo se hai già abbastanza
contesto.

Per iniziare uno sviluppo nuovo, chiedi all'agente più capace di creare un
piano. Sostituisci i nomi degli agenti con gli identificativi supportati dal tuo
host:

```text
/plan-execute-verify full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku add per-user rate limits; preserve existing behavior when disabled
```

La pianificazione crea una cartella numerata come
`docs/plans/003_plan-RateLimit/`. Non implementa né committa nulla. L'opzione e
il roster vengono salvati per l'esecuzione. Senza `executor-power`, il piano
punta a esecutori `low`: la scomposizione più fine e più dettagliata, che è
anche la più onerosa in fase di pianificazione. Passa `executor-power:medium` o
`executor-power:high` quando ogni implementatore è più capace
([sotto](#indica-al-pianificatore-quanto-sono-capaci-gli-esecutori)).

Poi esegui quel piano:

```text
/plan-execute-verify execute 003
```

Si applica il `full-autonomous:true` salvato. L'esecutore avanza nel piano,
ottiene le revisioni obbligatorie dell'agente più capace e committa in locale,
sul branch corrente, ogni sotto-fase e fase completata.

Esegui l'audit del risultato separatamente:

```text
/plan-execute-verify verify 003
```

Se l'audit trova problemi, applica esplicitamente il suo piano di correzione:

```text
/plan-execute-verify execute verify
```

Gli esempi usano la notazione con slash. Se il tuo host richiama le skill con
un'interfaccia diversa, seleziona questa skill e passa le stesse opzioni e gli
stessi argomenti.

## Scegli la modalità

| Comando dopo il nome della skill | Usalo per | Cosa cambia |
|------------------------------|------------|-----------------|
| `onboard [plan]` | Capire un repository esistente o recuperare il contesto e il passo successivo | Solo docs/onboarding.md; nessuna modifica al codice, allo stato del piano o commit |
| `plan <feature>` o `<feature>` | Progettare una funzionalità, un refactoring o una migrazione | Solo i file del piano; le opzioni diventano default del piano, e `executor-power` ne imposta il dettaglio |
| `execute [plan] [phase or sub-phase]` | Implementare un piano esistente | Codice, test, documentazione e stato del piano |
| `task <description>` | Una piccola modifica | La modifica richiesta e il relativo ledger |
| `bug <description>` | Un singolo difetto | Riproduzione, test di regressione, fix e ledger |
| `verify [plan] [phase, sub-phase, or entry]` | Fare l'audit dell'intero piano o di un ambito più ristretto, incluse le voci di `000_adhoc` | Report di audit e stato; nessuna correzione al codice |
| `execute verify [plan] [report ID]` | Applicare le correzioni dell'audit | Le correzioni selezionate e lo stato del piano interessato |
| `resume [plan] [unit ID]` | Riprendere il lavoro interrotto o salvato esattamente dal punto in cui si è fermato | Ciò che cambia l'unità o l'ambito ripreso; mai il suo ambito né le sue impostazioni |
| `handoff [--deadline=dd-mm-yyyy_hh_mm]` | Fermare il lavoro in corso in modo ordinato, subito o entro una deadline | Checkpoint dello stato, un solo commit di handoff per il lavoro sul codice e il comando di ripresa |

[USAGE_EXAMPLE_IT.md](USAGE_EXAMPLE_IT.md) mostra ogni modalità senza opzioni,
ogni opzione da sola, le quattro coppie autonomia/WIP, entrambe le forme
dell'elenco di agenti e una deadline: per ciascun caso il comando, cosa fa e le
impostazioni complete che quella run usa. È disponibile anche in inglese:
[USAGE_EXAMPLE.md](USAGE_EXAMPLE.md).

La prima parola dopo le opzioni seleziona la modalità quando è `onboard`,
`plan`, `execute`, `task`, `bug`, `verify`, `resume` o `handoff`. Altrimenti la
richiesta diventa la descrizione di una pianificazione. Per una funzionalità il
cui nome inizia con una parola di modalità, usa la forma esplicita con Plan:
`/plan-execute-verify plan task queue for background
jobs`. Argomenti mancanti o selettori non validi non cambiano mai modalità in
silenzio. Una richiesta la cui prima parola chiede di continuare un lavoro
registrato, come `/plan-execute-verify continue 003`, non è mai un nuovo piano:
viene eseguita come `resume 003`, oppure l'agente chiede cosa intendevi. Le
opzioni vanno prima della modalità; se una descrizione contiene un'opzione, come
un `--deadline=…` finale, l'agente chiede prima di iniziare. Solo `handoff`
accetta anche la deadline dopo la modalità.

Task e Bug non accettano selettori. Si collegano a un piano solo quando la
richiesta ne nomina uno (numero, nome della funzionalità o percorso) o cambia
chiaramente ambito, contratti o file di un piano attivo; altrimenti usano
`docs/plans/000_adhoc/`. Più piani candidati richiedono una tua scelta, e un
piano completato viene usato solo se nominato. Nessuna delle due modalità cambia
l'ambito di esecuzione salvato del piano.

Prima di qualsiasi modifica al codice, agent-1 scrive o convalida un breve
mini-piano nella voce del ledger; per un bug viene dopo la riproduzione e la
causa radice. Con `full-autonomous:false`, il default, la run si ferma con la
voce `PROPOSED` e mostra il mini-piano. Se vuoi, modificalo nel file, poi
approvalo con una risposta nella stessa sessione oppure con
`/plan-execute-verify resume
000_adhoc T-A004`: l'ID della voce è obbligatorio, e un `resume` senza ID non
approva mai. I file modificati o le tue modifiche vengono ricontrollati prima di
scrivere codice, e la run approva solo quella voce. Per rifiutare una proposta,
dillo nella stessa sessione oppure imposta il suo stato su `WITHDRAWN` con un
motivo nel file del ledger. Con `full-autonomous:true` non c'è nessuno stop, ma
la convalida viene comunque eseguita, quindi una sessione meno capace che non
riesce a raggiungere agent-1 si blocca prima di scrivere codice. Nessuna
impostazione produce un task o un bug che non abbia né uno stop di approvazione
né commit di completamento: `false` si ferma, `true` committa.

## Onboarding: primo accesso o progetto da riprendere

Esegui dal repository di destinazione:

```text
/plan-execute-verify onboard
/plan-execute-verify onboard 003
/plan-execute-verify onboard docs/plans/003_plan-RateLimit
```

Il selettore facoltativo mette a fuoco un piano esistente per numero, nome
univoco o percorso; non accetta selettori di fase/report né `000_adhoc`. Senza
di esso, Onboard inventaria il repository e i piani e i ledger trovati. Più
flussi di lavoro plausibili richiedono una scelta; il numero di piano più alto
non è automaticamente il lavoro da riprendere.

**Primo accesso, nessuno storico della skill:** l'agente mappa lo scopo del
progetto, i componenti, i punti di ingresso, lo stack e le versioni risolte, le
convenzioni, i flussi principali, i percorsi dei test, le definizioni dei
comandi e le modifiche esistenti rilevanti. Individua le incertezze e fornisce
un percorso di lettura ordinato per il prossimo agente. Il software esistente
non viene ricreato, e i TODO non vengono trasformati in una roadmap approvata.
Senza un obiettivo successivo dichiarato, l'agente chiede cosa vuoi ottenere.

**Progetto da riprendere:** l'agente legge lo stato di riferimento, i contratti
delle fasi, i ledger di task e bug e gli audit rilevanti, poi confronta il
checkpoint con il repository reale. Il riepilogo distingue il completamento
registrato, le prove ispezionate e i test effettivamente rieseguiti. Identifica
il lavoro aperto, i commit in sospeso, i blocchi, l'ambito e le impostazioni
salvati e il passo successivo ammissibile. I piani parziali o legacy vengono
segnalati come tali, non trattati come un progetto nuovo né riparati in
silenzio.

Il risultato è un breve riepilogo, una mappa di contesto con fonti in
docs/onboarding.md e un solo comando successivo o un handoff preciso. Per
esempio, un ambito di esecuzione salvato sulla sotto-fase 1.2 produce
`/plan-execute-verify resume 003`, che continua quell'ambito, e non un
`execute 003` sull'intero piano. Se quell'ambito o il piano ha salvato
`full-autonomous:true`, il riepilogo spiega che riprendere erediterebbe i commit
di completamento automatici. Onboard non esegue quel comando. Per una voce del
ledger interrotta, un audit o una bozza suggerisce `resume` con l'ID esatto,
come `/plan-execute-verify resume 000_adhoc B-A002`, mai una sintassi inventata
come `plan 003` o `bug B-A002`.

La mappa registra data di osservazione, branch e commit, copertura, riferimenti
alle fonti e limiti. È un ausilio di orientamento datato, non un secondo
STATE.md né un audit. Le modalità successive ricontrollano le fonti rilevanti ed
eseguono comunque la propria ricognizione e il proprio recupero; Onboard non è
obbligatorio prima di ogni comando. I contenuti dell'utente esterni alla sua
sezione gestita vengono preservati; un file non marcato nella destinazione
richiede un'unione o una posizione concordate, invece di essere sovrascritto.

Onboard non modifica mai codice, piani, impostazioni di runtime o roster; non
ricostruisce gli indici di ricerca; non prende in carico unità; non ripara lo
stato; non cambia branch; né committa. Inventaria i comandi del progetto senza
eseguire script, installare dipendenze o avviare servizi, per impostazione
predefinita. I test non eseguiti sono indicati esplicitamente come tali. Le
opzioni full-autonomous e WIP vengono accettate ma non modificano questi limiti
e non vengono salvate per i lavori successivi. Un prefisso di agente seleziona
solo l'ispettore; non riassegna un piano esistente. Per la prima mappa
dell'architettura preferisci un agente più capace; gli aggiornamenti ordinari
possono riutilizzarlo, passando a un agente più capace quando un'interpretazione
è incerta. La ricerca su internet resta mirata, di solito durante Plan, e non è
un'indagine obbligatoria in fase di onboarding.

## Configura autonomia e commit

Le opzioni vanno **prima della modalità o della descrizione della
funzionalità**, in qualsiasi ordine insieme al prefisso dell'agente:

```text
/plan-execute-verify full-autonomous:true execute 003
/plan-execute-verify full-autonomous:false execute 003
/plan-execute-verify full-autonomous:true --wip-commit execute 003
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

| Opzione | Effetto |
|--------|--------|
| `full-autonomous:true` | Continua finché l'ambito selezionato è completo o davvero bloccato; committa i completamenti operativi verificati |
| `full-autonomous:false` | Prosegue per tutta la fase corrente e si ferma dopo la sua chiusura (`resume` continua); Task e Bug si fermano una volta, per l'approvazione del mini-piano; non aggiunge commit di completamento |
| `--wip-commit` | Committa i progressi: unità di codice completate, chiusure di fase e un commit WIP a rotazione a ogni checkpoint di recupero |
| `--no-wip-commit` | Disattiva il comportamento WIP; non disattiva i commit di completamento abilitati dall'autonomia completa |
| `--deadline=dd-mm-yyyy_hh_mm` | Ogni modalità: si ferma in modo ordinato entro quest'ora locale; vale solo per questa run ([Fermati in modo ordinato](#fermati-in-modo-ordinato-handoff)) |

Default: `full-autonomous:false`, WIP disattivato. I booleani sono i valori
letterali `true` o `false`; `full-autonomous:yes` viene rifiutato.

L'autonomia completa si può chiedere anche come ultimo token di un comando
`execute`, `execute verify`, `resume` o `verify`
(`/plan-execute-verify execute 003 full-autonomous:true`) oppure a parole nel
messaggio ("in piena autonomia", "full autonomous", "senza fermarti fino alla
fine"): entrambe valgono come opzione esplicita. In autonomia completa l'agente
chiude un'unità, stampa una riga di avanzamento e apre la successiva nello
stesso turno. Si ferma solo quando l'ambito è completo, su un blocco reale, su
tua richiesta o `handoff`, o quando l'host chiude la sessione; non si ferma mai
dopo una sotto-fase per chiederti `resume`. Le modalità di permesso come bypass
o yolo non cambiano questo comportamento.

Le impostazioni si risolvono in modo indipendente:

1. Un'opzione esplicita nell'invocazione corrente.
2. L'opzione data con l'ambito di esecuzione salvato, finché quell'ambito
   continua.
3. Il default del piano in STATE.md, impostato da Plan.
4. Il default.

`executor-power` non è un'impostazione di runtime e non segue quest'ordine: solo
Plan lo accetta, viene salvato con il piano, e ogni altra modalità lo rifiuta
([sotto](#indica-al-pianificatore-quanto-sono-capaci-gli-esecutori)).

Le opzioni date a Plan diventano default del piano. Le opzioni date a Execute o
Execute verify appartengono all'ambito che avviano: sopravvivono a resume e alle
nuove sessioni di quell'ambito, e decadono quando un selettore diverso lo
sostituisce, quindi una run autonoma una tantum non cambia mai le esecuzioni
successive. Per disattivare tutti i commit automatici, indica sia
`full-autonomous:false --no-wip-commit`; solo un handoff fa ancora il suo
commit. Task, Bug, Verify e Resume usano le opzioni esplicite solo per quella
invocazione e le registrano nella loro voce del ledger, nel report di audit o
nell'unità ripresa, anche quando sono collegati a un piano; non cambiano mai le
sue impostazioni salvate. Onboard non salva mai opzioni né modifica la
configurazione salvata di un piano. Entrambi i valori booleani significano solo
ispezione: né l'autonomia completa né il WIP committano il suo documento di
contesto o avviano l'azione successiva consigliata.

### Quali commit vengono creati?

| Autonomia completa | WIP | Unità di codice completate | Fasi completate | WIP ai checkpoint | Audit completato |
|-----------------|-----|----------------------|------------------|------------------|-----------------|
| false | off | No | No | No | No |
| false | on | Sì | Sì | Sì | No |
| true | off | Sì | Sì | No | Sì, solo gli artefatti |
| true | on | Sì | Sì | Sì | Sì, solo gli artefatti |

Un'unità di codice è una sotto-fase, un task, la correzione di un bug o una
correzione di audit. Una fase riceve un proprio commit di completamento dopo
tutte le sotto-fasi, i controlli di integrazione, la documentazione e la
revisione dell'agente più capace, e il piano concluso riceve un proprio commit
di completamento dopo l'ultima fase, quando passano i gate finali (chiusura
`PLAN`). Plan e Onboard non committano mai. Quando il
lavoro o i file del piano restano non committati, il report finale lo dice e
suggerisce il comando di commit esatto senza eseguirlo: i file di piano non
tracciati possono andare persi con `git clean` o con un cambio di branch.

Gli oggetti dei commit sono fissi, così `git log --oneline` mostra quale piano,
fase e unità si è chiusa (qui il piano 003):

```text
sub-phase(003/1.2): sub-phase 1.2 of phase 1 complete — quota validation
phase(003/P1): PHASE 1 COMPLETE — limiter integration; gates and review passed
plan(003): PLAN 003 COMPLETE — RateLimit; 3 phases, final gates passed
task(003/T-A004): task T-A004 complete — --json output
bug(000_adhoc/B-A002): bug B-A002 fixed — missing-config exit code
correction(003/V001-C1): correction V001-C1 complete — Retry-After assertion
verify(003/V001): audit V001 complete — verdict FAIL, 1 blockers
wip(003/1.2): WIP sub-phase 1.2 — at S3
handoff(request-by-user): 003/1.2 stopped before S3
```

Il corpo ha al massimo sei righe brevi (piano, fase, unità, gate, review,
prossima unità) prima dei trailer PEV.

Un handoff crea un solo commit di handoff per il lavoro sul codice, qualunque
siano le impostazioni nella tabella sopra, ogni volta che c'è lavoro sul codice
da committare; se un hook lo rifiuta, il lavoro resta non committato e il report
mostra il comando di commit
([Fermati in modo ordinato](#fermati-in-modo-ordinato-handoff)).

Se un hook o commitlint rifiuta il tipo, viene mappato solo il tipo su uno
ammesso (per esempio `chore`); scope e descrizione restano. Tutti i
commit sono locali e usano il branch corrente, incluso `main` se è il tuo branch
corrente. La skill non crea né cambia branch e non fa push. Preserva le
modifiche non correlate, comprese quelle nello stesso file, e controlla il
contenuto in staging prima di committare.

Un audit autonomo può committare un report con verdetto FAIL: registra
un'ispezione completata, non un'implementazione completata o verificata. Non
applica mai automaticamente le correzioni al codice che propone.

I commit WIP sono etichettati separatamente come incompleti: con WIP attivo,
ogni checkpoint di recupero di un'unità aperta aggiorna un unico commit
`wip(<piano>/<unità>)` a rotazione, quindi un crash perde al massimo il lavoro successivo a
quel checkpoint. L'autonomia completa senza WIP non committa lavoro rotto o non
rivisto quando viene interrotta. I commit includono nello staging solo gli hunk
propri dell'unità, senza Git interattivo, lasciano attivi gli hook del
repository (mai `--no-verify`; un hook che fallisce blocca l'unità come un gate
non superato) e mettono i trailer di identità PEV nel blocco finale dei trailer,
accanto alle eventuali righe `Co-Authored-By`.

## Scegli esattamente cosa eseguire

```text
/plan-execute-verify execute 003
/plan-execute-verify execute RateLimit
/plan-execute-verify execute docs/plans/003_plan-RateLimit
/plan-execute-verify full-autonomous:true execute 003 phase_02
/plan-execute-verify full-autonomous:true execute 003 § 1.2
/plan-execute-verify execute verify V002
/plan-execute-verify execute verify 003 V002
```

Un selettore di fase o sotto-fase è un limite, anche con l'autonomia completa.
Selezionare 1.2 non autorizza l'esecutore a proseguire con 1.3 né a eseguire la
chiusura di fase P1; esegui P1 con un selettore di fase o di piano. Le
dipendenze restano valide. L'ambito selezionato viene salvato: `resume` lo
continua, e le run di task, bug o audit nel frattempo non lo sostituiscono. Un
`execute` o `execute verify` esplicito che sostituirebbe un ambito salvato in
esecuzione o bloccato con uno diverso ti chiede prima conferma.

I file di fase sono numerati da 01; le fasi logiche partono da 0. Quindi
`phase_02.md` contiene la fase logica 1 e sotto-fasi come 1.1 e 1.2.

Senza un selettore di piano, Execute, Execute verify e Verify usano l'unico
piano reale attivo, oppure quello con il numero più alto se nessuno è attivo;
con più piani attivi, l'agente ti chiede. La cartella riservata `000_adhoc` non
viene mai scelta per default e non è mai un obiettivo di Execute o Execute
verify (le sue correzioni di audit vengono eseguite come Task o Bug); Verify e
Resume la accettano solo quando viene nominata. Le correzioni di audit usano il
piano selezionato o l'unico piano attivo non ambiguo, e il report più recente, a
meno che non venga fornito un ID di report. Per eliminare l'ambiguità, usa
`execute verify 003 V002` oppure sostituisci `003` con un percorso di piano.

## Configura gli agenti

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-execute-verify agent-1:gpt5-6-sol,agent-2:gpt5-6-luna <feature>
/plan-execute-verify agent:my-model <feature>
```

| Posizione | Responsabilità |
|----------|----------------|
| agent-1 | Pianificatore più capace e supervisore; risolve le sorprese tecniche e rivede ogni fase |
| agent-2 | Implementatore principale |
| agent-3 e successivi | Ricognizione e implementazione assegnata, incluso il lavoro complesso quando è completamente specificato |
| agent:<name> | Un solo agente esegue tutto; la revisione è esplicitamente self-review |

I nomi sono identificativi specifici dell'host, non modelli garantiti come
disponibili. Le assegnazioni numerate devono partire da 1, senza salti né
duplicati. Senza un prefisso esplicito riusa il roster salvato; un piano nuovo
usa per default Opus/Sonnet/Haiku per compatibilità. Su altri host usa un roster
esplicito. Una singola voce numerata (`agent-1:<name>`) equivale a
`agent:<name>`.

Aprire il piano con un altro modello non cambia in silenzio le sue assegnazioni.
In Plan, Execute ed Execute verify un prefisso esplicito sovrascrive il roster e
aggiorna le assegnazioni rimanenti. In Task, Bug, Verify e Resume vale solo per
quella run; in Onboard vale per l'ispezione e non cambia mai le assegnazioni.

Se l'agente assegnato non può eseguire un'unità, può sostituirlo solo un agente
con numero di posizione uguale o inferiore (agent-1 per agent-2, non il
contrario), e la sostituzione viene registrata. Le revisioni del supervisore e
le revisioni del piano spettano solo ad agent-1; altrimenti l'unità viene
bloccata con un handoff. Un modello fuori dal roster può coordinare ma non
implementare. Una revisione fatta dallo stesso implementatore dell'unità è
indicata come self-review.

L'esecutore meno capace può implementare logica complessa, ma il pianificatore
più capace deve già specificare l'algoritmo (a meno che gli esecutori siano
`high`, vedi sotto), le interfacce, la sincronizzazione, i casi limite, i test e
i criteri di accettazione. Un design mancante torna al supervisore più capace.

### Indica al pianificatore quanto sono capaci gli esecutori

`executor-power:low|medium|high` è un'opzione riservata a Plan che descrive
l'implementatore meno capace che riceverà le unità del piano: agent-2 e le
posizioni successive, oppure l'unico agente di `agent:<name>`. Stabilisce quante
sotto-fasi scrive il supervisore, quanto dettaglio contengono e cosa può
decidere da solo l'esecutore.

```text
/plan-execute-verify executor-power:high agent-1:opus,agent-2:opus <feature>
/plan-execute-verify executor-power:medium agent-1:opus,agent-2:sonnet <feature>
```

| Livello | Esecutori tipici (solo esempi) | Piano risultante |
|-------|-----------------------------------|----------------|
| `low` (default) | Haiku, Luna | Di solito 3–6 sotto-fasi elementari e testabili singolarmente per fase; passi meccanici con posizioni esatte; ogni scelta architetturale, pattern e buona pratica esplicita; frammenti di codice verificati dal supervisore per le parti complesse. L'esecutore decide solo come individuare il codice e i dettagli che il piano lascia esplicitamente aperti |
| `medium` | Sonnet, Terra, DeepSeek | Di solito 2–4 sotto-fasi dettagliate e testabili per fase; frammenti di codice solo dove la prosa non può esprimere un contratto con precisione. L'esecutore riempie anche i dettagli di routine che non cambiano alcuna decisione |
| `high` | Fable, Opus, Astra, Sol, Kimi K3 | Di solito 1–3 sotto-fasi più ampie, orientate al risultato, per fase. L'esecutore pianifica i propri passi e decide l'implementazione interna |

Il default è `low`, quindi un piano creato senza l'opzione riceve la
scomposizione più fine, che costa più lavoro di pianificazione; un piano legacy
precedente all'opzione conta come `low`. La skill non deduce mai il livello dai
nomi dei modelli: scegli il livello in base all'implementatore meno capace che
assegnerai.

A ogni livello agent-1 fissa requisiti, interfacce pubbliche, invarianti, test
di accettazione e gate; un livello più basso aggiunge dettaglio, mai
un'accettazione più debole. Con `high`, nello stile a sessioni successive
l'esecutore registra i propri passi espansi in STATE.md prima di modificare; con
un coordinatore, il worker li restituisce insieme al proprio risultato e il
coordinatore li registra. Le decisioni interne vengono registrate allo stesso
modo per la revisione di agent-1 alla chiusura di fase, e qualsiasi modifica di
contratto va comunque ad agent-1.

Il livello viene salvato con il piano. Execute non può cambiarlo, e ogni
modalità diversa da Plan rifiuta l'opzione. Task e Bug seguono il livello del
piano collegato (`low` in `000_adhoc`), e le correzioni di audit vengono scritte
per quel livello. Se in seguito assegni un implementatore più debole del livello
registrato, il supervisore ricalibra le sue unità prima dell'invio. Limite noto:
nessun comando cambia il livello di un piano esistente, perché ciò richiede una
revisione del piano da parte del supervisore sulle unità rimanenti; scegli il
livello durante la pianificazione.

## Continua in un'altra sessione o con un altro modello

Entrambi gli stili di esecuzione usano gli stessi file di piano. Lo stile non è
un'opzione: ogni run usa lo stile coordinatore quando l'host può avviare
subagent che eseguono i modelli del roster, e lo stile a sessioni successive
altrimenti, e registra quale dei due ha usato.

| Stile | Come funziona |
|-------|--------------|
| Sessioni/modelli successivi (registrato come `handoff`) | Ogni sessione riprende da STATE.md e dal passo indicato; la titolarità passa quando la sessione precedente si ferma |
| Coordinatore con subagent (registrato come `delegated`) | Il coordinatore gestisce stato, modifiche al piano, revisioni e commit; i worker ricevono incarichi di implementazione circoscritti |

Per orientarti in una sessione nuova senza avviare lavoro:

```text
/plan-execute-verify onboard 003
```

Per richiedere invece la ripresa effettiva:

```text
/plan-execute-verify resume 003
/plan-execute-verify resume 003 1.2
/plan-execute-verify resume 000_adhoc B-A002
```

Resume recupera prima il lavoro interrotto (un'unità aperta, un commit di
completamento in sospeso, un audit interrotto, una bozza di pianificazione), poi
continua l'ambito di esecuzione salvato. Non allarga mai quell'ambito né cambia
le impostazioni salvate; un'unità ripresa mantiene le impostazioni con cui è
stata aperta, a meno che tu non le sovrascriva per quella run. Un ID di unità
deve indicare un lavoro aperto, in sospeso, bloccato o sospeso, oppure un task o
un bug proposto: indicandolo lo approvi. Un'unità TODO è un lavoro nuovo per
`execute`.

L'esecutore controlla il diff reale e i test prima di fidarsi di un checkpoint
registrato. La base di ogni unità è HEAD più uno snapshot del working tree,
quindi una ripresa può separare le proprie modifiche dalle unità precedenti non
committate e dalle tue modifiche. Registra lo stato della sotto-fase, gli ID dei
passi completati, la prossima azione esatta, le modifiche in sospeso e le prove
di verifica. Identità di commit stabili impediscono a una sessione ripresa di
duplicare un commit di completamento.

Se una sessione andata in crash detiene ancora la titolarità del piano, la tua
invocazione esplicita su quel piano consente a una nuova sessione di subentrare,
ma solo se il file di stato e il working tree restano invariati durante la sua
ispezione; il subentro viene registrato. Altrimenti chiede.

Il supervisore più capace resta disponibile per le revisioni obbligatorie e per
le decisioni tecniche impreviste. Può rivedere automaticamente i dettagli di
implementazione, preservando requisiti e ambito concordati. Requisiti di
prodotto modificati o nuove autorità esterne richiedono ancora il tuo
intervento.

Se l'host non può invocare quel supervisore, l'esecutore salva un handoff
preciso per una sessione con un modello più capace; non può produrre quella
capacità. L'autonomia completa non avvia automaticamente una nuova sessione
dell'host quando quella attuale finisce.

## Fermati in modo ordinato: handoff

Invia `handoff` a una sessione in esecuzione quando devi fermarla, oppure
assegnale una deadline:

```text
/plan-execute-verify handoff
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

La deadline usa il formato `dd-mm-yyyy_hh_mm`, con orario a 24 ore, nell'ora
locale della macchina che esegue l'agente; una deadline passata significa «ora».
Come opzione iniziale funziona con ogni modalità e vale solo per quella run. Una
richiesta di stop non viene mai rifiutata: `handoff` ignora qualsiasi altra
opzione, prefisso di agente o selettore e lo dichiara, e una deadline non valida
in quel caso significa «ora». Questa modalità non ha nulla a che vedere con lo
stile di esecuzione a sessioni successive, che è anche registrato come
`handoff`.

Inviato durante una run, `handoff` la ferma subito e annulla una deadline
precedente, mentre `handoff --deadline=…` lascia proseguire la run e sostituisce
la deadline precedente. Inviato a una sessione inattiva, riguarda il piano o il
ledger che quella sessione ha modificato per ultimo, oppure l'unico piano o
ledger con lavoro non concluso o non committato che nessun'altra sessione attiva
possiede; con più candidati ti chiede di scegliere.

L'agente poi:

1. Imposta uno stop latch in STATE.md e non avvia nulla di nuovo. Termina
   l'unità aperta solo se richiede circa 10 minuti, inclusi controlli e
   revisione, e non apre mai la successiva; altrimenti si ferma al successivo
   confine di passo e registra i comandi che non ha eseguito.
2. Salva un checkpoint con la prossima azione esatta, marca la run come
   `HANDOFF` e rilascia la titolarità che detiene, così la sessione successiva
   continua senza subentro.
3. Per il lavoro sul codice (Execute, Execute verify, Task, Bug e Resume di
   questi) fa un solo commit locale, anche quando i commit sono disattivati:
   `handoff(request-by-user): <piano>/<unità> stopped <punto>`. Contiene l'unità aperta e le
   unità già finite ma non ancora committate, così STATE.md non dichiara mai
   lavoro che il commit non contiene. Le modifiche di ogni unità vengono messe
   in staging separatamente, quindi le modifiche che hai fatto tra un'unità e
   l'altra restano fuori dal commit. I commit successivi si aggiungono dopo
   questo. Gli hook vengono comunque eseguiti: se uno fallisce, il lavoro resta
   non committato e il report mostra il comando di commit. Se non c'è nulla da
   committare, non viene creato alcun commit. Plan e Verify salvano solo il loro
   checkpoint e avvisano che i loro file non sono committati; Onboard va
   semplicemente rieseguito.
4. Riporta il comando che continua esattamente dal punto in cui si è fermato,
   come `/plan-execute-verify resume 003` o
   `/plan-execute-verify resume 003 T-A004`, e si ferma: nessuna chiamata a
   strumenti dopo il report, anche con `full-autonomous:true` e nelle modalità
   di permesso bypass/yolo. Gli automatismi dell'host (auto-continue, loop, hook,
   un subagente che termina) non riavviano il lavoro; solo il tuo prossimo
   comando esplicito rimuove il latch.

Con una deadline, l'agente controlla l'orologio prima di ogni unità, passo e
comando lungo, evita di avviare lavoro che finirebbe dopo di essa e limita i
comandi lunghi con `timeout`. Il comportamento è best effort: l'agente vede un
messaggio solo tra una chiamata di tool e l'altra, non può interrompere la
propria chiamata in corso, e una sessione inattiva non si risveglia alla
deadline. Imposta la deadline prima del momento in cui ti serve davvero la
macchina, per esempio alle 17:30 se la spegni alle 18:00.

## Dopo ogni run: Continua o Fermati

Ogni run, in ogni modalità e comunque termini, chiude il proprio report con un
blocco "Prossimo passo" (Next), con le etichette nella lingua dell'utente, per
esempio dopo una chiusura di fase con i commit disabilitati:

```text
Prossimo passo
- Continua: `/plan-execute-verify resume 003` — esegue la sotto-fase 2.1, la prossima unità dell'esecuzione salvata
- Fermati: `/plan-execute-verify handoff` — committa 1.1, 1.2 e P1, ancora non committati, in un unico commit di handoff; poi chiudi la sessione
```

Continua è un unico comando esatto, con ID reali e senza opzioni: le
impostazioni registrate viaggiano con `resume`, mentre un nuovo ambito `execute`
parte dai default del piano ed è indicato come nuovo, con le impostazioni che
userà. Dopo un comando rifiutato, quello corretto mantiene le tue opzioni
valide. Quando manca una decisione il testo dice "rispondi a …, poi …"; quando non
segue nulla, spiega perché. Fermati suggerisce `handoff` solo quando resta lavoro
sul codice aperto o non committato, una chiusura in sospeso o la titolarità
detenuta da questa sessione; altrimenti dice che non c'è nulla da salvare. I
file che un handoff non committa mai, come una bozza di piano, un report di
audit, un task proposto o docs/onboarding.md, sono elencati con un comando di
commit suggerito. Entrambe le righe sono suggerimenti: l'agente non le esegue
mai, nemmeno con `full-autonomous:true`. [next-step](references/next-step.md)
elenca quale comando si applica in ogni situazione.

## Quando un piano è pronto?

Ogni sotto-fase ha sette campi (Agent, Assignment, Files, Change, Unit tests,
e2e tests, Done) che contengono prerequisiti esatti, file e simboli, contratti
di design locali, passi numerati e risultati attesi (a livello di esito con
potenza dell'esecutore `high`), test mirati e nominati, con asserzioni,
revisioni obbligatorie e una condizione di completamento. Una fase raggruppa
sotto-fasi coerenti attorno a un unico risultato di integrazione; il loro numero
segue `executor-power` (più numerose e più piccole con `low`, meno e più grandi
con `high`). Il design condiviso compare una sola volta per fase, e la
documentazione può far parte di un'unità di implementazione.

Il pianificatore più capace controlla i contratti critici del codice sorgente ed
esegue una convalida a freddo prima di marcare il piano come READY. Un design
non risolto, requisiti contraddittori o un test di accettazione non definito
impediscono READY. Una bozza bloccata viene etichettata come tale e non
presentata come piano eseguibile.

Durante l'esecuzione, controlli obbligatori falliti o non disponibili
impediscono il completamento. Una run con zero test non è una verifica. I worker
non possono indebolire i test per far risultare tutto verde. Le sotto-fasi
eseguono una validazione mirata; i gate completi vengono eseguiti alla chiusura
di fase. Se un gate o una revisione di fase fallisce, la chiusura non corregge
mai il codice: la sotto-fase responsabile viene riaperta come nuovo tentativo,
oppure il supervisore rivede il piano, e la chiusura di fase viene eseguita di
nuovo. Lo stato viene aperto e chiuso per ogni unità, con checkpoint intermedi
solo ai confini di recupero, come handoff, operazioni rischiose o blocchi. Il
supervisore risolve i difetti tecnici del piano e registra le revisioni e le
dipendenze coinvolte. Questi controlli riducono l'ambiguità; non sostituiscono
il test reale e la revisione del software risultante.

## Ricerca su internet: dove si inserisce

Plan ispeziona prima il repository, poi svolge una ricerca mirata su internet
prima di scegliere il design e scrivere le sotto-fasi di implementazione. Il
pianificatore più capace indaga domande concrete: comportamento delle API,
versioni compatibili, alternative architetturali, vincoli di migrazione e
ipotesi di sicurezza. Le modifiche interamente interne e consolidate possono
registrare che la ricerca non è necessaria.

Non serve alcuna nuova opzione. Per richiedere un focus particolare, includilo
nella descrizione della pianificazione, per esempio:

```text
/plan-execute-verify plan add resumable uploads; investigate the existing storage provider's official guarantees and compare retry strategies before choosing the design
```

Il pianificatore verifica le fonti primarie per le versioni effettivamente usate
e registra in overview.md domande, URL e provenienza, versioni e date,
conclusioni e impatto sulle decisioni. Fatti, inferenze ed esperimenti locali
sono etichettati separatamente. I file di fase contengono le regole e i test
concreti che ne derivano: i worker non ricevono solo link da interpretare o
domande di design da risolvere.

La ricerca si ferma quando le domande necessarie hanno risposta e le decisioni
risultanti sono esplicite. A meno che l'ambiente non autorizzi già l'accesso
alla rete, Plan chiede una volta prima di navigare, elencando le domande
ripulite da dati sensibili, e registra la tua risposta. I fatti richiesti non
risolti impediscono READY, a meno che tu non accetti esplicitamente uno di essi
come rischio noto (ACCEPTED, con il relativo test di guardia); una navigazione
non disponibile viene dichiarata, non trattata come una verifica riuscita. La
documentazione o il codice sorgente primario locale applicabili possono fornire
prove, ma non possono stabilire un'attualità che non hanno. Codice privato,
segreti e dati identificativi restano fuori dalle query.

Durante Execute, Task o Bug, la ricerca viene riaperta solo per nuove prove
rilevanti, versioni cambiate o ipotesi mancanti o contraddittorie; le revisioni
del design restano al supervisore. Verify controlla le affermazioni rilevanti e
registra prove o limiti senza riprogettare né correggere il codice.
`full-autonomous:true` non modifica né questi limiti né il requisito di prove
sufficienti.

## File che vedrai

Onboard scrive il file docs/onboarding.md a livello di repository, separato dai
piani numerati. Non crea né una cartella di piano né un ledger ad hoc solo per
conservare il contesto. L'avanzamento dell'implementazione continua a vivere
solo nel file STATE.md o nel ledger pertinente.

```text
docs/plans/003_plan-RateLimit/
  overview.md       Goal, decisions, research evidence, interfaces, phase map
  phase_01.md       Detailed sub-phases for logical phase 0
  phase_02.md       Detailed sub-phases for logical phase 1
  STATE.md          Solo stato corrente: unità, impostazioni, fase aperta, record pendenti
  PROTOCOL.md       Protocollo statico di avvio per agenti senza questa skill
  history.md        Storico append-only delle unità chiuse (mai letto per riprendere)
  tasks.md          Out-of-plan tasks, created when needed
  bugs.md           Defects and fixes, created when needed
  verify/
    index.md        Reports and current finding statuses
    verify_001_<date>.md
```

Senza piano, il lavoro su task e bug usa `docs/plans/000_adhoc/` e conserva le
informazioni di recupero nella voce del ledger stessa. Non ci sono file di fase
o di STATE fittizi.

STATE.md resta piccolo: a ogni chiusura l'agente aggiunge le evidenze a
history.md e le toglie da STATE.md; a ogni chiusura di fase la fase si riduce a
una riga del board. STATE.md registra il suo formato (`Format: pev-state 2`).
Un piano scritto da una versione precedente della skill viene migrato in
automatico dalla prima run che ne prende la titolarità, prima di qualsiasi
lavoro (formato 1: il testo del protocollo passa in PROTOCOL.md, lo storico in
history.md). Un piano già concluso con le regole precedenti è considerato
completo: non riceve una nuova chiusura PLAN né un commit, a meno che tu non lo
chieda. `onboard` mostra il formato del piano e le migrazioni in sospeso senza
modificare nulla; un piano più recente della skill installata viene rifiutato
finché non aggiorni la skill.

I verdetti di audit sono PASS, PASS WITH FINDINGS, FAIL o INCOMPLETE. Il
verdetto di un audit limitato copre solo la sua fase, sotto-fase o voce, mai
l'intero piano. Le prove obbligatorie mancanti producono INCOMPLETE, a meno che
risultanze confermate di gravità major o blocker non giustifichino già FAIL. I
livelli di gravità BLOCKER, MAJOR e MINOR sono definiti in
[mode-verify](references/mode-verify.md). I report mantengono il verdetto
storico dopo le correzioni, e l'avanzamento di ciascuna correzione viene
tracciato in STATE.md. Un audit può concludersi mentre il suo piano di
correzione è BLOCKED per una decisione mancante; quelle correzioni non possono
essere eseguite finché i loro contratti non vengono convalidati come READY.

## Installazione o aggiornamento

Clona questo repository in una posizione stabile:

```bash
git clone https://github.com/manprint/plan-execute-analyze.git plan-execute-verify
cd plan-execute-verify
```

Per l'helper di installazione incluso per Claude:

```bash
./install-claude.sh
```

Collega questo checkout a `~/.claude/skills/plan-execute-verify`. Per usare
un'altra destinazione, imposta `CLAUDE_SKILLS_DIR` sulla cartella delle skill
desiderata. L'helper rifiuta di sovrascrivere una cartella esistente che non sia
un symlink.

Per un altro host che supporta le skill, registra l'intera cartella con il
meccanismo di installazione di quell'host. Tieni insieme SKILL.md e references/.
Un symlink segue questo checkout; un'installazione copiata va aggiornata dopo
ogni aggiornamento. La disponibilità dei modelli e il meccanismo per avviare
subagent dipendono dall'host.

## Riferimenti per i manutentori

[Punto d'ingresso della skill](SKILL.md) ·
[Contratto di esecuzione](references/execution-contract.md) ·
[Regole di invocazione](references/invocation.md) ·
[Template dei piani](references/output-template.md) ·
[Manuale di onboarding](references/mode-onboard.md) ·
[Template di onboarding](references/template-onboarding.md) ·
[Protocollo di ricerca](references/research.md) ·
[Esempio svolto](references/worked-example.md) ·
[Checklist di qualità](references/quality-checklist.md)

### Ambito della validazione

Le verifiche end-to-end qui sotto risalgono al 2026-09-22 e precedono revisioni
successive del protocollo: checkpoint ai confini di recupero, staging dei gate e
dimensionamento delle fasi, basi delle unità basate su snapshot del working
tree, subentro per titolarità obsoleta, ambito di esecuzione salvato, gestione
dei fallimenti alla chiusura di fase, sostituzione degli agenti, definizioni di
gravità degli audit, modalità Resume, verify con ambito limitato, commit WIP a
rotazione, executor power, modalità handoff con `--deadline`, gate di
approvazione di task e bug e blocco Next. Quelle revisioni sono state
controllate solo in modo statico; non sono state rieseguite end-to-end. I
comandi Git per lo staging degli hunk propri, incluso il fallback `--3way` e un
commit di handoff multi-unità con una patch in staging per unità che tiene fuori
le modifiche dell'utente fatte tra le unità, e il parsing della deadline sono
stati eseguiti solo in repository di prova.

Le verifiche sulla struttura della skill, i controlli statici dei link locali e
`git diff --check` sono superati. Questi controlli includono onboarding e il
protocollo e i template di ricerca; il flusso di ricerca non è ancora stato
eseguito end-to-end con fonti reali. Onboard non ha ancora subito una
valutazione indipendente end-to-end da parte di un agente.

Il protocollo di esecuzione è stato verificato separatamente prima dell'aggiunta
della ricerca: una revisione indipendente degli scenari ha controllato i limiti
di ambito, il completamento interrotto, i commit disabilitati, la sospensione
dell'audit e l'escalation in caso di design mancante.

Una prova isolata della CLI ha prodotto due commit di sotto-fase e un commit di
chiusura di fase, con 10 test superati e 4 esempi di documentazione controllati.
Ripetere l'esecuzione ha lasciato invariati HEAD e STATE.md, senza alcun commit
duplicato. Un altro agente ha scritto la sua bozza; dopo che un limite di
utilizzo del servizio ha interrotto quell'agente, l'agente principale è
ripartito a freddo dai file e ha completato l'esecuzione in locale.

Ciò convalida il protocollo su un piccolo progetto di prova (fixture), non le
prestazioni di Luna, Sonnet o Haiku su progetti complessi. Quei modelli non sono
stati valutati con benchmark qui; contratti dettagliati e gate di revisione non
possono garantire un output privo di errori.

## Licenza

MIT — vedi [LICENSE](LICENSE).
