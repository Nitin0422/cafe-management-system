# Product Requirements Document

**Project:** Aafnai Coffee

**Version:** 1.0 (approved)

**Status:** Approved by the human manager on 2026-09-05

## 1. Product Summary

**Aafnai Coffee** is a web-based management system for a single cafe branch. Staff take orders and
record payments at the counter. Customers have their own accounts through
which they can view reward points and credit-tab balances. Admin
(owner/manager) manages the menu, ingredient-based inventory, staff, credit
grants, and generates sales and credit reports. Payment is **recorded, not
processed** — actual card/cash handling stays with the physical terminal at
the counter.

## 2. Problem Statement

_Assumption: the cafe currently runs on a mix of manual/spreadsheet processes —
to be confirmed._

As the cafe serves 100–200 customers a day with ~10 staff, operational
information is scattered: orders, stock levels, customer tabs, reward points,
and staff records each live in different places. This causes:

- No visibility into what is actually selling, by item or payment type.
- Loose inventory tracking, leading to shortages or waste, with no connection
  between what is sold and what is left.
- Customer tabs and rewards managed from memory or paper, risking disputes and
  lost trust with regulars.
- No reliable reporting for decision-making.

## 3. Target Users

| User | Role | Context |
|---|---|---|
| **Admin** (owner/manager) | Full oversight | Manages menu, inventory, staff, credit grants; generates reports |
| **Staff** (~10) | Daily counter operations | Takes orders, records payments, charges tabs, redeems points |
| **Customer** (100–200/day) | Account holder | Logs in to view reward points and tab balance |

No additional personas needed for v1.

## 4. Product Goal

Centralize the cafe's daily operations — ordering, payments, inventory, credit,
and rewards — in one system staff can use quickly at the counter, customers can
check themselves, and admin can trust for reports.

## 5. Success Criteria

Proposed targets (subject to adjustment):

- Staff can complete an order including payment in **under 60 seconds** with
  all required data.
- Inventory **decrements automatically** with each sale, using
  recipe-to-ingredient mappings.
- Low-stock items surface to admin **as soon as stock crosses the threshold**.
- Sales and credit reports are producible **for any date range without manual
  compilation**.
- Customers can log in with **either email or phone** and see live reward
  points and tab balance.
- Admin can see **per-staff metrics (orders handled and revenue)** for any
  date range.

## 6. MVP Scope

### Must Have

**Authentication & roles**

- Admin, staff, and customer logins; role-based permissions enforced.
- Customer login via **email or phone**, each combined with a password.
- Staff accounts managed by admin.

**Counter operations (staff)**

- Create an order: add menu items, quantities, optional customer association,
  optional out-of-stock items.
- Apply reward-point redemption to an order (items paid by points).
- Complete an order with either a **recorded payment** (type: cash / card /
  other) or a **charge to the customer's tab** (if that customer has credit).
- Every completed order automatically decrements inventory. Points accrue at
  payment (cash/card) or at tab settlement (credit).

**Customer accounts**

- Registration and login (email or phone).
- Dashboard showing reward points balance, tab balance, and points
  earned/used history.

**Rewards**

- Admin-configurable earning rate (points per Rs. spent).
- Admin-configurable set of menu items redeemable with points.
- Redemption only performed by staff at the counter.

**Credit / tab system**

- Unlimited, request-based credit: any customer with an account can ask to
  "put it on credit" at the counter, and staff may charge the order to their
  tab — no pre-grant and no limit.
- Staff can charge an order to a customer's tab and record tab payments
  received.
- Admin sees credit status via the credit report: per-customer outstanding
  balance, payment/settlement history, and charge history.
- Admin can suspend credit for a specific customer when needed.

**Inventory (recipe-based)**

- Ingredients with names and units.
- Recipes: mapping each menu item to its required ingredients and quantities.
- Stock levels per ingredient; automatic decrement on sale.
- Manual adjustments: restock/purchase and stock correction.
- Low-stock thresholds per ingredient with admin alerts.

**Menu management (admin)**

- Menu items: name, price, category, availability, recipe association,
  redeemable-with-points flag.

**Reports (admin)**

- **Sales report**: date-range filter; totals by payment type; totals by menu
  item/category; **per-staff orders-handled count and revenue**.
- **Credit report**: open balances and settlements within a period.

**Staff management (admin)**

- Add staff, assign role (admin/staff), deactivate accounts.

### Should Have (deferred from v1, planned next)

- Customer order history visible in their app.
- Customer can _request_ a redemption in-app (staff confirms at counter).
- Split payment across multiple types in a single order.
- Cancel/refund flow that reverses inventory and points.
- Admin manual point/credit adjustments with an audit trail.
- Export reports to CSV.
- Ingredient purchase-unit ↔ recipe-unit conversion (e.g., buy beans in kg,
  recipe uses grams).

### Nice to Have

- Supplier and purchase-order tracking.
- "86'd" item toggling during service.
- Email/SMS alerts for low stock.
- Top-items / top-customers mini-reports.

## 7. Out of Scope (v1)

