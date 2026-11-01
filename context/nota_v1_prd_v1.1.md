# Nota — Product Requirements Document (V1)

**Status:** Draft for build
**Owner:** Favour
**Platform:** Flutter (Android-first)
**Revision:** V1.1, aligned with the final UI design

---

## 1. Problem Statement

Studying from PDFs is passive by default — highlighting is the only interaction most reading apps offer, and it produces no understanding on its own. Students end up with colored text and no structured way to question or visualize what they've read. Existing AI study tools bolt a chatbot onto a document viewer without connecting the conversation back to the specific passage that prompted it, and none convert understanding into a visual structure automatically.

Nota is a personal study tool: read a PDF, highlight a passage, and either ask a grounded question about it or generate a diagram that visualizes its structure — with the two actions chainable, so an AI answer can itself become a diagram.

---

## 2. Goals

- Make highlighting *generative* — every highlight can become a question or a diagram, not just colored text.
- Ground every AI interaction in the actual highlighted source text, not an ungrounded chat.
- Turn abstract or process-based passages into visual diagrams automatically, without the user having to describe what kind of diagram they want.
- Ship something the author will actually use for his own coursework, not just a portfolio artifact.

### Non-Goals (V1)
- No multi-device sync, accounts, or auth
- No support for scanned/image-based PDFs (OCR/snip-to-image is V2)
- No EPUB or plain-text support
- No collaborative or sharing features
- No separate dark theme (V1 ships one paper-toned theme, see §7)

---

## 3. Target User

Primary: the author, as a final-year CS student studying from dense academic PDFs (textbooks, papers, lecture material). Secondary: other students with the same problem — this is a personal tool first, portfolio piece second.

---

## 4. Core Concept & Interaction Flow

| Step | Trigger | Result |
|---|---|---|
| 1 | User highlights text in the PDF viewer | Tooltip appears: **Ask AI** / **Generate Diagram** |
| 2a | Taps **Ask AI** | Input opens; user types a free-form question. Highlighted text is sent as context alongside it — not a fixed prompt template. |
| 2b | Taps **Generate Diagram** (direct from highlight) | Highlighted text sent to Gemini with the diagram-generation prompt; diagram rendered. |
| 3 | Answer screen shown (from 2a) | Includes its own **Generate Diagram** action. |
| 4 | Taps **Generate Diagram** from the answer screen | Both the original highlight and the AI's answer are sent as combined context, so the diagram reflects the specific answer, not just the raw excerpt. |
| 5 | Diagram generated | Answer and Diagram are shown as a segmented tab toggle, not a replacement — user flips between text and visual freely. |

---

## 5. V1 Feature Set

### 5.1 Reading & Highlighting
- PDF import from device storage; imported documents listed in a Library screen
- PDF rendering via **pdfrx** (PDFium-based, MIT-licensed — chosen over Syncfusion specifically to avoid revenue-tier licensing constraints)
- Native text selection via pdfrx, with a custom-built highlight overlay layer (pdfrx provides selection, not persisted annotations — this is built, not out of the box)
- Highlights persist locally and reload correctly when a document is reopened
- Highlight tooltip on selection: **Ask AI** / **Generate Diagram**
- Tapping a saved highlight opens a small menu: **Ask AI** / **Diagram** / **Remove highlight**
- Document management: long-press a document to enter selection mode; multi-select; bulk **Delete** behind a confirmation dialog stating that highlights are removed too (the original PDF on the device is untouched); a snackbar with **Undo** follows for a short window
- Missing source file: the library row shows "File moved or deleted" with **Locate file** / **Remove**

### 5.2 Ask AI
- Free-form question input; highlighted text sent as context alongside the question
- Answer rendered in a bottom sheet, non-blocking to the reading view; the sheet expands to near-full height when the Diagram tab is opened
- Quoted preview of the *actual* highlighted text shown above the answer, so the user can recall their selection without scrolling back
- Chained **Generate Diagram** action available directly from the answer screen
- **Answer style** switch on the input sheet: **Explain** (default, direct) / **Hint first** (Socratic); the choice is saved in Settings

### 5.3 Generate Diagram
- Direct-from-highlight and chained-from-answer generation, per the flow in §4
- Single-call **classify-then-generate** prompt (see §6.2) — Gemini classifies the content's structure (process, hierarchy, comparison, relationship, or none) and either returns Mermaid syntax or a calm refusal message, in one request
- Mermaid output rendered via WebView + mermaid.js
- Answer/Diagram segmented tab when both exist for a highlight
- `"Elaborated from context"` badge shown when the diagram content was inferred rather than directly extracted from the source text
- Refusal state (no diagrammable structure) shown as a normal, non-error outcome with a suggestion to try Ask AI instead
- Pinch-to-zoom / pan on the diagram canvas, with zoom in / out / fit controls
- Each diagram type (process, hierarchy, comparison, relationship) has its own layout and node style, so output looks designed rather than generic

### 5.4 Storage & Scope
- Local-only storage (Hive/Isar) — no auth, no cloud sync, single device
### 5.5 Settings
- Gemini API key (view masked, edit; stored on device only)
- AI usage today (requests used of the daily cap, reset time)
- Default answer style (Explain / Hint first)
- Storage summary and **Clear all data**

