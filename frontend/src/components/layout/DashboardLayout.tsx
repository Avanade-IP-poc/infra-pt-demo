import { useMsal } from '@azure/msal-react';
import { NavLink, Outlet } from 'react-router-dom';
import { Button } from '@/components/ui';
import { cn } from '@/lib/cn';

const navItems = [{ to: '/dashboard', label: 'Dashboard' }];

export function DashboardLayout() {
  const { instance, accounts } = useMsal();
  const account = accounts[0];

  return (
    <div className="flex min-h-screen flex-col">
      <header className="flex items-center justify-between border-b border-border bg-surface px-6 py-3">
        <div className="flex items-center gap-3">
          <span className="rounded-md bg-brand-600 px-2 py-1 text-sm font-bold text-white">SICA</span>
          <span className="text-sm text-slate-500">Controlo de Acessos</span>
        </div>
        <div className="flex items-center gap-3">
          {account && <span className="text-sm text-slate-600">{account.name ?? account.username}</span>}
          <Button
            variant="secondary"
            size="sm"
            onClick={() => void instance.logoutRedirect()}
          >
            Terminar sessão
          </Button>
        </div>
      </header>

      <div className="flex flex-1">
        <nav className="w-56 border-r border-border bg-surface px-3 py-4">
          <ul className="flex flex-col gap-1">
            {navItems.map((item) => (
              <li key={item.to}>
                <NavLink
                  to={item.to}
                  className={({ isActive }) =>
                    cn(
                      'block rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                      isActive
                        ? 'bg-brand-50 text-brand-700'
                        : 'text-slate-600 hover:bg-slate-100',
                    )
                  }
                >
                  {item.label}
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>

        <main className="flex-1 px-6 py-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
