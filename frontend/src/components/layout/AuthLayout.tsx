import type { ReactNode } from 'react';

export function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-brand-50 px-4">
      <div className="w-full max-w-md">
        <div className="mb-6 text-center">
          <span className="inline-block rounded-md bg-brand-600 px-3 py-1.5 text-lg font-bold text-white">
            SICA
          </span>
          <p className="mt-2 text-sm text-slate-500">Sistema Integrado de Controlo de Acessos</p>
        </div>
        {children}
      </div>
    </div>
  );
}
