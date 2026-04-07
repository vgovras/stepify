# Plan Mode Rules

> How to behave in plan mode — think like a product manager and architect before writing a single line of code.

## 1. Plan First, Code Never First

Before writing any code, produce a structured plan that includes:

1. **Business goal** — what problem does this solve? What is the user value?
2. **Use cases** — concrete usage scenarios with expected behavior
3. **Prior art** — how do similar products solve this? What can we learn?
4. **Scope** — what's in, what's explicitly out
5. **Data model changes** — new/modified models, fields, relationships
6. **Architecture** — which layers/features are affected, dependency flow
7. **Affected files** — list every file that will be created or modified
8. **Reuse inventory** — existing code that must be reused (see rule 5)
9. **Edge cases** — null inputs, empty states, concurrent access, error paths
10. **Test strategy** — what to test, how to verify

**Rule of thumb:** if you cannot describe the exact diff in one sentence, you must plan first.

## 2. Identify and Ask About Information Gaps

Before proceeding with a plan, ask yourself these questions:

- Do I fully understand the business goal, or am I guessing?
- Are there acceptance criteria, or am I inventing them?
- Does this touch areas of the codebase I haven't read?
- Are there architectural decisions that need the developer's input?
- Is the scope clear, or could it mean multiple things?

**If any answer is "no" or "unsure" — stop and ask the developer.** List specific questions, not vague "anything else?" prompts. Propose your best guess alongside each question so the developer can simply confirm or correct.

```
Example:
"The spec says 'timer notification' — I assume this means flutter_local_notifications 
with a scheduled zonedSchedule() call, not a push notification from a server. Correct?"
```

## 3. Reference Existing Code, Don't Write Examples

In plan mode, **never write code snippets** to demonstrate a pattern. Instead, link to existing code in the project:

```
GOOD: "Follow the same pattern as `lib/features/cook/widgets/step_card.dart:15-42` 
       — a StatelessWidget with const constructor and single-responsibility build()"

BAD:  "Here's how the widget should look:
       class NewWidget extends StatelessWidget { ... }"
```

If no similar code exists in the project yet, reference the relevant rule file instead:

```
"Follow the widget extraction pattern described in .claude/rules/widgets.md"
```

## 4. Predict and Prevent Code Duplication

Before proposing new code, **search the codebase** for:

- Existing functions that do the same or similar thing
- Widgets that could be parameterized instead of duplicated
- Utility functions that already handle the edge case
- Constants/theme tokens that already define the value

List them explicitly in the plan under **Reuse Inventory**:

```
Reuse Inventory:
- pickNextStep() in step_graph.dart — reuse for step availability check
- NoteBlock widget — parameterize for new note types instead of creating NoteBlockV2
- AppColors.ac in theme.dart — don't hardcode #E8B44C
- TimerService._tick() — extend, don't create parallel timer logic
```

## 5. Extract Before Adding

When the plan reveals that new code overlaps with existing code:

1. **Identify the common pattern** across both locations
2. **Propose extracting** it into a shared function/widget/mixin first
3. **Then use the extraction** in both the existing and new code

Less code is always better. Three lines of duplication are acceptable; ten are not.

```
Example:
"Steps 1-2: Extract _formatDuration() from cook_screen.dart into shared/utils/time_format.dart
Step 3: Use the extracted function in both the float bar and the new timer block"
```

## 6. Think Like a Product Manager

In plan mode, don't just describe implementation steps. Start with:

- **Why** — what user problem does this solve? What metric does it improve?
- **What** — describe the feature from the user's perspective (user story format)
- **How others do it** — research 2-3 similar apps/products for inspiration
- **What could go wrong** — UX pitfalls, performance risks, edge cases users will hit

```
Example:
"## Business Goal
Users lose track of multiple background timers during complex recipes like Borscht.
The float bar feature solves this by showing active bg timers at a glance.

## How Others Solve This
- Mealime: no parallel timers at all (simpler but limiting)
- Kitchen Stories: separate timer tab (requires navigation away from current step)
- Our approach: inline float bars — zero navigation, always visible

## UX Risks
- More than 2 float bars will crowd the screen on small devices
- Timer urgency animation (<1 min) must not distract from the current step text"
```

## 7. Self-Reflection Checklist

Before finalizing any plan, ask yourself:

### Completeness
- [ ] Do I have enough information to start, or should I ask the developer?
- [ ] Have I read every file I'm planning to modify?
- [ ] Have I checked for existing code that does what I'm about to create?

### Quality
- [ ] How can I make this better than my first instinct?
- [ ] How have people solved this before in similar projects?
- [ ] Is this the minimum viable change, or am I over-engineering?
- [ ] Would I be embarrassed if this broke in production?

### Risks
- [ ] What happens if this runs twice concurrently?
- [ ] What if the input is null, empty, or enormous?
- [ ] Does this change affect other features I haven't considered?
- [ ] What assumptions could be wrong?

### Reuse
- [ ] Does this duplicate something that already exists?
- [ ] Can I solve this by extending existing code instead of adding new code?
- [ ] Am I creating an abstraction that will only be used once?

## 8. Plan Output Format

Structure every plan as:

```markdown
## Business Goal
[1-2 sentences: what user problem this solves]

## Use Cases
- [User story 1]
- [User story 2]

## Prior Art
- [How similar product X handles this]
- [How similar product Y handles this]

## Reuse Inventory
- [Existing code to reuse, with file:line references]

## Scope
- IN: [what's included]
- OUT: [what's explicitly excluded]

## Implementation Steps
1. [Step — with file paths, not code]
2. [Step]

## Edge Cases
- [Edge case and how to handle it]

## Test Plan
- [What to test and how]

## Open Questions
- [Question for the developer, with your best guess]
```
