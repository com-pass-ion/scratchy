# Emacs Power Workflows

Kurzreferenz für die wichtigsten Workflows dieser Config.

---

## Suchen & Navigation

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-s` | `consult-line` | Fuzzy-Suche im aktuellen Buffer |
| `C-x b` | `consult-buffer` | Buffer wechseln (mit Vorschau) |
| `C-x r b` | `consult-bookmark` | Bookmark laden |
| `M-s r` | `consult-ripgrep` | Fuzzy-Suche im gesamten Projekt |
| `M-y` | `consult-yank-pop` | Yank-History (Zwischenablage) |
| `C-r` | `consult-history` | Minibuffer-History (nach `M-x` etc.) |

**Beispiel Fuzzy-Suche:**
1. `C-s` drücken
2. Typen: `def main` — wird sofort gefiltert
3. `C-n`/`C-p` für nächste/vorherige Ergebnisse
4. `RET` zum Springen

---

## Completion (Autocompletion)

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `TAB` | corfu-complete | Aktuelle Completion akzeptieren |
| `M-TAB` | corfu-next | Nächste Option |
| `C-g` | corfu-quit | Abbrechen |

**Verhalten:**
- Completion startet automatisch nach 1 Zeichen
- Erscheint inline unter dem Cursor (kein Popup-Fenster)
- Funktioniert in allen Modi

---

## Snippets (tempo)

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-<TAB>` | `tempo-complete-tag` | Template-Name eingeben und C-TAB drücken |

**Verfügbare Templates:**

| Template | Modus | Inhalt |
|----------|-------|--------|
| `c-main` | C | `#include <stdio.h>` + main() |
| `python-main` | Python | `def main():` + `if __name__` |
| `bash-header` | Bash | Shebang + `set -euo pipefail` |
| `elisp-func` | Elisp | `(defun ...)` mit docstring |

**Beispiel:**
1. Neuen Buffer öffnen (`C-x b`)
2. `python-main` tippen
3. `C-<TAB>` drücken
4. Template wird eingefügt

---

## Build & Run

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-c l r` | `my/run` | Datei ausführen (modus-abhängig) |
| `C-c l b` | `my/cpp-build` | C++ Projekt bauen (CMake) |
| `C-c l c` | `compile` | Beliebigen Befehl kompilieren |
| `C-c l k` | `kill-compilation` | Laufende Kompilierung abbrechen |
| `C-c l n` | `next-error` | Zum nächsten Fehler springen |
| `C-c l p` | `previous-error` | Zum vorherigen Fehler springen |
| `C-c C-c` | `python-shell-send-buffer` | Python-Buffer an Shell senden |

### C++
1. `C-c l b` — Projekt bauen
2. `C-c l r` — Bauen + Ausführen

### Python
1. `C-c C-c` — Buffer an Python-Shell senden
2. `C-c l r` — Script ausführen

### Bash
1. `C-c l r` — Script ausführen

### Elisp
1. `C-c l r` — Aktuellen Buffer evaluieren
2. `C-x C-e` — Letzten S-Expression evaluieren

---

## Terminal

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-c t n` | `eat` | Terminal öffnen (rechts split) |

**Verwendung:**
- `C-c t n` öffnet `eat` in einem Side-Window
- Shell-Befehle werden direkt ausgeführt
- Für interaktive Programme (htop, gitui, etc.)

---

## Git (magit + diff-hl)

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `M-x magit-status` | `magit-status` | Git-Status öffnen |
| `C-x v =` | `diff-hl-diff-goto-hunk` | Diff für aktuellen Hunk anzeigen |
| `C-x v n` | `diff-hl-next-hunk` | Zum nächsten geänderten Hunk springen |
| `C-x v p` | `diff-hl-previous-hunk` | Zum vorherigen geänderten Hunk springen |

**Diff-Hl:**
- Zeigt Änderungen im Fringe (links neben Zeilennummern)
- Grün = Zeile hinzugefügt, Rot = gelöscht, Blau = geändert
- Automatisch aktiv in prog-mode

**Magit-Workflow:**
1. `M-x magit-status` — Status-Buffer öffnen
2. `s` — Dateien stage-n
3. `c c` — Commit erstellen
4. `P` — Push
5. `F` — Pull
6. `b b` — Branch wechseln

---

