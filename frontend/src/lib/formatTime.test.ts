import { describe, expect, it } from 'vitest';
import { formatTime } from './formatTime';

describe('formatTime', () => {
  it('formats a valid ISO timestamp as HH:mm:ss', () => {
    const result = formatTime('2026-06-24T10:15:30Z');
    expect(result).toMatch(/\d{2}:\d{2}:\d{2}/);
  });

  it('returns a dash for an invalid timestamp', () => {
    expect(formatTime('not-a-date')).toBe('—');
  });
});
