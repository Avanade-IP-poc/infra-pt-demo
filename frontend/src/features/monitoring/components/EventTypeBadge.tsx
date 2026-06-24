import type { AccessEventType } from '@/features/monitoring/types';
import { cn } from '@/lib/cn';

const config: Record<AccessEventType, { label: string; className: string }> = {
  Entry: { label: 'Entrada', className: 'bg-green-100 text-green-700' },
  Exit: { label: 'Saída', className: 'bg-amber-100 text-amber-700' },
  Unknown: { label: 'Desconhecido', className: 'bg-slate-100 text-slate-600' },
};

export function EventTypeBadge({ type }: { type: AccessEventType }) {
  const { label, className } = config[type] ?? config.Unknown;
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium',
        className,
      )}
    >
      {label}
    </span>
  );
}
