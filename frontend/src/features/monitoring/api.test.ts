import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const apiFetch = vi.fn();

vi.mock('@/api/client', () => ({
  apiFetch: (...args: unknown[]) => apiFetch(...args),
}));

import { fetchAccessEvents, fetchCircuits, fetchZoneOccupancy } from './api';

describe('monitoring api', () => {
  beforeEach(() => {
    apiFetch.mockReset();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('fetchCircuits returns the raw array', async () => {
    apiFetch.mockResolvedValue([{ id: 1, name: 'Entrada', circuitGroupId: null, smiCircuitId: null }]);

    const result = await fetchCircuits();

    expect(apiFetch).toHaveBeenCalledWith('/api/v1/access-control/circuits', expect.any(Object));
    expect(result).toHaveLength(1);
  });

  it('fetchAccessEvents builds the query string and unwraps items', async () => {
    apiFetch.mockResolvedValue({ items: [{ cardCode: 'C001' }] });

    const result = await fetchAccessEvents({ circuitId: 10, hours: 24, maxEvents: 50 });

    const [url] = apiFetch.mock.calls[0];
    expect(url).toContain('circuitId=10');
    expect(url).toContain('hours=24');
    expect(url).toContain('maxEvents=50');
    expect(result).toEqual([{ cardCode: 'C001' }]);
  });

  it('fetchAccessEvents omits optional params when not provided', async () => {
    apiFetch.mockResolvedValue({ items: [] });

    await fetchAccessEvents({ circuitId: 7 });

    const [url] = apiFetch.mock.calls[0];
    expect(url).toContain('circuitId=7');
    expect(url).not.toContain('hours=');
    expect(url).not.toContain('maxEvents=');
  });

  it('fetchZoneOccupancy unwraps the items envelope', async () => {
    apiFetch.mockResolvedValue({ items: [{ zoneId: 1, zoneName: 'Receção', userCount: 3 }] });

    const result = await fetchZoneOccupancy();

    expect(apiFetch).toHaveBeenCalledWith('/api/v1/monitoring/zones', expect.any(Object));
    expect(result[0].userCount).toBe(3);
  });
});
