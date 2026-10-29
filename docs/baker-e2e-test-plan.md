# Baker E2E test plan — gaps, actions, dashboard and AI

**Task:** AS-5 — Baker, end-to-end testing of the second half of the user journey
**Tester:** Shamil Baker
**Build under test:** web `https://gen-lang-client-0366595329.web.app` · Android APK from Jalia/Brice
**Prepared:** 29 Oct 2026, from a review of the source at `main` (`65267c2`)
**Status:** test script ready — live results to be filled in below

> This script was written from the code, not from a live run: I could not drive the
> deployed app or YouTrack from this machine. Expectations below are what the code is
> designed to do. Use the *Actual* and *Result* columns during the real test pass.

---

## 1. Scope

In scope: the second half of the journey.

1. Gaps — how they are created, prioritised and resolved
2. Action tracker — assigning, deadlines, status changes, resolving a gap
3. Dashboard — score, counts, next steps and area progress
4. AI features — guide assistant and AI report summary
5. Cross-device and layout behaviour (web desktop/tablet/phone, Android APK, offline)

Out of scope (covered by other testers): sign-up/login details, checklist content accuracy,
photo-check model quality beyond the gap it creates.

---

## 2. Setup and data hygiene

- [ ] Create a **fresh test school account** (e.g. `baker.test+<date>@…`). Never use real learner data.
- [ ] Install/keep a second fresh account from another school for isolation checks (X11).
- [ ] Get the **Ministry guide PDF** from Brice for the accuracy table (section 6).
- [ ] Get the **Android APK** from Jalia/Brice and note its version/build.
- [ ] Confirm network, and note today's date so overdue checks are unambiguous.
- [ ] Take screenshots for every failure. Do not screenshot real learner data.

Useful numbers from the build: **25 checklist items** across 6 areas (entrances 4,
ramps/pathways 6, classrooms 4, toilets 5, signage 3, safety 3); **10 high / 13 medium /
2 low** priority items. The guide condensed text covers pages I-III and 1-33.
Layout breakpoints: **800 px** (side rail) and **1000 px** (desktop sidebar, tables,
split checklist). AI model: `gemini-3.5-flash`; AI requests time out at 60 s.

---

## 3. Device and browser matrix

| ID | Device / browser | Size | What to check |
|---|---|---|---|
| W1 | Windows Chrome | 1440 × 900 | desktop sidebar, gap/action tables |
| W2 | Windows Edge | 1280 × 800 | same |
| W3 | Windows Firefox | 1280 × 800 | same, clipboard/copy |
| W4 | Chrome responsive | 1024 × 768 | desktop threshold, horizontal table scroll |
| W5 | Chrome responsive | 900 × 700 | side rail |
| W6 | Chrome responsive | 799 × 700 | bottom navigation, 5 items |
| W7 | Chrome responsive | 390 × 844 | phone portrait |
| W8 | Chrome responsive | 360 × 800, 1.3× text | narrow phone / text scaling |
| A1 | Android phone (APK) | 360-412 dp | install, camera/gallery, back button |
| A2 | Android phone landscape | — | keyboard, date picker, chat input |
| A3 | Android tablet (if available) | 800/1024 dp | rail/desktop layout |
| A4 | Android emulator | Android 7.0 | minimum supported version |

Record the exact OS/browser versions in the bug reports.

---

## 4. Gaps

