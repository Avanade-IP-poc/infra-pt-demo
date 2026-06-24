import { Card } from '@/components/ui';

export function DashboardPage() {
  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-xl font-semibold text-slate-800">Dashboard</h1>
        <p className="text-sm text-slate-500">Visão geral do controlo de acessos.</p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
        <Card title="Acessos hoje">
          <p className="text-3xl font-bold text-brand-700">—</p>
          <p className="text-xs text-slate-400">Disponível no Bolt 8 (Dashboard)</p>
        </Card>
        <Card title="Visitantes ativos">
          <p className="text-3xl font-bold text-brand-700">—</p>
          <p className="text-xs text-slate-400">Disponível no Bolt 9 (Visitantes)</p>
        </Card>
        <Card title="Zonas monitorizadas">
          <p className="text-3xl font-bold text-brand-700">—</p>
          <p className="text-xs text-slate-400">Disponível no Bolt 8 (Dashboard)</p>
        </Card>
      </div>
    </div>
  );
}
