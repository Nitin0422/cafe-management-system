# Task Plan — Aafnai Coffee (cafe-management-system)

**Source:** `docs/prd.md` / `prd.md` — v1.0 (approved 2026-09-05)
**Planner phase:** Phase 1 draft (unapproved). No Notion content exists.
**Status:** DRAFT — pending human manager review.

---

## 0. Assumptions (must be confirmed by the human manager)

- **Tech stack is NOT specified in the PRD.** The repository is empty (only
  `.vscode/` and `prd.md`). This draft assumes the established workspace
  convention (the existing "Expense Tracker" project): **Ruby on Rails +
  PostgreSQL**, with a **system test / RSpec** testing setup and CI. If a
  different stack is desired, the task boundaries below still hold, but T1
  scaffolding and T2 data models would need stack-specific adjustment.
  **This is the single most important assumption to confirm.**
- All monetary values are in **Nepali Rupees (NPR / Rs.)** per PRD constraints.
- Payment is **record-only**; real settlement happens on the physical terminal.
  No card-processing integration in v1.
- Credit is **unlimited and request-based** (no pre-grant, no limit); the only
  admin control is per-customer **suspension**.
- Customers cannot place orders in v1 — staff handle all ordering.
- Redemption happens **only at the counter by staff**, never customer-initiated.
- Points accrue on **paid amounts** at the configured rate — immediately for
  cash/card orders, at settlement for credit orders.
- A completed order must be closed by **either a recorded payment or a tab
  charge**; an order cannot be left unclosed (FR-5 assumption).
- Per-staff metrics attribute an order to the **staff member who closed it**.
- Staff can register a customer at the counter if one does not exist.

---

## 1. Task List (19 tasks)

Tasks are sequenced in dependency-honoring order. Task IDs are assigned in a
recommended build order; no ticket numbers are implied yet.

### T1 — Set up project scaffolding

- **Description:** Bootstrap the application skeleton for the Aafnai Coffee web
  app (Rails + PostgreSQL, per assumption). Establish the project structure,
  dev database, test framework, CI pipeline, linting, environment config, and a
  README with run instructions. This is the foundation every other task builds
  on.
- **Acceptance criteria:**
  - [ ] App boots locally with a configured PostgreSQL database.
  - [ ] Test framework (RSpec/system tests) runs green with a trivial smoke test.
  - [ ] Lint/static-analysis tooling runs clean.
  - [ ] CI pipeline runs the test suite on each push (with a green run).
  - [ ] README documents local setup, test, and run commands.
- **Dependencies:** None — first task.
- **Technical considerations:** Stack assumption above must be confirmed first.
  Keep dependencies minimal; no domain models yet.
- **Testing requirements:** CI passes; a single smoke/system test boots the app
  and loads the home page.

### T2 — Design & implement core data models

- **Description:** Create the full domain schema and database migrations:
  users (with `admin`/`staff`/`customer` role), menu items, categories,
  ingredients, recipes (item → ingredients+qty), stock levels, orders, order
  items, payments, credit/tab accounts, tab payments, points ledger, and the
  audit/attribution fields needed for FR-12 (every user-generated change
  attributed to an acting user).
- **Acceptance criteria:**
  - [ ] All core tables created via migrations with appropriate indexes/constraints.
  - [ ] Model associations and validations in place for the domain.
  - [ ] Every mutating record carries attribution to the acting user (FR-12).
  - [ ] Schema reviewable in a single PR (migrations + models + factories).
  - [ ] All unit model tests pass.
- **Dependencies:** T1.
- **Technical considerations:** Establish the attribution/audit pattern here so
  order, payment, stock, points, and credit tasks reuse it. Use seed data for
  development. Decisions on enum vs table for roles/status/payment-type should
  be made here.
- **Testing requirements:** Model specs for associations, presence/validity
  rules, and attribution; uniqueness/constraint coverage.

### T3 — Implement authentication & role-based authorization

- **Description:** Implement login (sessions) for admin/staff (email+password)
  and authentication primitives shared with customer login. Enforce role-gated
  access throughout the app (FR-1).
- **Acceptance criteria:**
  - [ ] Admin and staff can log in with email+password.
  - [ ] Session handling is secure (password hashing, CSRF, no secrets logged).
  - [ ] Role-based authorization guards protect admin-only vs staff-only routes.
  - [ ] Unauthenticated users are redirected to login; blocked roles get a 403.
  - [ ] Auth + authorization specs pass.
- **Dependencies:** T2.
- **Technical considerations:** Use a standard Rails auth approach (e.g.,
  `has_secure_password` or a small auth library). Customer phone+password login
  is handled in T7; keep the primitive reusable. Confirmed in FR-1.
