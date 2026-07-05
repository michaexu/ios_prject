# Program Detail Change Design

**Goal:** Complete REQ-001 by ensuring program rows expose a non-disruptive detail entry, the detail sheet presents the required fields, and the requirement tracking document reflects completion.

**Scope:** This change stays inside the existing program list/detail flow in `ProgramsView`. We do not redesign Home cards or alter timer launch/edit behavior. We only tighten formatting to match the requirement log and add lightweight verification around the new formatting helpers.

**Design:**
- Keep the current `info.circle` entry point in `ProgramRow` for both preset and custom programs.
- Keep `ProgramDetailView` as the detail presentation surface so the start and edit affordances remain unchanged.
- Move the detail-view duration formatting to `Program` model helpers so the formatting rule is centralized and unit-testable.
- Update `Requirement-Change-Log.md` to mark `REQ-001` as completed now that the app behavior and acceptance criteria are satisfied.

**Acceptance Mapping:**
- Info button on preset and custom rows: preserved in `ProgramRow`
- Detail sheet fields: preserved in `ProgramDetailView`
- `分:秒` formatting: enforced through new `Program` formatting helpers
- No interference with start/edit: preserved by keeping independent buttons and sheet presentation
