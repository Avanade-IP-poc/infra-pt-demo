import { useQuery } from '@tanstack/react-query';
import { fetchAccessEvents, fetchCircuits, fetchZoneOccupancy } from './api';

const EVENTS_POLL_MS = 5_000;
const ZONES_POLL_MS = 15_000;

/** Loads the circuit list (rarely changes). */
export function useCircuits() {
  return useQuery({
    queryKey: ['circuits'],
    queryFn: ({ signal }) => fetchCircuits(signal),
    staleTime: 5 * 60_000,
  });
}

/** Loads recent access events for a circuit, polling every 5s while enabled. */
export function useAccessEvents(circuitId: number | null) {
  return useQuery({
    queryKey: ['access-events', circuitId],
    queryFn: ({ signal }) => fetchAccessEvents({ circuitId: circuitId as number }, signal),
    enabled: circuitId !== null,
    refetchInterval: circuitId !== null ? EVENTS_POLL_MS : false,
  });
}

/** Loads zone occupancy, polling every 15s. */
export function useZoneOccupancy() {
  return useQuery({
    queryKey: ['zone-occupancy'],
    queryFn: ({ signal }) => fetchZoneOccupancy(signal),
    refetchInterval: ZONES_POLL_MS,
  });
}