- **Testing requirements:** Login success/failure, session expiry, and
  authorization tests for each role and unauthorized access.

### T4 — Implement staff account management (admin)

- **Description:** Admin UI to create staff accounts, assign exactly one role
  (`admin` or `staff`), and deactivate accounts (FR-2).
- **Acceptance criteria:**
  - [ ] Admin can create a staff account with email+password and one role.
  - [ ] Admin can deactivate (rather than delete) a staff account.
  - [ ] Only admin access; staff cannot manage staff accounts.
  - [ ] Deactivated staff cannot log in.
  - [ ] Specs cover create/deactivate and permission enforcement.
- **Dependencies:** T3.
- **Technical considerations:** Adopt the audit pattern from T2 for who created
  the account. Soft-deactivate to preserve historical attribution.
- **Testing requirements:** CRUD + deactivation + authorization specs.

### T5 — Implement admin menu management

- **Description:** Admin CRUD for menu items: name, price (NPR), category,
  availability, recipe association, and redeemable-with-points flag (FR-3).
- **Acceptance criteria:**
  - [ ] Admin can create/edit/deactivate menu items with all fields.
  - [ ] Menu item price is validated in NPR; category is manageable.
  - [ ] Availability flag controls whether the item is orderable (FR-4).
  - [ ] Redeemable-with-points flag exposed (consumed by T8).
  - [ ] Only admin access; specs pass.
- **Dependencies:** T3, T2.
- **Technical considerations:** Menu item is a prerequisite for recipes (T6)
  and rewards config (T8). Deactivate, never hard-delete running-of-record data.
- **Testing requirements:** Menu CRUD, validation, availability, authorization specs.

### T6 — Implement inventory management (ingredients, recipes, stock)

- **Description:** Ingredients with name, unit, low-stock threshold; recipes
  mapping each menu item to required ingredients+quantities; stock levels per
  ingredient; manual restock/purchase and stock correction; low-stock alerts
  when stock ≤ threshold (FR-10).
- **Acceptance criteria:**
  - [ ] Admin can add ingredients with unit and low-stock threshold.
  - [ ] Admin can define/edit recipes linking a menu item to ingredients+qty.
  - [ ] Staff/admin can record restock/purchase and stock corrections.
  - [ ] Low-stock state is flagged/alerted when stock ≤ threshold.
  - [ ] Stock decrement on sale is implemented and unit-tested (full integration
        in T12).
  - [ ] All specs pass.
- **Dependencies:** T3, T5.
- **Technical considerations:** Decide a single stock unit per ingredient
  (purchase-unit ↔ recipe-unit conversion is deferred to v1.1 per PRD). Leverage
  the attribution pattern for manual adjustments.
- **Testing requirements:** Ingredient/recipe CRUD, stock adjust/correct, and
  low-stock threshold specs; a unit test that a sale decrements stock by the
  recipe quantities.

### T7 — Implement customer registration & login

- **Description:** Customer can register with **both email and phone**, and log
  in via **email+password OR phone+password** (FR-1, FR-7). Staff may register a
  customer at the counter (PRD §12 assumption).
- **Acceptance criteria:**
  - [ ] Registration captures email and phone (both required) plus password.
  - [ ] Login works via email+password or phone+password.
  - [ ] Role is `customer` on registration.
  - [ ] Staff can create a customer account from the counter when none exists.
  - [ ] Customer auth specs pass (duplicate handling, invalid credentials).
- **Dependencies:** T3.
- **Technical considerations:** Reuse auth primitives from T3; ensure phone is
  unique and validated. Distinguish customer auth entry points from staff/admin.
- **Testing requirements:** Registration, dual login paths, uniqueness, and
  counter-creation specs.

### T8 — Implement rewards configuration (admin)

- **Description:** Admin-configurable points **earning rate** (points per Rs.
  spent) and the set of menu items **redeemable with points** (FR-8).
- **Acceptance criteria:**
  - [ ] Admin can set the points-per-Rs earning rate.
  - [ ] Admin can mark which menu items are redeemable with points (wired to the
        menu redeemable flag from T5).
  - [ ] Config is stored and retrievable for the rewards engine (T9).
  - [ ] Admin-only; specs pass.
- **Dependencies:** T5, T3.
- **Technical considerations:** Keep rate config simple (single global rate for
  v1). Redeemable set derived from menu item flags.
- **Testing requirements:** Rate configuration persistence + redeemable flags
  specs.

### T9 — Implement rewards engine & points ledger

