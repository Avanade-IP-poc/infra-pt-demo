import { apiFetch } from '@/api/client';
import type {
  AccessFamily,
  AssignVisitorCardPayload,
  AssignVisitorCardResult,
  AvailableVisitorCard,
  VisitorAssignment,
} from './types';

export function fetchAvailableVisitorCards(terminalId: number): Promise<AvailableVisitorCard[]> {
  return apiFetch<AvailableVisitorCard[]>(
    `/api/v1/cards/visitors/available?terminalId=${terminalId}`,
  );
}

export function fetchAccessFamilies(): Promise<AccessFamily[]> {
  return apiFetch<AccessFamily[]>('/api/v1/access-control/families');
}

export function fetchVisitorAssignments(params: {
  terminalId: number;
  active?: boolean;
}): Promise<VisitorAssignment[]> {
  const active = params.active ?? true;
  return apiFetch<VisitorAssignment[]>(
    `/api/v1/cards/visitors/assignments?terminalId=${params.terminalId}&active=${active}`,
  );
}

export function assignVisitorCard(
  payload: AssignVisitorCardPayload,
): Promise<AssignVisitorCardResult> {
  return apiFetch<AssignVisitorCardResult>('/api/v1/cards/visitors/assign', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export function recordVisitorExit(assignmentId: string): Promise<void> {
  return apiFetch<void>(`/api/v1/cards/visitors/assignments/${assignmentId}/exit`, {
    method: 'POST',
  });
}