## Fenster & Buffer

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `M-o` | `ace-window` | Zu Fenster springen (per Nummer) |
| `C-x C-r` | `recentf-open-files` | Letzte Dateien öffnen |
| `C-x 2` | `split-window-below` | Horizontal teilen |
| `C-x 3` | `split-window-right` | Vertikal teilen |
| `C-x 1` | `delete-other-windows` | Nur aktives Fenster |
| `C-x 0` | `delete-window` | Aktuelles Fenster schließen |

**Ace-Window:**
1. `M-o` drücken — Nummern erscheinen über jedem Fenster
2. Nummer tippen (a/s/d/f/g/h/j/k/l) — sofort zum Fenster springen

---

## Undo (vundo)

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-/` | `undo` | Rückgängig (Standard) |
| `C-?` | `undo-redo` | Wiederherstellen |
| `C-c u` | `vundo` | Visueller Undo-Tree |

**Vundo:**
- Zeigt Änderungsverlauf als Baumdiagramm
- Pfeile für Navigation, RET zum Springen
- q zum Beenden

---

## LSP (eglot)

**Automatisch aktiv für:** Python, C++, C, Java, Bash

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `M-.` | `xref-find-definitions` | Zur Definition springen |
| `M-,` | `xref-pop-marker-location` | Zurück zur Definition |
| `M-?` | `xref-find-references` | Referenzen finden |
| `M-n` | `flymake-goto-next-error` | Zum nächsten Fehler springen |
| `M-p` | `flymake-goto-prev-error` | Zum vorherigen Fehler springen |

---

## Help (helpful)

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `C-h f` | `helpful-callable` | Funktion dokumentieren |
| `C-h v` | `helpful-variable` | Variable dokumentieren |
| `C-h k` | `helpful-key` | Tastenkombination erklären |
| `C-h o` | `helpful-symbol` | Symbol (Funktion/Variable) |

---

## Minibuffer

| Key | Funktion | Beschreibung |
|-----|----------|--------------|
| `M-A` | `marginalia-cycle` | Annotationen ein/aus |
| `C-n` | `vertico-next` | Nächstes Ergebnis |
| `C-p` | `vertico-previous` | Vorheriges Ergebnis |
| `C-s` | `orderless-flex` | Weiter filtern |
| `C-j` | `vertico-exit` | Auswahl bestätigen |

---

## Projekt erstellen

**`M-x my/project-new`** erstellt ein neues Projekt:

1. Sprache wählen: `cpp` oder `python`
2. Projektname eingeben
3. Automatisch:
   - Verzeichnisstruktur erstellen
   - `.projectile` Datei anlegen
   - `CMakeLists.txt` (C++) oder `main.py` (Python)
   - `.gitignore` erstellen
   - Git-Repo initialisieren + Initial-Commit
   - Python: virtuelle Umgebung erstellen

**Speicherort:** `~/Projects/<name>`

---

## Emacs-spezifische Workflows

### Buffer verwalten
| Key | Funktion |
|-----|----------|
| `C-x b` | Buffer wechseln |
| `C-x k` | Buffer schließen |
| `C-x 1` | Nur aktuellen Buffer |
| `C-x 2` | Horizontal teilen |
| `C-x 3` | Vertikal teilen |

### Region & Text
| Key | Funktion |
|-----|----------|
| `C-SPC` | Mark setzen |
| `C-x C-x` | Mark und Cursor tauschen |
| `C-w` | Ausschneiden |
| `M-w` | Kopieren |
| `C-y` | Einfügen |
| `M-y` | Yank-History |

### Navigieren
| Key | Funktion |
|-----|----------|
| `C-a` | Zeilenanfang |
| `C-e` | Zeilenende |
| `M-<` | Dateianfang |
| `M->` | Dateiende |
| `C-v` | Seite runter |
| `M-v` | Seite hoch |

### Editing
| Key | Funktion |
|-----|----------|
| `C-/` | Rückgängig |
| `C-?` | Wiederherstellen |
| `M-/` | Autocomplete (dabbrev) |
| `C-M-\` | Region einrücken |

---

## Emacs beenden

| Key | Funktion |
|-----|----------|
| `C-x C-c` | Emacs schließen |
| `C-z` | Minimieren (iconify) |
| `C-x r r` | Register speichern |
| `C-x r j` | Register laden |