- **Description:** Points accrual at the configured rate on paid amounts
  (immediately for cash/card, at settlement for credit — wired in T12), points
  redemption at the counter, and a points history. A redemption must **never**
  drive the balance negative (FR-6, FR-8).
- **Acceptance criteria:**
  - [ ] Points accrue at the configured rate for a given paid amount.
  - [ ] Staff can redeem points toward an order (only redeemable items).
  - [ ] Redemption cannot make a points balance negative.
  - [ ] Points earned/used history is recorded and queryable (for dashboard T13).
  - [ ] Engine specs pass (accrual, redemption, negative-balance guard).
- **Dependencies:** T8, T2.
- **Technical considerations:** Implement as a service operating on the points
  ledger from T2; enforce the never-negative rule at the ledger level.
- **Testing requirements:** Unit specs for accrual rate math, redemption
  validation, and the negative-balance guard; ledger entries recorded.

### T10 — Implement credit/tab system

- **Description:** Unlimited, request-based credit. Staff charge an order to a
  customer's tab ("put it on credit"), record tab payments received, track the
  per-customer balance, and admin can **suspend credit** for a customer (FR-9).
- **Acceptance criteria:**
  - [ ] Staff can charge an order to a customer's tab (customer account required).
  - [ ] Staff can record tab payments (amount + type) against a customer.
  - [ ] Per-customer tab balance is tracked correctly (charges − payments).
  - [ ] Admin can suspend/resume credit for a specific customer; suspended
        customers cannot be charged to tab.
  - [ ] Tab charges/payments are attributed to the acting user (FR-12).
  - [ ] Specs pass (charge, payment, balance, suspension, attribution).
- **Dependencies:** T7, T2, T3.
- **Technical considerations:** Order-to-tab charging is invoked from T12; this
  task delivers the service + admin/staff UI. Defer settlement-driven points
  accrual to T12.
- **Testing requirements:** Charge/payment/balance math, suspension gating, and
  attribution specs.

### T11 — Implement order composition at the counter

- **Description:** Staff compose an order from currently available menu items
  with quantities; each line item shows price and allowed point redemptions;
  optional customer association (FR-4, FR-5).
- **Acceptance criteria:**
  - [ ] Staff can start an order and add menu items with quantities.
  - [ ] Only **available** menu items are orderable.
  - [ ] Line items display price and, where applicable, points redemption.
  - [ ] Staff can attach a customer (or register one via T7).
  - [ ] Draft order can be reviewed before completion; completion is T12.
  - [ ] Composition specs pass.
- **Dependencies:** T3, T5.
- **Technical considerations:** Composition builds an in-progress order object;
  the transactional close (stock/points/credit side effects) is T12. Keep the
  counter UI minimal per the adoption-risk mitigation in the PRD.
- **Testing requirements:** Order draft assembly, availability gating, quantity
  handling, and customer attachment specs.

### T12 — Implement order completion (payment, tab close, stock, points)

- **Description:** Close a composed order by either a **recorded payment**
  (type: cash/card/other) or a **charge to the customer's tab** (if credit
  available); on close, decrement inventory per the recipe, accrue points
  (immediately for paid, at settlement for credit), and attribute to the closing
  staff member (FR-5, FR-6, FR-8, FR-9, FR-12).
- **Acceptance criteria:**
  - [ ] Order must close via recorded payment (cash/card/other) or tab charge.
  - [ ] Inventory decrements per the item's recipe on close.
  - [ ] Points accrue at the configured rate (paid orders immediately; credit
        orders only on settlement).
  - [ ] Tab charge routes through T10; suspended customers blocked.
  - [ ] Revenue is attributed to the staff member who closed the order (FR-11).
  - [ ] End-to-end and service specs pass (atomic closure, side effects).
- **Dependencies:** T11, T6, T9, T10.
- **Technical considerations:** Close must be **transactional/atomic** — either
  everything commits (order + payment/tab + stock decrement + points) or
  nothing. This is the highest-risk transactional task.
- **Testing requirements:** Integration specs for full happy path (cash, card,
  tab) and failure paths (insufficient stock, suspended credit, redemption
  overshoot); verify stock and ledger side effects.

### T13 — Implement customer self-service dashboard

- **Description:** Logged-in customer sees live reward-points balance, tab
  balance, and points earned/used history (FR-7).
- **Acceptance criteria:**
  - [ ] Customer dashboard shows current points balance from the ledger.
  - [ ] Customer dashboard shows current tab balance.
  - [ ] Points earned/used history is displayed.
  - [ ] Only the owning customer sees their data; no cross-account leakage.
  - [ ] Dashboard specs pass.
