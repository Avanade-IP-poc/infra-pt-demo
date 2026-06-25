# BOLT Framework — Scope Constitution: Frontend

> **Proyecto**: SICA Modernization — Migración VB.NET WebForms → React SPA
> **Scope**: `frontend`
> **Estado**: Ratificado — 2026-06-19
> **Fuente legacy**: `demo/from_old_src/SICAWeb/` (ASP.NET Web Forms + UserControls)
> **Destino**: `demo/destino.md` (SPA React, responsive, API Gateway)

---

## Article II §2.2-2.3: Frontend Framework & Mobile

### §2.2: Frontend Framework 🔴 CRITICAL

- [x] **React** — Version: [x] 18.x

**Justificación**: Seleccionado en sesión de inception (2026-06-19). Ecosistema maduro,
compatibilidad con Azure Static Web Apps, amplia disponibilidad de talento.

Build tool: [x] **Vite**
Language: [x] **TypeScript**
Component library: [x] **shadcn/ui + Tailwind CSS v4**

### §2.3: Mobile Application

- [x] **None** — Sin aplicación móvil en el alcance de la migración.

---

## Article III §3.2: Frontend Architecture Style 🔴 CRITICAL

- [x] **Monolith SPA** — Aplicación React única.

**Justificación**: El sistema legacy tiene ~24 ficheros WebForms y UserControls. Una SPA
monolítica es suficiente para el alcance de la migración. Micro-frontends añadiría
complejidad innecesaria.

State management: [x] **TanStack Query** (server state) + **Zustand** (client state)
Routing: [x] **React Router v6**

---

## Article VII §7.3-7.4: Identity & Access (Frontend)

### §7.3: Authentication Flows 🟡 IMPORTANT

| Escenario    | Flow                      | Habilitado |
| ------------ | ------------------------- | ---------- |
| SPA Frontend | Authorization Code + PKCE | [x] Yes    |
| Mobile App   | —                         | N/A        |

Librería: [x] **MSAL.js v3** (`@azure/msal-react`) — Azure AD B2C

### §7.4: Authorization Model

- [x] **RBAC** — Roles desde JWT claims de Azure AD B2C.

---

## Article XIII: Testing Standards (Frontend)

| Métrica         | Mínimo | Recomendado | Herramienta       |
| --------------- | ------ | ----------- | ----------------- |
| Line Coverage   | ≥ 80%  | ≥ 90%       | Istanbul (Vitest) |
| Branch Coverage | ≥ 75%  | ≥ 85%       | Istanbul (Vitest) |
| Mutation Score  | ≥ 70%  | ≥ 80%       | Stryker JS        |

| Tipo              | Framework                            |
| ----------------- | ------------------------------------ |
| Unit / Component  | Vitest + React Testing Library       |
| E2E               | Playwright                           |
| Visual Regression | Playwright (screenshots)             |
| Performance       | Lighthouse CI                        |

---

## Article XIV: Code Standards (Frontend)

| Elemento   | Convención       | Ejemplo              |
| ---------- | ---------------- | -------------------- |
| Ficheros   | kebab-case       | `access-control.tsx` |
| Componentes| PascalCase       | `AccessControl.tsx`  |
| Interfaces | I + PascalCase   | `IAccessConfig`      |
| Funciones  | camelCase        | `getAccessByCardId`  |
| Constantes | UPPER_SNAKE_CASE | `MAX_CARDS`          |

- Formateo: ESLint + Prettier
- Longitud de línea: 100 caracteres
- Punto y coma: [x] Sí
- Comillas: [x] Simples

---

## Article XV: Project Structure (Frontend)

```
src/
├── app/            # Router, layouts, global providers
├── features/       # Feature-sliced (access, alarms, visitors…)
│   └── access/
│       ├── api/    # TanStack Query hooks
│       ├── components/
│       ├── hooks/
│       └── types/
├── shared/         # UI primitives, utils, auth hooks
└── assets/
```

---

## Article XVII: Legacy Migration (Frontend)

Módulos WebForms a migrar (prioridad por uso):

| UserControl / Page      | Feature React         | Prioridad |
| ----------------------- | --------------------- | --------- |
| `MonSeg.aspx`           | Dashboard monitoreo   | Alta      |
| `Acessos.ascx`          | Gestión de accesos    | Alta      |
| `Visitantes.ascx`       | Visitantes            | Alta      |
| `ActivarCartoes.ascx`   | Activación de tarjetas| Media     |
| `Circuitos.ascx`        | Circuitos             | Media     |
| `LogHistorico.ascx`     | Histórico de logs     | Media     |
| `Alarmes.ascx`          | Alarmas               | Media     |

---

## Skills Provisionados (Frontend)

- `senior-frontend` — React patterns, TypeScript, TanStack Query, accesibilidad
- `playwright-e2e` — E2E testing, Page Object Model, fixtures
- `tdd-comprehensive` — TDD/BDD frontend con Vitest + RTL