### 5.6 Screen & State Inventory (design must cover each)
Library (empty, populated, selection mode, delete confirm, missing file) · Reader (selection tooltip, saved-highlight menu, scrambled-text banner) · Ask input · Answer sheet · Diagram (generating, Answer/Diagram tabs, elaborated badge, no-structure refusal) · Daily limit reached · Settings · Snackbars (saved, already highlighted, one request at a time, diagram failed, last request didn't finish, importing, documents deleted with Undo)

- Explicitly excluded from V1: OCR, scanned/image PDF handling, non-PDF formats, multi-device sync, cross-session AI chat memory

---

## 6. Technical Architecture

### 6.1 Stack
- **Framework:** Flutter, **MVVM architecture** with **Cubit** for state management (View → ViewModel/Cubit → Repository/Service layers)
- **PDF rendering:** pdfrx
- **AI:** Gemini API, **2.5 Flash-Lite** as the default model
- **Local storage:** Hive/Isar
- **Diagram rendering:** WebView wrapping mermaid.js (no mature pure-Dart Mermaid renderer exists)

### 6.2 AI Prompting Strategy
Each "Ask AI" or "Generate Diagram" action maps to exactly **one** API request — no separate validation call, no OCR pre-processing step. The diagram-generation prompt asks Gemini to:
1. Classify the highlighted content's shape: `PROCESS`, `HIERARCHY`, `COMPARISON`, `RELATIONSHIP`, or `NONE`
2. Return either valid Mermaid syntax matching that shape, or — only for genuine `NONE` cases (a single fact/definition/opinion with no structure) — a short user-facing refusal message
3. Flag `inferred: true` when the diagram elaborates beyond what's explicitly in the source text, so the UI can surface the "Elaborated from context" badge

Full prompt template and worked examples are maintained separately (`diagram_prompt_template.md`).

### 6.3 Quota Strategy
Built for the **Gemini free tier**, which has no dollar cost but hard **request-count** limits (RPM/RPD), not token-based cost. Flash-Lite (15 RPM / 1,000 RPD) is the default specifically because it has the most generous daily cap of the three tiers. Each user action = one request; UI must debounce rapid repeated taps to avoid burning quota on duplicates, and must surface a clear message (not a silent failure) if the daily cap is hit mid-session.

### 6.4 Known Technical Risks
- Multi-column and scanned academic PDFs may extract text unreliably — must be tested against real course material early (Milestone 2), before highlighting/AI work is built on top
- Mermaid output must be defensively parsed — a malformed/unparseable response from Gemini should degrade gracefully, not crash the diagram view
- Reading chrome is flat (hairline bar, no blur or `BackdropFilter`), so no blur performance risk in V1; still test scrolling on a real mid-range device

---

## 7. Design System (Summary)

Replaces the earlier dark-first system.

- **Two colors only:** ink `#17120D` on paper `#EAE3D3`. Secondary text, hairlines and highlight fills are the ink at reduced opacity (muted text stays at 70% or above for contrast). No gradients, blur or shadows.
- **Flat Apple-style minimalism:** hairline dividers, pill buttons, bottom sheets with a single ink top border, generous whitespace. 4px base grid; radii 18–28px for cards and sheets, 999px for pills.
- **Type:** Inter for UI, JetBrains Mono for labels, progress and status, Newsreader (serif) for PDF text and quoted passages.
- **State language (no extra colors):** selected text is inverted (paper on ink); a saved highlight is a light ink fill with an underline; an inferred diagram uses a dashed outline; warnings and errors are outlined; primary actions are filled ink.
- **ASCII accents (decorative only):** `━╌` progress bars, empty-state glyph, `░▒▓` loading ramp, blinking cursor, `█` usage meter.
- **Touch targets:** at least 44px.
- **Implementation note:** disable Material 3 `surfaceTint` and elevation overlays so no color cast appears on flat surfaces.
- **Reference influence:** Apple's minimalism; no Linear/Vercel dark-chrome look.

---

## 8. Edge Cases In Scope for V1

- Empty/whitespace text selection → no-op
- Re-highlighting an already-highlighted region → no duplicate/broken state
- Malformed Gemini JSON response → parsed defensively, doesn't crash the diagram view
- Daily quota exhausted mid-session → clear message, not a silent failure or infinite spinner
- Rapid repeated taps on Ask AI / Generate Diagram → debounced
- App killed mid-generation → no stuck "pending" state on relaunch
- Source PDF moved/deleted after import → handled without crashing
- Deleting a document → its highlights are removed with it; Undo restores both while the snackbar is visible
- Diagram with many nodes → must stay legible/zoomable on a phone screen, not silently overflow

Deferred to V2: scanned/image PDF handling (snip-to-image), cross-highlight linking, diagram history, export, additional file formats.

---

## 9. Definition of Done (V1)

The app is V1-complete when:
- A real course PDF can be imported, read, highlighted, questioned, and diagrammed end to end, on a real Android device
- The full chained flow (highlight → answer → diagram, with correct context passed at each step) works reliably
- The refusal state and the "Elaborated from context" badge both appear correctly in real use, not just in testing
- A 30+ minute real study session produces no crashes and no visually broken states
- The build is demoable — screen-recordable for a portfolio/YouTube video without narrating around bugs

Detailed task-by-task breakdown lives in `nota_v1_milestone_tracker.md`.

---

## 10. Open Decisions Carried Forward

- **Resolved for V1:** default **Ask AI** posture is direct explanation, with **Hint first** (Socratic) as a switch; revisit after real use
- Diagram type selection logic for genuinely ambiguous content (e.g. content that could reasonably be either a mindmap or a hierarchy) — currently resolved by instructing Gemini to pick confidently rather than asking the user, but worth revisiting after real usage data
