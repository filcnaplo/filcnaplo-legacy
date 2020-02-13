# Szia!
Elsosorban szeretnenk megkoszonni hogy kozremukodsz a projektben!

### Miert olvasd ezt el?
Ha ezt a segedet koveted, a kommunikacio konnyebb lesz es nem fogunk felesleges dolgokon fennakadni.

### Milyen fajta segitseg lenne jo nekunk?
A kod refactorolasa (olvashatobba, minosegibbe teteleben), issue-k javitasa, meg ujabb nyelvekre forditas.

## Elvarasok:

- Ne legyel tiszteletlen senkivel. (meg a KRETA fejlesztoivel se)
  - Tragar beszedet hanyagolni, ha lehet.
  - Mindenki egy elo ember itt.
  - Vitakban civilizalt viselkedes. (Semmi veszekedes)
  - Viselkedj ugy mintha szemtol szemben beszelnel.
  - Ha valaki kenyelmentelnul erzi magat az nem produktiv.

- Gondolkodj elore
  - Probald meg tesztelni a PR-jaidat mielott elkuldod. 
    - Nem a legnagyobb problema ha valami nem tokeletes itt, meg van ideje releasig.
  - Kovesd a commit uzenetek formait. (Lentebb) [LINK COMMIT UZENETEK]
  - Kovesd a kod konvenciot. (TODO)
  - Probalj segitokesz commenteket hagyni. (link comment guide)
  - Ha valamit nem ertesz, nyugodtan kerdezz. (Lentebb) [LINK KOZOSSEG]
    - Sok dolgot mi se ertunk, ne varj azonnali valaszt.

## Elso kozremukodesed
Remeljuk olyan izgatott vagy mint mi!

### Hogyan is kezdjek hozza?
- Csinalj egy forkot.
- Szerkessz bele.
- Csinalj egy PR-t a forkodbol.

### Commit uzenetek

#### Minek kene ezeket kovetni?
- Konnyebben lehet automata changelogokat generalni.
- Konnyebb navigacio a git historyban.

#### Formatum
```
<tipus>(<hataskor>): targy

<hosszabb leiras ha kell>

<lab>
```
- Megengedett tipusok:
 - feat (uj feature)
 - fix (bug fix)
 - docs (dokumentacio)
 - style (barmi ami nem valtoztat a kodon)
 - refactor 

- Pelda hataskorok:
 - ui
 - request
 - login
 - screens
 - dialogs
 - <semmi>, ha tul nagy a hataskor (ilyenkor nem kellenek a zarojelek)

- Leiras:
 - Legtobb esetben nem kell
 - Jelen ido
 - Elmondja a kulonbseget a mostani es az elozo viselkedes kozott

- Lab:
 - Ha egy issue-t (vagy tobbet) bezar akkor `Closes: #123, #456, #789`