- **Dependencies:** T7, T9, T10.
- **Technical considerations:** Read-only views over the points ledger (T9) and
  credit balances (T10). Enforce ownership scoping.
- **Testing requirements:** Data display, ownership isolation, and empty-state
  specs.

### T14 — Implement admin reports

- **Description:** **Sales report** filterable by date range with totals by
  payment type, by menu item/category, and per-staff orders-handled count and
  revenue (attributed to the closer); **Credit report** showing per-customer
  open balances plus charges and payments within a range (FR-11).
- **Acceptance criteria:**
  - [ ] Sales report returns totals by payment type for any date range.
  - [ ] Sales report returns totals by menu item/category.
  - [ ] Sales report returns per-staff orders-handled count and revenue.
  - [ ] Credit report returns per-customer open balance + charges/payments in
        range.
  - [ ] Reports are admin-only.
  - [ ] Report specs pass with seeded/representative data.
- **Dependencies:** T12, T10.
- **Technical considerations:** CSV export is deferred to v1.1 (PRD). Query
  against the closed-order/payment and credit/`tab payment` data. Reuse the
  closing-staff attribution from T12.
- **Testing requirements:** Report query specs (date filtering, grouping,
  per-staff attribution) using fixture data; authorization spec.

### T15 — Canonicalize customer phone numbers

- **Description:** Phone numbers can be entered with varying formatting
  (+9779800000001 vs +977-980-000-001 vs +977 980 000 001). `normalize_phone`
  currently only strips whitespace, so formatting variants bypass the phone
  uniqueness constraint and break `find_by_identifier` phone login when the
  stored format differs from the login input. Canonicalize phone numbers before
  validation, uniqueness check, and lookup; consider a data migration for
  existing rows.
- **Acceptance criteria:**
  - [ ] Phone numbers are canonicalized (digits-only or E.164) before validation
        and uniqueness enforcement.
  - [ ] Duplicate phone numbers with different formatting are rejected.
  - [ ] Phone-based login (`find_by_identifier`) works regardless of how the
        phone was originally stored.
  - [ ] A data migration normalizes existing rows (if any exist).
  - [ ] Specs cover uniqueness across formats and login across formats.
- **Dependencies:** T7.
- **Technical considerations:** Choose a canonical format (E.164 without
  spaces/dashes) and apply it consistently via a `before_validation` callback
  or similar. Ensure the migration uses the same normalization logic.
- **Testing requirements:** Uniqueness specs across formatting variants; login
  specs across formatting variants; data migration spec if applicable.

### T16 — Enforce minimum password length

- **Description:** No minimum password length is enforced — `has_secure_password`
  only validates presence, so a 1-character password is accepted at registration
  and counter-side customer creation. Add a minimum length validation to the
  User model.
- **Acceptance criteria:**
  - [ ] `validates :password, length: { minimum: 8 }` (or similar) is enforced.
  - [ ] Registration and counter-side customer creation reject short passwords.
  - [ ] Model and request specs cover the minimum length constraint.
- **Dependencies:** T7.
- **Technical considerations:** The validation belongs on the User model so it
  applies to all registration paths (self-service, admin staff creation, and
  counter-side customer creation).
- **Testing requirements:** Model spec for password length validation; request
  specs for registration paths rejecting short passwords.

### T17 — Establish design system foundation

