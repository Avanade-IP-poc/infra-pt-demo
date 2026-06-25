---
name: senior-frontend
description: Comprehensive frontend development skill for building modern, performant web applications using React 18, TypeScript, Tailwind CSS, TanStack Query, Zustand and Vite. Use when developing frontend features, optimizing performance, implementing UI/UX, managing state, or reviewing frontend code for the SICA SPA. Triggers => "React component", "TypeScript frontend", "TanStack Query", "Zustand", "Vite", "Tailwind", "frontend feature", "SPA", "MSAL React", "component patterns".
provisioned_from: .boltf/available-skills/frontend/senior-frontend
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Senior Frontend — React 18 + TypeScript (SICA SPA)

Modern frontend development with React 18, TypeScript, Vite, TanStack Query, Zustand and
Tailwind CSS v4.

## When to Use

- Scaffolding React components for SICA features (Access, Alarms, Visitors, etc.)
- Implementing TanStack Query hooks for API calls
- Setting up MSAL React authentication (Azure AD B2C)
- Managing state with Zustand
- Performance optimization (bundle analysis, code splitting)
- Writing Vitest + React Testing Library tests

## Project Structure (Feature-Sliced)

```
src/
├── app/
│   ├── App.tsx           # Router + providers
│   ├── router.tsx        # React Router v6 routes
│   └── providers.tsx     # MsalProvider, QueryClientProvider, etc.
├── features/
│   ├── access/           # Acessos.ascx migration
│   │   ├── api/          # TanStack Query hooks
│   │   ├── components/
│   │   ├── hooks/
│   │   └── types/
│   ├── monitoring/       # MonSeg.aspx migration
│   ├── visitors/         # Visitantes.ascx migration
│   ├── cards/            # ActivarCartoes.ascx migration
│   └── alarms/           # Alarmes.ascx migration
├── shared/
│   ├── ui/               # shadcn/ui primitives (Button, Table, etc.)
│   ├── hooks/            # useAuth, useDebounce, etc.
│   └── utils/
└── assets/
```

## Component Pattern

```typescript
// features/access/components/AccessTable.tsx
import { useAccessList } from '../api/use-access-list';

interface AccessTableProps {
  zoneId: string;
}

export function AccessTable({ zoneId }: AccessTableProps) {
  const { data, isLoading, error } = useAccessList(zoneId);

  if (isLoading) return <TableSkeleton />;
  if (error) return <ErrorAlert message={error.message} />;

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Card ID</TableHead>
          <TableHead>Access Time</TableHead>
          <TableHead>Status</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data?.map((entry) => (
          <AccessTableRow key={entry.id} entry={entry} />
        ))}
      </TableBody>
    </Table>
  );
}
```

## TanStack Query Hook Pattern

```typescript
// features/access/api/use-access-list.ts
import { useQuery } from '@tanstack/react-query';
import { accessApi } from './access-api';

export function useAccessList(zoneId: string) {
  return useQuery({
    queryKey: ['access', 'list', zoneId],
    queryFn: () => accessApi.getByZone(zoneId),
    staleTime: 30_000,   // 30s
    enabled: !!zoneId,
  });
}

export function useActivateCard() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: accessApi.activateCard,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['access'] });
    },
  });
}
```

## MSAL React — Azure AD B2C

```typescript
// app/providers.tsx
import { MsalProvider } from '@azure/msal-react';
import { PublicClientApplication } from '@azure/msal-browser';

const msalInstance = new PublicClientApplication({
  auth: {
    clientId: import.meta.env.VITE_AZURE_B2C_CLIENT_ID,
    authority: `https://${import.meta.env.VITE_AZURE_B2C_TENANT}.b2clogin.com/...`,
    knownAuthorities: [import.meta.env.VITE_AZURE_B2C_TENANT + '.b2clogin.com'],
    redirectUri: window.location.origin,
  },
});

// Hook usage
import { useMsal, useIsAuthenticated } from '@azure/msal-react';

function Header() {
  const { accounts } = useMsal();
  const isAuthenticated = useIsAuthenticated();
  return isAuthenticated ? <UserMenu user={accounts[0]} /> : <LoginButton />;
}
```

## Zustand State (Client State Only)

```typescript
// shared/stores/ui-store.ts
import { create } from 'zustand';

interface UIStore {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  selectedZone: string | null;
  setSelectedZone: (id: string | null) => void;
}

export const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  selectedZone: null,
  setSelectedZone: (id) => set({ selectedZone: id }),
}));
```

## Testing — Vitest + RTL

```typescript
// features/access/components/AccessTable.test.tsx
import { render, screen } from '@testing-library/react';
import { AccessTable } from './AccessTable';
import { createWrapper } from '@/test-utils/create-wrapper';

describe('AccessTable', () => {
  it('renders access entries', async () => {
    render(<AccessTable zoneId="ZONE-A" />, { wrapper: createWrapper() });
    expect(await screen.findByText('CARD-001')).toBeInTheDocument();
  });

  it('shows error when API fails', async () => {
    server.use(/* MSW handler returning 500 */);
    render(<AccessTable zoneId="ZONE-A" />, { wrapper: createWrapper() });
    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
```

## Naming Conventions

| Element     | Convention       | Example               |
| ----------- | ---------------- | --------------------- |
| Files       | kebab-case       | `access-table.tsx`    |
| Components  | PascalCase       | `AccessTable`         |
| Interfaces  | I + PascalCase   | `IAccessEntry`        |
| Hooks       | use + camelCase  | `useAccessList`       |
| Constants   | UPPER_SNAKE      | `MAX_RETRY_COUNT`     |

## Code Quality

- Formatter: Prettier (`singleQuote: true`, `printWidth: 100`)
- Linter: ESLint (eslint-config-react-app + @typescript-eslint)
- Pre-commit: husky + lint-staged

## References (source)

`.boltf/available-skills/frontend/senior-frontend/`
- `references/react_patterns.md`
- `references/frontend_best_practices.md`
