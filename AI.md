# AI Working Context

This file explains how the user typically works with an AI coding assistant in this project.

## Main context

Project objective: Port an StepMania 5.2 theme called Ultimate to PMOD (Pump It Up focused StepMania fork).

## What you need to know

- Inside the 'ultimate-master' folder there is the theme to be worked, this is the working folder.
- Inside the '_sm5.2themes' folder there is the current working environment which this theme works perfectly while running under StepMania 5.2
- Inside the '_fallback' folder there is the Fallback theme which has information that applies to all themes running in PMOD, every theme will be relying into this. Information inside this folder shall not be modified, this is not the working folder.
- Inside the 'pmod' folder there is the current default theme of PMOD. Information inside this folder shall not be modified, this is not the working folder.
- The `potentialissues.md` file contains the first PMOD port risk review. Use it as a reference before changing screen flow, noteskins, scoring, music select, gameplay, or evaluation behavior.
- The `portguidelines.md` file documents effective PMOD theme-port steps as they are proven useful. Update it when a repeatable porting step is discovered.

## Communication Style

- The user usually gives direct task-oriented requests.
- Common requests are short, for example:
  - `Execute roadmap.`
  - `Fix this.`
  - `Explain that error to me.`
  - `Bump the version, commit and push.`
- The user often provides screenshots to show the exact issue or desired UI result.
- The user prefers practical execution over long planning.
- The user does not want unnecessary changes outside the requested scope.
- When something is wrong, the user expects it to be acknowledged plainly and corrected quickly.

## Preferred AI Behavior

- Read the current notes/roadmap before acting when the request references `roadmap`.
- Execute first, explain second.
- Keep responses concise and focused on what changed, verification, and version/git status.
- Do not make unrelated improvements unless explicitly requested.
- Preserve existing design patterns unless the user asks for a redesign.
- If a change affects UI, compare against screenshots carefully.
- When the user points out a regression, prioritize restoring expected behavior before adding anything new.
- Keep roadmap execution tightly scoped to the exact pending item unless the roadmap says otherwise.

## Roadmap Execution Workflow

When the user says `Execute roadmap` or similar:

1. Follow the instructions written in the roadmap file, located at the project root.
2. The user may do changes on his own. The AI must evaluate them and if there's a better way to implement them suggest them and ask the user for confirmation.
3. If the current roadmap block has no tasks, do not invent work.
4. Do not propose upcoming tasks.

## Coding Preferences Inferred From Prior Work

- 

## Debugging Expectations

- Explain errors in plain language when asked.
- Distinguish clearly between:
  - app logic bugs
  - build/config issues
  - editor/path/cache problems
- If the issue is caused by environment confusion, stale caches, or old paths, say so directly.

## Git And Release Expectations

- Version bumps are important.
- Commits should be small, descriptive, and aligned with the work done.
- Pushes are expected after completed note executions.
- Do not include unrelated local changes in commits unless requested.
- If unrelated local changes exist, leave them untouched and mention that briefly.

## What To Avoid

- Do not over-explain simple changes.
- Do not ask unnecessary clarifying questions when the screenshots or the roadmap already define the task.
- Do not silently change behavior beyond the request.
- Do not leave roadmap/version files out of sync after a requested release step.

## Good Default Assumption

If the user gives a short imperative request, they usually want the AI to:

- inspect the relevant files,
- make the change,
- verify it,
- summarize the result briefly.
