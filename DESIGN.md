# Design Guidelines

## Purpose

This document defines the visual design rules for this project.

The UI should feel intentionally designed for this specific product, not like a generic AI-generated SaaS application or UI template.

The design should prioritize:

- Clarity
- Usability
- Strong visual hierarchy
- Consistency
- Restraint
- Product-specific decisions

When in doubt, prefer simplicity.

---

## 1. Avoid Generic AI UI

Do not automatically use common AI-generated design patterns.

Avoid:

- Purple/blue gradients
- Gradient text
- Glassmorphism
- Excessive rounded cards
- Excessive shadows
- Floating cards everywhere
- Giant headings
- Excessive whitespace without purpose
- Excessive pills and badges
- Excessive icons
- Emoji as decoration
- Decorative illustrations without purpose
- Generic dashboard layouts
- Three-column card grids by default
- Cards inside cards
- Every section inside a card
- Excessive use of `border-radius`
- Excessive use of bold text
- Excessive centered content
- Random decorative shapes
- Unnecessary animations
- "Modern SaaS" styling when it does not fit the product

Do not use a design pattern simply because it is popular in AI-generated interfaces.

---

## 2. Design for This Product

The UI should reflect the actual product and its users.

Do not assume every application should look like a SaaS dashboard.

Before designing a screen, consider:

- What is the user trying to accomplish?
- What information matters most?
- What action matters most?
- How frequently will this screen be used?
- How much information does the user need at once?

The design should emerge from the workflow rather than from a generic template.

---

## 3. Layout

Prefer simple layouts with clear hierarchy.

A screen should make it obvious:

1. Where the user is.
2. What the screen is about.
3. What they can do.
4. What information is most important.
5. What information is secondary.

Use spacing to establish relationships between elements.

Do not add containers simply because an area feels empty.

Whitespace is acceptable when it improves hierarchy.

---

## 4. Cards

Cards are not the default way to structure content.

Use a card when:

- It represents a distinct object.
- The content needs visual containment.
- The object is independently actionable.
- Separation from surrounding content improves usability.

Prefer simple sections, spacing, and dividers when a card is unnecessary.

Avoid:

- Cards inside cards
- Cards around single pieces of text
- Cards around every form
- Cards around every statistic
- Cards around every section
- Turning every list item into a card

---

## 5. Typography

Typography should establish hierarchy without being excessive.

Use a restrained type scale.

Prioritize:

- Clear page titles
- Clear section headings
- Readable body text
- Subtle supporting text

Avoid:

- Oversized headings
- Too many font sizes
- Bold text everywhere
- Excessive uppercase labels
- Excessive letter spacing

Typography should improve scanning and comprehension.

---

## 6. Color

Use a restrained and consistent color palette.

Define clear roles for:

- Background
- Surface
- Primary text
- Secondary text
- Muted text
- Borders
- Primary action
- Success
- Warning
- Error

Use color to communicate meaning and hierarchy.

Do not introduce colors simply for decoration.

Avoid gradients unless they are explicitly part of the product's visual identity.

---

## 7. Borders and Shadows

Use borders and shadows sparingly.

Borders should provide structure.

Shadows should communicate elevation.

Good uses for shadows include:

- Dialogs
- Dropdowns
- Popovers
- Floating elements

Do not give every card a noticeable shadow.

Avoid combining heavy shadows, thick borders, and large corner radii on every component.

---

## 8. Border Radius

Use a consistent radius system.

Do not make every element heavily rounded.

Reserve pill-shaped elements primarily for things such as:

- Tags
- Status indicators
- Filters
- Compact controls

Not every button, card, input, and container needs to look like a pill.

---

## 9. Icons

Icons should communicate meaning.

Use them when they:

- Improve recognition
- Clarify an action
- Support navigation
- Represent a familiar concept

Do not add icons merely to make a UI element look more interesting.

Avoid putting an icon beside every label or button.

Maintain consistent icon sizing.

---

## 10. Buttons

Buttons should have clear hierarchy.

Establish appropriate levels such as:

- Primary
- Secondary
- Tertiary
- Destructive

A screen should generally have one visually dominant primary action.

Prefer concise labels:

- Create project
- Add task
- Save changes
- Delete project

Avoid decorative button labels such as:

- ✨ Create Something Amazing
- 🚀 Start Your Journey

unless the product's actual brand language requires them.

---

## 11. Forms

Forms should prioritize clarity and usability.

Use:

- Visible labels
- Logical grouping
- Appropriate input types
- Clear validation
- Useful descriptions where necessary

Do not make forms visually complicated for the sake of appearance.

Do not place every field inside its own card.

---

## 12. Tables and Lists

Use the appropriate representation for the information.

### Tables

Use tables when users need to compare structured information.

Prioritize:

- Alignment
- Scannability
- Consistent columns
- Appropriate density

### Lists

Use lists when information is naturally sequential or repetitive.

Do not convert structured information into cards simply because cards look more attractive.

---

## 13. Dashboards

Do not add dashboard widgets simply to fill space.

Avoid automatically creating layouts such as:

```text
Welcome back!

[Metric] [Metric] [Metric] [Metric]

        [Large Chart]

[Recent Activity] [Quick Actions]
