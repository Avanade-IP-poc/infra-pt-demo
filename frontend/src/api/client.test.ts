import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const acquireTokenSilent = vi.fn();
const getActiveAccount = vi.fn();
const getAllAccounts = vi.fn();

vi.mock('@/auth/msalInstance', () => ({
  msalInstance: {
    acquireTokenSilent: (...args: unknown[]) => acquireTokenSilent(...args),
    getActiveAccount: () => getActiveAccount(),
    getAllAccounts: () => getAllAccounts(),
  },
}));

vi.mock('@/auth/msalConfig', () => ({
  apiScopes: ['api://sica/scope'],
}));

import { apiFetch } from './client';

describe('apiFetch', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    acquireTokenSilent.mockReset();
    getActiveAccount.mockReset();
    getAllAccounts.mockReset();
    getAllAccounts.mockReturnValue([]);
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('returns parsed JSON on a successful response', async () => {
    getActiveAccount.mockReturnValue(null);
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        new Response(JSON.stringify({ value: 42 }), { status: 200 }),
      ),
    );

    const result = await apiFetch<{ value: number }>('/api/v1/test');

    expect(result.value).toBe(42);
  });

  it('attaches a bearer token when an account is active', async () => {
    getActiveAccount.mockReturnValue({ homeAccountId: 'abc' });
    acquireTokenSilent.mockResolvedValue({ accessToken: 'token-123' });
    const fetchMock = vi
      .fn()
      .mockResolvedValue(new Response('{}', { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);

    await apiFetch('/api/v1/secure');

    const [, init] = fetchMock.mock.calls[0];
    const headers = init.headers as Headers;
    expect(headers.get('Authorization')).toBe('Bearer token-123');
  });

  it('returns undefined for a 204 No Content response', async () => {
    getActiveAccount.mockReturnValue(null);
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(null, { status: 204 })));

    const result = await apiFetch('/api/v1/empty');

    expect(result).toBeUndefined();
  });

  it('throws ApiError with the status on a failed response', async () => {
    getActiveAccount.mockReturnValue(null);
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('nope', { status: 403 })));

    await expect(apiFetch('/api/v1/forbidden')).rejects.toMatchObject({
      name: 'ApiError',
      status: 403,
    });
  });
});
