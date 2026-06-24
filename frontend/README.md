# SICA SPA (Frontend)

Single Page Application del proyecto **SICA Modernization** (Bolt 7 — Foundation).

## Stack

- **React 18** + **TypeScript** + **Vite 6**
- **Tailwind CSS v4** (design system con tokens en `src/index.css`)
- **TanStack Query** — estado de servidor (cliente API en `src/api/`)
- **Zustand** — estado de cliente (disponible para próximos Bolts)
- **MSAL React v2** — autenticación Azure AD B2C (Authorization Code + PKCE)
- **React Router v6** — enrutado
- **Vitest** + **Testing Library** — tests unitarios/componentes

## Estructura

```text
src/
├── api/            # Cliente HTTP autenticado + QueryClient
├── auth/           # Configuración e instancia MSAL + RequireAuth
├── components/
│   ├── layout/     # DashboardLayout, AuthLayout
│   └── ui/         # Button, Input, Card, Table, Modal
├── lib/            # Utilidades (cn)
├── pages/          # LoginPage, DashboardPage
├── test/           # Setup de Vitest
├── App.tsx         # Providers (MSAL, Query, Router)
├── main.tsx        # Bootstrap MSAL + render
└── router.tsx      # Rutas (/login, /dashboard)
```

## Comandos

```bash
npm install
npm run dev            # servidor de desarrollo (http://localhost:5173)
npm run build          # build de producción
npm run test           # tests (Vitest)
npm run test:coverage  # tests con cobertura
npm run lint           # ESLint
```

## Configuración

Copia `.env.example` a `.env` y completa los valores de Azure AD B2C y la URL del backend.
En desarrollo, si `VITE_API_BASE_URL` queda vacío, las peticiones a `/api` se redirigen al
backend en `http://localhost:5000` mediante el proxy de Vite.