Expected behaviour: a checklist **No** creates an Open gap; **Unsure** creates a
Needs-verification gap; **Yes** resolves an existing checklist gap; a photo finding the
tester accepts creates an AI-photo gap labelled "Possible issue — needs verification".
Gap counts must always equal the dashboard numbers.

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| G1 | Answer **No** to a high-priority checklist item | Gap report shows the item, **High**, **Open**, source **Checklist**, guide page and "What to do" recommendation | | |
| G2 | Answer **Unsure** to another item | Gap shows **Needs verification**; dashboard "Needs verification" tile increases by 1 | | |
| G3 | Change G1's answer from No to **Yes** | Gap becomes **Resolved**, leaves the active list (phone: under "Resolved gaps (n)"), Open count drops, Resolved count rises | | |
| G4 | Change the same answer back to **No** | Gap reopens as **Open**; counts move back | | |
| G5 | Tap **No** again on an already-open item | No duplicate gap; count unchanged | | |
| G6 | Open an area → **Photo check** → take/choose a clear photo → **Accept** a finding | Snackbar "Added to the gap report"; gap shows **AI photo** badge and "Photo check saw"; no photo thumbnail is stored | | |
| G7 | In photo check, **Dismiss** a finding | No gap created; "All findings reviewed" when the last one is handled | | |
| G8 | Look at the status of the accepted photo gap | **Needs verification** (AI findings are possible issues). Currently the code creates it as **Open** — see S1 | | |
| G9 | Desktop: sort the gap table by Priority, Question, Area, Source, Status, Owner, Due date; open a row | Sort works both directions; row opens the full gap card with recommendation and Assign | | |
| G10 | Phone: look at gap sections | High / Medium / Low sections, Needs-verification items after confirmed ones, Resolved collapsed | | |
| G11 | Assign a gap → save the action | Gap card/table shows owner and due date; Assign button is replaced by the assignment | | |
| G12 | On a school with no gaps | "No gaps yet…" message; **Generate summary** button absent | | |

**Gaps: ___ / 12 passed**  Failures: ________  Bugs: ________

---

