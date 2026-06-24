import { useEffect, useState } from 'react';
import { Card } from '@/components/ui';
import { CircuitSelector } from '@/features/monitoring/components/CircuitSelector';
import { EventLog } from '@/features/monitoring/components/EventLog';
import { ZoneOccupancyPanel } from '@/features/monitoring/components/ZoneOccupancyPanel';
import {
  useAccessEvents,
  useCircuits,
  useZoneOccupancy,
} from '@/features/monitoring/hooks';

export function DashboardPage() {
  const [circuitId, setCircuitId] = useState<number | null>(null);

  const circuitsQuery = useCircuits();
  const eventsQuery = useAccessEvents(circuitId);
  const zonesQuery = useZoneOccupancy();

  const circuits = circuitsQuery.data ?? [];

  // Auto-select the first circuit once the list is available.
  useEffect(() => {
    if (circuitId === null && circuits.length > 0) {
      setCircuitId(circuits[0].id);
    }
  }, [circuitId, circuits]);

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-xl font-semibold text-slate-800">Dashboard de monitorização</h1>
        <p className="text-sm text-slate-500">Acessos físicos em tempo (cuasi) real.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Card
          title="Eventos recentes"
          className="lg:col-span-2"
          actions={
            <CircuitSelector
              circuits={circuits}
              value={circuitId}
              onChange={setCircuitId}
              disabled={circuitsQuery.isLoading || circuits.length === 0}
            />
          }
        >
          <EventLog
            events={eventsQuery.data ?? []}
            isLoading={eventsQuery.isLoading}
            isError={eventsQuery.isError}
          />
        </Card>

        <Card title="Ocupação por zona">
          <ZoneOccupancyPanel
            zones={zonesQuery.data ?? []}
            isLoading={zonesQuery.isLoading}
            isError={zonesQuery.isError}
          />
        </Card>
      </div>
    </div>
  );
}
