# ADR-002: Frontend — React 18 + TypeScript + Vite + shadcn/ui

> **Estado**: Accepted
> **Fecha**: 2026-06-19
> **Proyecto**: SICA Modernization
> **Scope**: frontend

---

## Contexto

El sistema legacy usa ASP.NET WebForms con UserControls (.ascx) y Master Pages.
La interfaz de usuario es monolítica, no responsive y difícil de mantener.
`demo/destino.md` especifica una SPA (React/Angular) como destino.

## Decisión

Adoptamos **React 18.x + TypeScript + Vite** como stack frontend, con:

1. **React 18** como framework (SPA Monolítica)
2. **TypeScript** como lenguaje
3. **Vite** como build tool
4. **shadcn/ui + Tailwind CSS v4** como sistema de componentes y estilos
5. **TanStack Query** para estado de servidor (API calls)
6. **Zustand** para estado de cliente (UI state)
7. **MSAL.js v3 (@azure/msal-react)** para autenticación Azure AD B2C

## Opciones Consideradas

| Opción | Pros | Contras | Decisión |
| ------ | ---- | ------- | -------- |
| React 18 | Ecosistema amplio, skill disponible, Azure Static Web Apps | — | ✅ Elegida |
| Angular 18/20 | Opinionated, TypeScript nativo | Mayor curva de aprendizaje, más verboso | ❌ |
| Vue 3 | Más simple que Angular | Menor ecosistema Azure, skill menos disponible | ❌ |
| Blazor WebAssembly | Full .NET stack | Performance inicial (WASM load), menor ecosistema UI | ❌ |
| Micro-frontends | Independencia de equipos | Over-engineering para el tamaño del proyecto | ❌ |
| Next.js (SSR) | SEO, performance | SICA es una app interna (no necesita SSR/SEO) | ❌ |
| Vite | Mejor DX que CRA/webpack, HMR rápido | — | ✅ |
| shadcn/ui | Componentes accesibles, personalizable, Tailwind-native | — | ✅ |

## Consecuencias

**Positivas**:
- React 18 + TypeScript + Vite es el stack más demandado del mercado (disponibilidad de talento)
- shadcn/ui da accesibilidad WCAG de base, reduciendo deuda técnica de UI
- TanStack Query gestiona el estado de caché de server state, simplificando el código
- MSAL.js v3 es la librería oficial de Microsoft para Azure AD B2C en SPA

**Negativas / Riesgos**:
- Migración de los 24 ficheros WebForms/UserControls requiere priorización cuidadosa
- El equipo debe aprender React si viene de WebForms
- TanStack Query tiene una curva de aprendizaje inicial

## Módulos WebForms a Migrar (Prioridad)

| UserControl / Page      | Feature React         | Prioridad |
| ----------------------- | --------------------- | --------- |
| `MonSeg.aspx`           | Dashboard monitoreo   | Alta      |
| `Acessos.ascx`          | Gestión de accesos    | Alta      |
| `Visitantes.ascx`       | Visitantes            | Alta      |

## Compliance

- ✅ Constitution Art. II §2.2: React 18.x, TypeScript
- ✅ Constitution Art. III §3.2: Monolith SPA
- ✅ Constitution Art. VII §7.3: Authorization Code + PKCE, MSAL.js v3
- ✅ Constitution Art. XIII: Vitest+RTL ≥80%, Playwright E2E, Stryker JS ≥70%