## 5. Action tracker

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| A1 | Assign action with empty title / owner / due date | Inline "Please fill this in" / "Please choose a due date"; nothing saved | | |
| A2 | Open the due-date picker | Past dates disabled; earliest is today; latest ~2 years out; chosen date shown as "3 Nov 2026" | | |
| A3 | Save a valid action | Snackbar "Action saved"; returns to the gap report; action appears on the tracker sorted by due date | | |
| A4 | Check an action due yesterday, one due today, one Done | Yesterday: red outline + "Overdue, was due …"; today: not overdue; Done: never overdue | | |
| A5 | Change status To do → In progress → Done | Bottom sheet shows current selection; status persists after navigating away and reloading | | |
| A6 | Set an action **Done**, then "Yes, resolve" | Snackbar "Gap marked as resolved"; gap becomes Resolved; dashboard Resolved/Open counts update | | |
| A7 | Set an action **Done**, then "Not now" | Action is Done; gap stays open. Check whether that high-priority gap is still surfaced on the dashboard (see S5) | | |
| A8 | Use the All / To do / In progress / Done chips | Correct filtering; "No actions with this status" for an empty filter | | |
| A9 | Desktop: check initial sort and row click | Sorted by due date; any column sorts; row opens the status sheet; table scrolls sideways rather than squashing | | |
| A10 | Assign two actions to the same gap (use the gap's `/gaps/<gapId>/assign` URL directly) | Ideally prevented or warned; currently possible — see S7 | | |
| A11 | Add notes; view on phone and desktop | Notes wrap and are readable; no overflow | | |
| A12 | Change status while offline, then reconnect | Offline banner shows; change applies locally; it persists after reconnect/reload (or shows a clear error if it cannot save) | | |

**Actions: ___ / 12 passed**  Failures: ________  Bugs: ________

---

## 6. Dashboard

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| D1 | New school, no answers | "Start your first assessment" card + area progress at 0; no score ring or stat tiles | | |
| D2 | Answer the first question | Dashboard switches to score card, "1 of 25 questions answered", four tiles, next steps, progress | | |
| D3 | Answer 3 Yes and 2 No (5 answered) | Score shows **60%** (Yes ÷ answered), not 3 ÷ 25; explanation text is visible | | |
| D4 | Compare tiles with the gap report | Open, Needs verification and Resolved tiles match the gap report counts exactly | | |
| D5 | Make an action overdue | "Overdue actions" tile matches tracker, warning styling, tapping opens Actions | | |
| D6 | Tap Open/Needs/Resolved tiles | All open the Gap report | | |
| D7 | Check Next steps | Only high-priority open/confirmed gaps with no action, max 3, checklist order; Assign opens a prefilled action form and saving returns to the dashboard | | |
| D8 | Give every high-priority gap an action (including one Done but not resolved) | "Every high-priority gap has someone working on it" — confirm that the Done-but-unresolved gap is or is not surfaced (S5) | | |
| D9 | Check Progress by area | Each area shows correct answered/total (e.g. 2/6) and opens that area | | |
| D10 | Photo-only school: accept a photo gap without answering any question | Dashboard should show the open gap. Currently it still shows "Start your first assessment" and hides all tiles — see S3 | | |
| D11 | Check greeting and school name | Time-of-day greeting; school name shown once; desktop header vs phone body correct | | |
| D12 | Resize 1440 → 1100 → 720 → 390 | Cards side by side above 720; one column below; no overflow when tiles go two-by-two on phones | | |

**Dashboard: ___ / 12 passed**  Failures: ________  Bugs: ________

---

## 7. AI guide assistant

Rules to verify: answers only from the guide, cite printed pages, never claim compliance,
plain English, no Markdown, out-of-scope questions politely refused, failed question is
offered back, chat is not saved and clears when the user changes.

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| GA1 | Open Guide with an empty chat | Intro text and four starter questions; tapping one sends it and shows the answer with the source note | | |
| GA2 | Ask a typed question with Enter and with the send button | One message sent each time, no duplicate | | |
| GA3 | Ask the 10 questions in the accuracy table | Page cited and content both correct; partial if content right but page wrong | | |
| GA4 | Ask "What is the capital of Uganda?" | Politely says it only helps with school accessibility/the guide | | |
| GA5 | Ask something the guide does not cover | "The guide does not cover this" (or closest section), no invented standards | | |
| GA6 | Ask 7-8 questions in one chat | Every answer still succeeds. The code sends only the last 12 messages, which can start with a model turn — see S4 | | |
| GA7 | Go offline and ask | Friendly "No internet" error; question is put back in the input and can be resent | | |
| GA8 | While "Looking in the guide…" is shown, press send again | Send is disabled; no duplicate request | | |
| GA9 | Log out, log in as the second account, return to Guide | Previous chat is gone; nothing is restored after a page reload | | |
| GA10 | Inspect answer formatting | Plain text, `- ` lists, no `**`, `#` or other Markdown symbols | | |

**Guide: ___ / 10 passed**  Failures: ________  Bugs: ________

### 7.1 Guide assistant accuracy table

Fill the *Page cited* and *Correct?* columns while testing. "Correct page" is the page in
the Ministry PDF; the bracketed page is what the condensed guide in the app suggests.

| # | Question | Page cited in answer | Correct page (PDF) | Correct? (Y / Partial / N) | Notes |
|---|---|---|---|---|---|
| 1 | How steep can a ramp be? | | 12 (method on 31) | | |
| 2 | What does an accessible toilet need? | | 16 (compartment 17-18, rails 19-20) | | |
| 3 | How wide should classroom doors be? | | 7-8 | | |
| 4 | How do we start an accessibility assessment? | | III | | |
| 5 | What gradient is allowed for a ramp? | | 12 | | |
| 6 | What are the handrail rules for stairs? | | 14 | | |
| 7 | What size should an accessible toilet compartment be? | | 17-18 | | |
| 8 | Do signs need to be in braille? | | 2 (room signs 7-8) | | |
| 9 | What is the minimum door width for a secondary school? | | 8 | | |
| 10 | What does the guide say about desk heights? | | 27-28 (29) | | |
| 11 | Out of scope: "Who won the 2022 World Cup?" | — | Refuse | | |
| 12 | "Is our school compliant?" | — | Must not certify; explain self-check | | |

**Accuracy: ___ correct + ___ partial out of 10 content questions; refusal checks: ___ / 2**

---

## 8. AI report summary

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| RS1 | Open Gap report with gaps | **Generate summary** in the header (desktop) / summary card (phone); hidden when there are no gaps | | |
| RS2 | Generate | Overview covers answered count, score, open/needs-checking gaps; ≤3 priorities; 2-4 next steps | | |
| RS3 | Check priorities against the report | Prefers high priority and confirmed gaps; each has a short reason; pages appear only when in the data and never invented; gap marked "needs checking" is described as needing a check | | |
| RS4 | Check trust language | No "compliant", "accessible", "certified" or "approved"; if none open, says none found so far and suggests keeping it up to date | | |
| RS5 | Press **Copy**, paste somewhere | Text starts with the AI label, then overview, priorities and steps | | |
| RS6 | Generate again, then force a failure (go offline) and generate | On failure: friendly error. Confirm whether an old summary is still shown next to it — see S8 | | |
| RS7 | Check error cases: offline, quota, unreadable reply | Friendly message for each; button can retry; summary stays while on the page, gone after leaving and returning | | |
| RS8 | Check data sent | Only school name, stats, non-resolved gaps and overdue actions; no emails, no photos; owner names only for actions | | |
| RS9 | Resolve every gap, then generate | Summary still generates and says no open gaps; counts are consistent | | |
| RS10 | Phone: long summary | Wraps without overflow; Copy works on Android (clipboard) and web | | |

**Summary: ___ / 10 passed**  Failures: ________  Bugs: ________

---

## 9. Cross-device, layout, offline and isolation

| # | Step | Expected | Actual | Pass/Fail |
|---|---|---|---|---|
| X1 | Phone 360/390: use every tab and action | Bottom nav has all 5 items with readable labels; no overflow at 1.3× text | | |
| X2 | 800-999 px: check rail layout | Side rail, page keeps app bar; gap/action lists show cards, not tables | | |
| X3 | ≥1000 px: sidebar, tables, split checklist | Tables scroll sideways at 1000; split checklist area pane works | | |
| X4 | Web: refresh on `/gaps`, `/actions`, `/guide`, `/gaps/<id>/assign`; use browser back/forward | Hosting rewrite serves the app; deep links and back/forward keep the right screen | | |
| X5 | Android: install the APK and sign in | Installs on Android 7+, opens, logs in over mobile data/Wi-Fi | | |
| X6 | Android: photo check with camera and gallery | Both sources work; permission prompt behaves; photo is not saved | | |
| X7 | Rotate the phone on the assign form, date picker and guide chat | Layout survives; keyboard does not cover the field/send button | | |
| X8 | Turn airplane mode on/off on web and Android | Offline banner appears/disappears; queued answer/status saves; no silent loss | | |
| X9 | Same account on two devices: change on A, look at B | Ideally B updates or prompts to refresh. The providers load once with `.get()`, so B stays stale until reload — see S6 | | |
| X10 | Second school account | No data from the first school appears anywhere (gaps, actions, dashboard, chat) | | |
| X11 | Log out and back in | Dashboard, gaps, actions, summary and chat are cleared/reset correctly | | |

**Cross-device: ___ / 11 passed**  Failures: ________  Bugs: ________

---

## 10. Suspected issues from the code review

Confirm each on the live build before filing. Severity is a suggestion, not the final call.

| ID | Severity | Issue | Evidence | How to reproduce |
|---|---|---|---|---|
| S1 | High | AI photo findings are saved as **Open**, although the photo-check UI calls them "Possible issue — needs verification". The report summary then labels them "confirmed" rather than "needs checking". | `lib/providers/assessment_provider.dart:117` (no status, defaults to open); `lib/services/report_summary_service.dart:116` (only `needs_verification` maps to "needs checking") | Photo check → Accept a finding → Gap report shows Open; generate a summary and see it treated as confirmed |
| S2 | High | There is no way to **verify** a "Needs verification" gap. No screen sets status `verified`; the only status change available is Resolve, via a completed action. | `Gap.statusVerified` is defined but never written by UI; `lib/screens/actions/action_tracker_screen.dart:67` is the only gap-status write | Answer Unsure → gap Needs verification → look for a Verify/Confirm control anywhere |
| S3 | Medium | Dashboard hides the score, all four tiles and Next steps until at least one checklist question is answered. A school that only uses photo check sees "Start your first assessment" despite having gaps. | `lib/screens/dashboard/dashboard_screen.dart:109`, `:168` (`answeredCount == 0`) | Fresh account → photo check → accept a gap → Dashboard |
| S4 | Medium-High | Guide chat history trimming can start with a model turn. The user question is appended before sending, so with more than 6 exchanges the last 12 messages begin with an assistant answer; Gemini expects a user turn first. May cause failed or degraded answers on long chats. | `lib/services/guide_assistant_service.dart:54-56`; `lib/services/guide_chat_provider.dart:38` (question appended before `ask`) | Ask 7+ questions in one chat and keep going |
| S5 | Medium | A high-priority gap whose action is **Done** but was not resolved disappears from "Next steps" because any action hides the gap, yet it still counts as open. | `lib/screens/dashboard/next_steps_card.dart:27-34` | High-priority No → assign → Done → "Not now" → Dashboard |
| S6 | Medium | Data does not refresh across devices/tabs. Providers load once with `.get()` and only retry on error; returning to the app does not reload. Two staff editing on different devices see stale numbers until a manual reload. | `lib/services/firestore_service.dart` read methods; providers' `load()` | Change a gap/action on device A; leave B open/reopen; compare |
| S7 | Low-Medium | The same question can produce two gaps (an AI-photo gap plus a checklist gap), and a gap can get two actions via its assign URL. Counts then overstate the problem. | `assessment_provider.dart:117` (generated id) vs checklist gap keyed by item id; no duplicate-action guard in `action_provider.dart` | Accept a photo finding, then answer No to the same item; or open `/gaps/<id>/assign` twice |
| S8 | Low | "Generate again" keeps the previous summary visible while loading and after a failure, next to the error, so stale text can look current. | `lib/screens/gaps/report_summary_controller.dart:24-35` | Generate successfully → go offline → Generate again |
| S9 | Low | Pressing Enter/send while an answer is already waiting clears the typed text even though the request is ignored. | `lib/screens/guide/guide_assistant_screen.dart:39-45`; `guide_chat_provider.dart:41` (`_isWaiting` guard) | While "Looking in the guide…", type and press send |
| S10 | Low | An **Unsure** answer downgrades a Verified gap to Needs verification; only **No** preserves Verified. The code comment says verified gaps should not be downgraded. | `lib/models/gap.dart:59-69` | Only reachable with seeded data today (see S2) |

Minor copy observations to confirm visually: the guide assistant source note is the same
for every answer (nothing distinguishes a "guide does not cover this" reply), and the
summary card has no visible "not saved" note on phones.

---

## 11. Automated coverage already in place

`flutter analyze`: no issues. `flutter test`: **49 tests, 49 passed** (16 files).
Relevant to this task:

- `gap_test.dart` — No/Unsure/Yes transitions, verified gaps stay verified, re-open, no-op
- `assessment_stats_test.dart` — score is Yes ÷ answered; no score when unanswered; verified counts as open
- `action_item_test.dart` — overdue rules, map round-trip, date wording
- `report_summary_test.dart` — data sent, ≤3 priorities, malformed replies, AI label on copy
- `report_summary_controller_test.dart` — success and friendly error states
- `guide_chat_provider_test.dart` — send, failure restores the question, user change clears
- `guide_knowledge_test.dart` — <15,000 words, every heading names a guide page
- `gemini_service_test.dart` — finding parsing, unknown ids skipped, unreadable reply
- `stat_tiles_test.dart`, `sortable_table_test.dart`, `app_shell_test.dart`, `offline_banner_test.dart` — layout/sorting/offline
- `checklist_item_card_test.dart`, `checklist_data_test.dart`, `district_field_test.dart`, `school_test.dart` — earlier journey

Not covered automatically: real AI answers/citations, Firestore rules, photo check, live
navigation, and anything across two devices.

---

## 12. Bug log

File each issue in the **AS** project and link it to AS-5 ("relates to"). Template:

```text
Title: <short description>

Steps to reproduce:
1.
2.
3.

Expected:
Actual:
Device / browser:
Screenshot:
```

| Bug | AS issue | Title | Subtask | Severity | Status |
|---|---|---|---|---|---|
| S1 | | | Gaps / AI summary | High | To confirm |
| S2 | | | Gaps | High | To confirm |
| S3 | | | Dashboard | Medium | To confirm |
| S4 | | | Guide | Medium-High | To confirm |
| S5 | | | Dashboard / Actions | Medium | To confirm |
| S6 | | | Cross-device | Medium | To confirm |
| S7 | | | Gaps / Actions | Low-Medium | To confirm |
| S8 | | | AI summary | Low | To confirm |
| S9 | | | Guide | Low | To confirm |
| S10 | | | Gaps | Low | To confirm |
| | | | | | |

---

## 13. Pass / fail summary

Fill these from the tables above.

| Subtask | Cases | Pass | Fail | Blocked | Bugs filed |
|---|---|---|---|---|---|
| Gaps | 12 | | | | |
| Actions | 12 | | | | |
| Dashboard | 12 | | | | |
| Guide assistant | 10 + accuracy | | | | |
| AI report summary | 10 | | | | |
| Cross-device / offline | 11 | | | | |
| **Total** | **67** | | | | |

---

## 14. Top 5 suggestions to improve the app

1. **Treat AI photo findings as unconfirmed.** Save them as `needs_verification`, show
   "Needs verification" on the gap card, and make the report summary say "needs checking"
   for them. This keeps the AI label honest and matches the Responsible AI promises.
   (`assessment_provider.dart:117`, `report_summary_service.dart:116`)
2. **Add a verify/confirm step for gaps.** Let staff set a gap from "Needs verification"
   to "Verified" (and back) from the gap card, with who/when. Today Verified is
   unreachable and Unsure gaps can only be resolved indirectly through an action.
   (`gap_card.dart`, `action_tracker_screen.dart:67`)
3. **Show the dashboard as soon as there is anything to show.** Base the score/stat tiles
   on answers *or* gaps/actions, so a photo-only or action-only school still sees open
   gaps, overdue work and next steps instead of "Start your first assessment".
   (`dashboard_screen.dart:109`, `:168`)
4. **Make the guide assistant robust and checkable.** Trim history on a user turn, not a
   fixed 12 messages; require a `(Guide p. X)` citation and flag pages outside I-III/1-33
   or TODO; show when the guide does not cover the question. (`guide_assistant_service.dart:54`)
5. **Close the loop across devices and completed actions.** Refresh providers on app
   resume/visibility change (or listen to the school's collections), and put high-priority
   gaps whose action is Done-but-unresolved back into Next steps. Prevent duplicate
   actions for one gap at the same time. (`next_steps_card.dart:27`, provider `load()`)

---

## 15. Honest view — would a headteacher understand and trust the results?

Write this after the live pass; the prompts below are what to look for.

- **Understandable?** Is "Accessibility score" clear that it is Yes ÷ answered, not Yes ÷ 25?
  Do "Open gaps" vs "Needs verification" vs "Resolved" mean what a headteacher expects?
  Are the next steps actionable without reading the guide?
- **Trustworthy?** Does the app ever sound like it certifies the school? Are AI findings
  clearly marked as possible issues, and is there a visible way to confirm them? Are the
  page citations right according to the PDF? Do the dashboard numbers agree with the gap
  and action lists after edits and reloads?
- **Would they act on it?** Can they hand the action list to a facilities manager and
  follow it up? Is it obvious what is overdue and who owns it?

**Preliminary code-level view (to be checked live):** the wording is deliberately cautious
("self-check, not a certification", AI label, guide pages), which supports trust. The main
trust risks are (a) AI photo findings appearing as confirmed open gaps, (b) no visible
verify step for "Needs verification", and (c) a score that could be read as "out of the
whole school" rather than "out of questions answered". If those are fixed, a headteacher
should be able to understand the page and act on it; without them, a careful headteacher
may question why an AI's guess is listed as a confirmed barrier.

---

## 16. AS-5 comment draft (fill the blanks)

```text
Baker — end-to-end testing: gaps, actions, dashboard and AI

Build: web <url> / Android APK <version>, tested <date>.
Accounts: fresh test school <name>, second school for isolation.

Pass/fail per subtask
- Gaps: __/12
- Actions: __/12
- Dashboard: __/12
- Guide assistant: __/10 (accuracy: __/10 content correct, refusals __/2)
- AI report summary: __/10
- Cross-device/offline: __/11
Total: __/67.

Bugs filed and linked to AS-5:
- AS-__ <title> (S1, high)
- AS-__ <title> (S2, high)
- ...

Guide assistant accuracy: <link to the table / paste summary>. Pages checked against the
Ministry PDF supplied by Brice.

Top 5 improvements
1. ...
2. ...
3. ...
4. ...
5. ...

Honest view: <2-4 sentences: would a headteacher understand and trust it, and why>
```
