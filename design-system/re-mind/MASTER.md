# Design System Master File

> **LOGIC:** When building a specific page, first check `design-system/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** Re:Mind
**Generated:** 2026-08-21 22:21:33
**Category:** Productivity Tool
**Design Dials:** Variance 3/10 (Centered / Minimal) | Motion 4/10 (Standard) | Density 5/10 (Standard)

---

## Global Rules

### Color Palette

| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#0D9488` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#14B8A6` | `--color-secondary` |
| Accent/CTA | `#EA580C` | `--color-accent` |
| Background | `#F0FDFA` | `--color-background` |
| Foreground | `#134E4A` | `--color-foreground` |
| Muted | `#E8F1F4` | `--color-muted` |
| Border | `#99F6E4` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#0D9488` | `--color-ring` |

**Color Notes:** Teal focus + action orange [Accent adjusted from #F97316 for WCAG 3:1]

### Typography

- **Heading Font:** Plus Jakarta Sans
- **Body Font:** Plus Jakarta Sans (single family)
- **Mood:** friendly, modern, clean, professional — proven for productivity tools
- **Weights:** 300 / 400 / 500 / 600 / 700
- **Google Fonts:** [Plus Jakarta Sans](https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap)

> Override of generated Lora/Raleway: serif wellness pairing did not fit a daily-use utility app. Single sans family keeps the list UI quiet and legible.

### Spacing Variables

*Density: 5/10 — Standard*

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | `4px` / `0.25rem` | Tight gaps |
| `--space-sm` | `8px` / `0.5rem` | Icon gaps, inline spacing |
| `--space-md` | `16px` / `1rem` | Standard padding |
| `--space-lg` | `24px` / `1.5rem` | Section padding |
| `--space-xl` | `32px` / `2rem` | Large gaps |
| `--space-2xl` | `48px` / `3rem` | Section margins |
| `--space-3xl` | `64px` / `4rem` | Hero padding |

### Shadow Depths

| Level | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle lift |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, buttons |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, dropdowns |
| `--shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Hero images, featured cards |

---

## Component Specs

### Buttons

```css
/* Primary Button */
.btn-primary {
  background: #EA580C;
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}

.btn-primary:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

/* Secondary Button */
.btn-secondary {
  background: transparent;
  color: #0D9488;
  border: 2px solid #0D9488;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}
```

### Cards

```css
.card {
  background: #F0FDFA;
  border-radius: 12px;
  padding: 24px;
  box-shadow: var(--shadow-md);
  transition: all 200ms ease;
  cursor: pointer;
}

.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}
```

### Inputs

```css
.input {
  padding: 12px 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 200ms ease;
}

.input:focus {
  border-color: #0D9488;
  outline: none;
  box-shadow: 0 0 0 3px #0D948820;
}
```

### Modals

```css
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: var(--shadow-xl);
  max-width: 500px;
  width: 90%;
}
```

---

## Style Guidelines

**Style:** Exaggerated Minimalism

**Keywords:** Bold minimalism, oversized typography, high contrast, negative space, loud minimal, statement design

**Best For:** Fashion, architecture, portfolios, agency landing pages, luxury brands, editorial

**Key Effects:** font-size: clamp(3rem 10vw 12rem), font-weight: 900, letter-spacing: -0.05em, massive whitespace

### Page Pattern

**Pattern Name:** Minimal Single Column

- **Conversion Strategy:** Single CTA focus. Large typography. Lots of whitespace. No nav clutter. Mobile-first.
- **CTA Placement:** Center, large CTA button
- **Section Order:** 1. Hero headline, 2. Short description, 3. Benefit bullets (3 max), 4. CTA, 5. Footer

---

## Motion

**Scroll Reveal** (Standard) — Trigger: scroll (viewport enter) | Duration: 400-600ms | Easing: `power2.out`

```js
gsap.from(el.children, { opacity: 0, y: 24, duration: 0.5, stagger: 0.08, ease: 'power2.out', scrollTrigger: { trigger: el, start: 'top 85%' } });
```

**Framework notes:** In React use useGSAP(() => {...}, { scope: containerRef }) from @gsap/react to auto-cleanup on unmount

- ✅ Scope the ScrollTrigger to the section container so it doesn't re-scan the whole page
- ❌ Don't stagger more than ~8 children; beyond that the last items feel laggy
- ⚡ Set scroller/markers: false in production; markers is dev-only

---

## Anti-Patterns (Do NOT Use)

- ❌ Complex onboarding
- ❌ Slow performance

### Additional Forbidden Patterns

- ❌ **Emojis as icons** — Use SVG icons (Heroicons, Lucide, Simple Icons)
- ❌ **Missing cursor:pointer** — All clickable elements must have cursor:pointer
- ❌ **Layout-shifting hovers** — Avoid scale transforms that shift layout
- ❌ **Low contrast text** — Maintain 4.5:1 minimum contrast ratio
- ❌ **Instant state changes** — Always use transitions (150-300ms)
- ❌ **Invisible focus states** — Focus states must be visible for a11y

---

## Pre-Delivery Checklist

Before delivering any UI code, verify:

- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons from consistent icon set (Heroicons/Lucide)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px
- [ ] No content hidden behind fixed navbars
- [ ] No horizontal scroll on mobile

---

## App Adaptations (Flutter)

Decisions on what is adopted, adapted, or rejected from the generated system — Re:Mind is a Flutter app, not a web landing page.

### Adopted

- **Color palette as-is**: teal primary #0D9488 (calm focus) + orange accent #EA580C (action/nudge, WCAG-adjusted) + destructive #DC2626. Map to Flutter ColorScheme.fromSeed(seedColor: #0D9488) with primary pinned to the exact token and accent override; provide full darkTheme. Scaffold backgrounds: light #F0FDFA, dark #0C1615 (calm near-black teal — reviewed adaptation).
- **Minimalism direction**: high contrast, generous whitespace, quiet chrome.
- **Anti-patterns**: no complex onboarding (matches ADR-0008/decision #9), no slow performance.

### Adapted

- **"Exaggerated Minimalism" effects toned down for app UI**: bold display type (w700, tight tracking) reserved for counts and section headers ("3 hanging"), never hero-scale text inside list rows.
- **Motion**: GSAP presets do not apply. Flutter equivalent: implicit animations (AnimatedContainer, AnimatedSwitcher) and hero transitions, 150-300ms, Curves.easeOutCubic; respect MediaQuery.disableAnimations (reduced motion).
- **Landing-page pattern sections** (hero/benefit bullets/footer) are ignored; the single-column minimal pattern maps to the home screen: one prioritized list + prominent capture affordance.

### Flutter implementation notes (from stack guidelines)

- MaterialApp(theme: light, darkTheme: dark) — follow system theme.
- List items need keys: ListTile(key: ValueKey(loop.id)) to preserve state.
- Typed route arguments only (no dynamic maps).
- Touch targets >= 44-48dp; icon set: Material Symbols (outlined), never emoji.

### Pre-delivery checklist additions (mobile)

Replace web responsive breakpoints with: safe-area ( notch/gesture bar) respected, 44dp+ touch targets, dark mode contrast checked, notification action buttons match digest copy tone.