- **Description:** The app has no styling at all —
  `app/assets/stylesheets/application.css` is an empty manifest and all views
  are unstyled plain HTML. Build the design-system foundation per DESIGN.md (the
  project's UI source of truth): CSS custom properties for color roles
  (background, surface, primary/secondary/muted text, borders, primary action,
  success, warning, error), radius/shadow tokens, restrained type scale, base
  components (buttons with primary/secondary/tertiary/destructive hierarchy,
  forms with visible labels + validation states, tables, flash messages), and an
  application layout shell with role-based navigation replacing the inline links
  in `pages/home`. No generic-SaaS patterns per DESIGN.md §1.
- **Acceptance criteria:**
  - [ ] CSS custom properties for color roles, radius, and shadow tokens defined
        in the stylesheet.
  - [ ] Restrained type scale established.
  - [ ] Base component styles: buttons (primary/secondary/tertiary/destructive),
        forms (visible labels, validation states), tables, flash messages.
  - [ ] Application layout shell with role-based navigation.
  - [ ] Existing views remain functional after layout change.
  - [ ] Specs (visual/system tests if available) pass.
- **Dependencies:** None — baseline on `main`.
- **Technical considerations:** Follow DESIGN.md strictly. Do not introduce
  generic-SaaS styling patterns. Keep the foundation minimal — T18 and T19
  apply it to specific views.
- **Testing requirements:** System tests verifying layout renders and navigation
  links appear for each role; no visual regressions on existing pages.

### T18 — Apply design system to auth & home screens

- **Description:** Apply the T17 design system to the authentication and home
  screens: `sessions/new`, `customer_sessions/new`, `registrations/new`,
  `staff/customers/new`, and `pages/home`.
- **Acceptance criteria:**
  - [ ] All five views use design-system component styles.
  - [ ] Forms follow the design-system form pattern (visible labels, validation
        states).
  - [ ] No unstyled elements remain on these pages.
  - [ ] Existing functionality is preserved (specs pass).
- **Dependencies:** T17.
- **Technical considerations:** Apply the component classes defined in T17. Do
  not restructure view logic — only apply styling.
- **Testing requirements:** System tests for each view confirming styled elements
  render and functionality is preserved.

### T19 — Apply design system to admin screens

- **Description:** Apply the T17 design system to the admin screens:
  `admin/users`, `admin/menu_items`, `admin/ingredients`,
  `admin/recipe_items`, `admin/stock_entries` (index tables, new/edit forms,
  form partials). Keep tables as tables (DESIGN.md §12) — do not convert to
  cards.
- **Acceptance criteria:**
  - [ ] All five admin index views use design-system table styling.
  - [ ] New/edit forms and form partials use design-system form styling.
  - [ ] Tables remain as tables (no card conversion per DESIGN.md §12).
  - [ ] No unstyled elements remain on these pages.
  - [ ] Existing functionality is preserved (specs pass).
- **Dependencies:** T17.
- **Technical considerations:** Apply the component classes defined in T17. Do
  not restructure view logic — only apply styling. Preserve table structure.
- **Testing requirements:** System tests for each admin view confirming styled
  elements render and functionality is preserved.

---

## 2. Dependency spine (build order)

```
T1 Set up scaffolding
 └─ T2 Core data models
     ├─ T3 Auth & RBAC
     │   ├─ T4 Staff account management
     │   ├─ T5 Menu management
     │   └─ T7 Customer registration & login
     │       ├─ T15 Phone number canonicalization (follow-up)
     │       └─ T16 Minimum password length (follow-up)
     ├─ T5 Menu management ─┐
     ├─ T3/T5 → T6 Inventory (ingredients, recipes, stock)
     ├─ T3/T5 → T8 Rewards configuration ─→ T9 Rewards engine & ledger
     ├─ T3/T5 → T11 Order composition
     │              └─ T11 + T6 + T9 + T10 → T12 Order completion
     └─ T7 → T10 Credit/tab system
T7 + T9 + T10 → T13 Customer dashboard
T12 + T10 → T14 Admin reports
T17 Design system foundation (baseline main)
 ├─ T18 Apply design system to auth & home screens
 └─ T19 Apply design system to admin screens
```

**Recommended implementation order (sequential):**
1. T1 → 2. T2 → 3. T3 → 4. T4 → 5. T5 → 6. T6 → 7. T7 → 8. T8 → 9. T9 →
10. T10 → 11. T11 → 12. T12 → 13. T13 → 14. T14

**Follow-up additions (approved 2026-09-11):**

- T15 and T16 are independent follow-up fixes to T7; each can be worked at any
  time after T7, in any order.
- T17 → T18 → T19 is the UI/design-system order: T17 must precede T18 and T19;
  T18 and T19 are independent of each other once T17 is done.

## 3. First unblocked tasks

- **T1 — Set up project scaffolding** (no dependencies; unblocks the whole plan).
- **T17 — Establish design system foundation** (no dependencies; baseline on
  `main`; unblocks T18 and T19).

## 4. Completeness pass

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

All 12 functional requirements are covered. No requirements are deferred except
those already marked "Should Have / Nice to Have" in the PRD (v1.1+).

## 5. Items intentionally deferred (per PRD "Should Have / Nice to Have")

- Customer order history, in-app redemption requests, split payments,
  cancel/refund reversal, manual point/credit adjustments + audit, CSV export,
  purchase-unit ↔ recipe-unit conversion, suppliers/POS, "86'd" toggling,
  email/SMS alerts, top-items/customers mini-reports.

## 6. Notes / open questions for the manager

1. **Confirm the tech stack** (assumed Rails + PostgreSQL per workspace
   convention). If different, T1/T2 adjust.
2. Confirm the database/status conventions are acceptable (single global points
   rate; redundant menu `redeemable` flag drives rewards config).
3. Confirm task granularity — 14 tasks (plus 5 follow-up additions approved on
   2026-09-11: T15–T19), each one branch + one PR.
