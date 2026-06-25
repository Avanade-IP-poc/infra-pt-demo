import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const apiFetch = vi.fn();

vi.mock('@/api/client', () => ({
  apiFetch: (...args: unknown[]) => apiFetch(...args),
}));

import {
  assignVisitorCard,
  fetchAccessFamilies,
  fetchAvailableVisitorCards,
  fetchVisitorAssignments,
  recordVisitorExit,
} from './api';

describe('visitors api', () => {
  beforeEach(() => {
    apiFetch.mockReset();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('requests available visitor cards with terminalId', async () => {
    apiFetch.mockResolvedValue([]);

    await fetchAvailableVisitorCards(3);

    expect(apiFetch).toHaveBeenCalledWith('/api/v1/cards/visitors/available?terminalId=3');
  });

  it('requests active assignments by default', async () => {
    apiFetch.mockResolvedValue([]);

    await fetchVisitorAssignments({ terminalId: 2 });

    expect(apiFetch).toHaveBeenCalledWith(
      '/api/v1/cards/visitors/assignments?terminalId=2&active=true',
    );
  });

  it('posts assign visitor card payload', async () => {
    apiFetch.mockResolvedValue({ assignmentId: '1', entryTime: '2026-06-25T10:00:00Z' });

    await assignVisitorCard({
      cardId: 'card',
      visitorId: 'visitor',
      accessFamilyIds: ['family'],
      validFrom: '2026-06-25T08:00:00Z',
      validUntil: '2026-06-25T18:00:00Z',
    });

    expect(apiFetch).toHaveBeenCalledWith('/api/v1/cards/visitors/assign', expect.any(Object));
  });

  it('posts record exit for an assignment', async () => {
    apiFetch.mockResolvedValue(undefined);

    await recordVisitorExit('assignment-1');

    expect(apiFetch).toHaveBeenCalledWith(
      '/api/v1/cards/visitors/assignments/assignment-1/exit',
      expect.any(Object),
    );
  });

  it('fetches access families from access-control context', async () => {
    apiFetch.mockResolvedValue([]);

    await fetchAccessFamilies();

    expect(apiFetch).toHaveBeenCalledWith('/api/v1/access-control/families');
  });
});
