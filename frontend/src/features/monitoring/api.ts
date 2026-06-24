import { apiFetch } from '@/api/client';
import type { AccessEvent, Circuit, ZoneOccupancy } from './types';

interface ItemsEnvelope<T> {
  items: T[];
}

/** Lists the access circuits (reader points). */
export function fetchCircuits(signal?: AbortSignal): Promise<Circuit[]> {
  return apiFetch<Circuit[]>('/api/v1/access-control/circuits', { signal });
}

/** Lists recent access events for a circuit (RULE-010/011). */
export async function fetchAccessEvents(
  params: { circuitId: number; hours?: number; maxEvents?: number },
  signal?: AbortSignal,
): Promise<AccessEvent[]> {
  const query = new URLSearchParams({ circuitId: String(params.circuitId) });
  if (params.hours !== undefined) {
    query.set('hours', String(params.hours));
  }
  if (params.maxEvents !== undefined) {
    query.set('maxEvents', String(params.maxEvents));
  }

  const response = await apiFetch<ItemsEnvelope<AccessEvent>>(
    `/api/v1/monitoring/events?${query.toString()}`,
    { signal },
  );
  return response.items;
}

/** Lists the current occupancy per geographical zone. */
export async function fetchZoneOccupancy(signal?: AbortSignal): Promise<ZoneOccupancy[]> {
  const response = await apiFetch<ItemsEnvelope<ZoneOccupancy>>('/api/v1/monitoring/zones', {
    signal,
  });
  return response.items;
}
