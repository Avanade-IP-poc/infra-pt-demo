import type { ZoneOccupancy } from '../types';

export interface ZoneOccupancyPanelProps {
  zones: ZoneOccupancy[];
  isLoading: boolean;
  isError: boolean;
}

export function ZoneOccupancyPanel({ zones, isLoading, isError }: ZoneOccupancyPanelProps) {
  if (isError) {
    return <p className="py-2 text-sm text-danger">Não foi possível carregar as zonas.</p>;
  }

  if (isLoading && zones.length === 0) {
    return <p className="py-2 text-sm text-slate-400">A carregar zonas…</p>;
  }

  if (zones.length === 0) {
    return <p className="py-2 text-sm text-slate-400">Sem zonas monitorizadas.</p>;
  }

  return (
    <ul className="flex flex-col gap-2">
      {zones.map((zone) => (
        <li
          key={zone.zoneId}
          className="flex items-center justify-between rounded-lg border border-border px-3 py-2"
        >
          <span className="text-sm text-slate-700">{zone.zoneName}</span>
          <span className="rounded-full bg-brand-50 px-2.5 py-0.5 text-sm font-semibold text-brand-700 tabular-nums">
            {zone.userCount}
          </span>
        </li>
      ))}
    </ul>
  );
}
