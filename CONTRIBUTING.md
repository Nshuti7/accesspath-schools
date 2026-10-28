# Contributing to AccessPath Schools

This page explains how the Ctrl Freaks team built AccessPath Schools and how to
contribute.

## How we worked

**Planning.** We chose the problem from the Ministry of Education and Sports' School
Accessibility Companion Guide and defined a focused MVP: checklist, photo check, gaps,
actions.

**Project management with YouTrack.** Our project, "AccessPath Schools" (AS), lives at
ctrl-freaks.youtrack.cloud. Each team member has a parent task with subtasks, priorities,
due dates and states (To do, In Progress, Done). Testers file bugs as new AS issues linked
to their testing task, and we track each fix to Done.

**Development.** Flutter, Firebase and Gemini, built with help from Claude Code. Every
feature was reviewed and committed in small steps on GitHub.

**Quality.** Code review by Jalia, end-to-end testing by Umar and Baker, and bug reports in
YouTrack.

**Responsible AI.** The checklist and recommendations come from the official guide, with
page references. AI only flags possible issues for a person to verify.

## Reporting a bug

1. Create a new issue in the AS project on YouTrack.
2. Say what you did, what you expected and what happened. Add a screenshot if you can.
3. Link it to your testing task.

## Making a change

1. Pick a task in YouTrack and move it to In Progress.
2. Work on one screen or feature at a time.
3. Before committing, run:

   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

   Fix every warning before you commit.
4. Commit with a short, plain message in the imperative, for example `Add login screen`.
5. Move the task to Done.

## Code style

- Use clear names that say what things are, such as `ChecklistItem` and `GapCard`.
- One public widget per file. Keep files under about 200 lines.
- Comments explain *why*, not what the code does.
- No emojis and no `print`.
- Keep UI text short and plain, and store repeated strings in one place.
- Ask the team before adding a package.

## Rules we never break

- Never invent accessibility requirements, measurements or guide page references. If an
  item is not confirmed from the guide, mark it `"guideRef": "TODO"` and tell the team.
- Every AI finding is shown as "Possible issue – needs verification". The app never says a
  school is compliant or certified.
- Photos are sent to Gemini and only the result is saved. Never upload images to storage.
- No learner data. Only staff names and emails.