- Customer self-ordering, pre-order, delivery, kiosks.
- In-system payment processing or card-terminal integration.
- Multi-branch support.
- Native mobile apps.
- Loyalty beyond points-per-spend (no tiers, no visit-based rewards).
- Shift scheduling, time tracking, payroll.
- Integration with external accounting software.

## 8. Functional Requirements

- **FR-1** Users authenticate with credentials. Customers can log in with
  email+password **or** phone+password; staff/admin with email+password.
  Access is role-gated.
- **FR-2** Admin can create/deactivate staff accounts and assign exactly one
  role: `admin` or `staff`.
- **FR-3** Admin manages menu items (name, price, category, availability,
  recipe, redeemable-with-points flag).
- **FR-4** Staff can compose an order from currently available menu items with
  quantities; each line item displays price and allowed redemptions.
- **FR-5** On completion, an order must record either (a) payment received with
  a transfer type (cash/card/other), or (b) a charge to a customer's tab.
  _(Assumption: an order cannot be left unclosed; closing requires one of these
  paths.)_
- **FR-6** Every completed order decrements ingredient stock per its recipe.
  Reward points accrue on paid amounts at the configured rate — at payment for
  cash/card orders, and at tab settlement for credit orders.
- **FR-7** Customers can register with both email and phone, log in, and view
  live reward-points balance, tab balance, and their points history.
- **FR-8** Rewards: earning rate and redeemable items are admin-configured.
  Points redeem only at the counter through staff. A redemption never drives a
  points balance negative.
- **FR-9** Credit: unlimited and request-based. Staff may charge an order to
  a customer's tab when the customer asks ("put it on credit"); staff also
  record tab payments. Admin monitors credit status through the credit report
  and can suspend credit for a customer. Points on credit orders accrue only
  after settlement.
- **FR-10** Inventory: ingredients have a unit and a low-stock threshold;
  recipes define quantities; stock decreases on sale; staff can restock or
  correct stock; admin alerted when stock ≤ threshold.
- **FR-11** Sales report: any date range; revenue by payment type and by menu
  item/category; **per-staff orders-handled count and revenue, attributed to
  the staff member who closed the order**. Credit report: per-customer open
  balance plus charges and payments within a range.
- **FR-12** All user-generated changes (orders, payments, stock adjustments,
  points, credit) are attributed to the acting user.

## 9. Core User Flows

**Counter sale (happy path):** Staff logs in → composes order → (optional)
attaches customer → (optional) redeems points → confirms total → records
cash/card/other payment or charges to tab ("put it on credit") → order closed;
stock decremented; points awarded (immediately for paid orders, at settlement
for credit orders); customer balance updated if applicable.

**Tab settlement:** Customer settles a balance → staff records payment received
(amount + type) against the customer → tab balance and credit report update.

**Customer checkout of own account:** Customer registers (email+phone) or logs
in → views points balance, tab balance, and points history.

**Admin stock management:** Admin views ingredients (with current stock) → adds
ingredient or adjusts stock → sets thresholds → low-stock alerts resolve as
stock is restored.

**Admin reporting:** Admin opens sales report → picks date range → reads totals
by payment type, by item, and per staff member → exports (v1.1) → same flow for
the credit report.

## 10. Constraints

- Single branch; ~10 staff; 100–200 customers/day.
- Web application only — staff on counter tablet/PC browsers, customers on
  phone browsers.
- Payment is **record-only**; settlement still happens on a physical terminal
  or in cash. System state must match the till via staff discipline.
- All prices, rewards, and reports are denominated in Nepali Rupees (Rs., NPR).
- Customer PII (phone, email) is stored; handle per basic privacy expectations.

## 11. Risks

| Risk | Mitigation |
|---|---|
| Recorded payment mis-matches actual till cash | Confirmation steps at checkout; sales report by payment type enables daily reconciliation |
| Tabs going unpaid (default risk) | Unlimited request-based credit; staff discretion at the counter; credit report gives admin full visibility; admin can suspend credit for a customer |
| Ingredient stock drifting from reality | Manual corrections + periodic stocktake workflow; low-stock alerts |
| Points/credit disputes | Every action attributed to a user; history visible to both admin and customer |
| Per-staff metrics misused as a punishment tool | Business decision: use reports for coaching/visibility, not public comparison |
| Staff adoption friction | Minimal-field order flow; one screen per task |

## 12. Assumptions

- The cafe currently manages operations through manual/spreadsheet processes
  (see §2).
- Web app model as agreed: staff browsers + customer phone browsers.
- Staff handle all ordering; customers do not place orders in v1.
- Redemption happens only at the counter by staff.
- Admin configures points rate and redeemable items.
- Points accrue on paid amounts — at payment for cash/card orders, at
  settlement for credit orders.
- Customer login supports both email and phone.
- Credit is unlimited and request-based; staff discretion decides at the
  counter; admin monitors status and can suspend a customer's credit.
- Charge to credit requires a customer account; staff can register a customer
  at the counter if one does not exist.
- Per-staff metrics attribute an order to the staff member who closed it.