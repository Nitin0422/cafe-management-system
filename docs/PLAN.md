# Aafnai Coffee — Implementation Plan

**Project:** Aafnai Coffee (cafe-management-system)
**Source:** Approved PRD v1.0 (2026-09-05). Approved task breakdown (`docs/TASK_PLAN.md`) on 2026-09-05.

## 1. Product Summary

Aafnai Coffee is a web-based management system for a single cafe branch. Staff
take orders and record payments at the counter; customers have accounts to view
reward points and credit-tab balances; admin manages menu, ingredient-based
inventory, staff, credit grants, and generates sales and credit reports.
Payment is **recorded, not processed** — actual card/cash handling stays at the
physical terminal.

## 2. Approved Decisions

- **Status:** Task breakdown approved by human manager on 2026-09-05.
- **Tech stack:** Ruby on Rails + PostgreSQL (workspace convention; assumed and
  confirmed by manager).
- **Scope:** v1 MVP only; all "Should Have / Nice to Have" PRD items are
  deferred to v1.1+.
- **Workflow:** 19 tasks; each task = 1 branch = 1 PR into `main`.
- **Credit model:** Unlimited, request-based credit; only per-customer
  suspension is admin-controlled.
- **Redemption:** Counter-only; points accrue at payment (cash/card) or
  settlement (credit); never negative.
- **Per-staff metrics:** attributed to the staff member who closed the order.
- **Currency:** all values in Nepali Rupees (Rs., NPR).
- **Attribution (FR-12):** every user-generated change attributed to the acting
  user.

## 3. Task Table

| ID | Task | Dependencies | Status |
|----|------|--------------|--------|
| T1 | Set up project scaffolding | — | Not started |
| T2 | Design & implement core data models | T1 | Not started |
| T3 | Implement authentication & role-based authorization | T2 | Not started |
| T4 | Implement staff account management (admin) | T3 | Not started |
| T5 | Implement admin menu management | T3, T2 | Not started |
| T6 | Implement inventory management (ingredients, recipes, stock) | T3, T5 | Not started |
| T7 | Implement customer registration & login | T3 | Not started |
| T8 | Implement rewards configuration (admin) | T5, T3 | Not started |
| T9 | Implement rewards engine & points ledger | T8, T2 | Not started |
| T10 | Implement credit/tab system | T7, T2, T3 | Not started |
| T11 | Implement order composition at the counter | T3, T5 | Not started |
| T12 | Implement order completion (payment, tab close, stock, points) | T11, T6, T9, T10 | Not started |
| T13 | Implement customer self-service dashboard | T7, T9, T10 | Not started |
| T14 | Implement admin reports | T12, T10 | Not started |
| T15 | Canonicalize customer phone numbers | T7 | Not started |
| T16 | Enforce minimum password length | T7 | Not started |
| T17 | Establish design system foundation | None (baseline main) | Not started |
| T18 | Apply design system to auth & home screens | T17 | Not started |
| T19 | Apply design system to admin screens | T17 | Not started |

## 4. Dependency-Honoring Implementation Order

```
1. T1 → 2. T2 → 3. T3 → 4. T4 → 5. T5 → 6. T6 → 7. T7 → 8. T8 → 9. T9 →
10. T10 → 11. T11 → 12. T12 → 13. T13 → 14. T14
```

- **First unblocked task:** T1 — Set up project scaffolding.
- **Critical convergence point:** T12 — Order completion (atomic close of order
  + payment/tab + stock decrement + points).

### Approved additions (2026-09-11)

Five follow-up tasks were approved by the human manager on 2026-09-11:

- **T15 / T16** are independent bug-fix follow-ups to T7 (customer registration
  & login). They can be worked in any order and are not on the critical path.
- **T17 → T18 → T19** is the UI/design-system work order. T17 (design-system
  foundation) must be completed before T18 or T19 can begin. T18 and T19 are
  independent of each other once T17 is done.

## 5. Per-Task Requirements & Acceptance Criteria

Full per-task requirements, acceptance criteria, technical considerations, and
testing requirements live in the Notion task cards (created in the Aafnai
Coffee board) and in the approved breakdown `docs/TASK_PLAN.md`. Refer to those
as the authoritative per-task detail.

### Requirements coverage (functional traceability)

| Functional requirement | Covered by |
|---|---|
| FR-1 Auth (admin/staff/customer; email or phone for customers) | T3, T7 |
| FR-2 Staff accounts + single role | T4 |
| FR-3 Menu management | T5 |
| FR-4 Order composition | T11 |
| FR-5 Order close (payment or tab) | T12 |
| FR-6 Decrement stock + accrue points | T12 |
| FR-7 Customer register/login + dashboard | T7, T13 |
| FR-8 Rewards config + counter redemption, never negative | T8, T9, T11/T12 |
| FR-9 Credit (charge, payments, suspend, report) | T10, T12, T14 |
| FR-10 Inventory (ingredients, recipes, stock, alerts) | T6 |
| FR-11 Sales & credit reports; per-staff metrics | T14 |
| FR-12 Attribution to acting user | T2 (pattern), T3 (frame), T10/T12 (enforced) |

## 6. Testing & Documentation Strategy

- **Testing:** Automated tests per task (unit/system specs) covering expected
  behavior, edge cases, failure paths, and authorization. RSpec + system tests.
  CI runs the suite on each PR. Highest-risk atomic testing is T12 (order
  completion side effects).
- **Documentation:** README established in T1 (setup, run, test). Per-task
  documentation maintained alongside implementation. `docs/PLAN.md` and
  `docs/TASK_PLAN.md` kept synchronized with approved plan revisions.

## 7. Deferred Scope (v1.1+)

Customer order history, in-app redemption requests, split payments,
cancel/refund reversal, manual point/credit adjustments + audit, CSV export,
purchase-unit ↔ recipe-unit conversion, suppliers/POS, "86'd" toggling,
email/SMS alerts, top-items/customers mini-reports.
