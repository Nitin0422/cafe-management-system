# Project AGENTS.md

## Project-Specific Rules

- Follow the global `AGENTS.md` rules for all development work.
- Read `DESIGN.md` before implementing or modifying any frontend/UI.
- Treat `DESIGN.md` as the source of truth for visual design and UI decisions.
- Reuse existing project patterns and components before introducing new ones.
- Do not introduce new visual patterns without a clear product-specific reason.

## Git

- Commit frequently.
- Keep commits very small and focused.
- Each commit should represent one logical change.
- Prefer several small commits over one large feature commit.
- Do not bundle unrelated changes into the same commit.
- Commit after completing and verifying a small, coherent piece of work.
- Use clear, descriptive commit messages.

## Task Completion Checklist

Before asking for a human review:

- [ ] Boot the development server and smoke-test the app — start `bin/rails server` (or similar), confirm it boots cleanly, and load the key pages/flows affected by the task before requesting human review.
