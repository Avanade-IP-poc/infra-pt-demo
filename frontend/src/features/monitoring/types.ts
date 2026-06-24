/** Circuit (reader point) as returned by GET /api/v1/access-control/circuits. */
export interface Circuit {
  id: number;
  name: string;
  circuitGroupId: number | null;
  smiCircuitId: number | null;
}

/** Movement classification (mirrors backend RULE-011 AccessEventType). */
export type AccessEventType = 'Entry' | 'Exit' | 'Unknown';

/** Access event as returned by GET /api/v1/monitoring/events. */
export interface AccessEvent {
  timestamp: string;
  cardCode: string;
  personName: string;
  circuitId: number;
  circuitName: string;
  eventType: AccessEventType;
}

/** Zone occupancy as returned by GET /api/v1/monitoring/zones. */
export interface ZoneOccupancy {
  zoneId: number;
  zoneName: string;
  userCount: number;
}
