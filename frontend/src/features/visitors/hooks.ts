import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  assignVisitorCard,
  fetchAccessFamilies,
  fetchAvailableVisitorCards,
  fetchVisitorAssignments,
  recordVisitorExit,
} from './api';
import type { AssignVisitorCardPayload } from './types';

const ASSIGNMENTS_POLL_MS = 15_000;

function availableCardsKey(terminalId: number) {
  return ['visitor-cards-available', terminalId] as const;
}

function assignmentsKey(terminalId: number, active: boolean) {
  return ['visitor-assignments', terminalId, active] as const;
}

export function useAvailableVisitorCards(terminalId: number) {
  return useQuery({
    queryKey: availableCardsKey(terminalId),
    queryFn: () => fetchAvailableVisitorCards(terminalId),
    staleTime: 20_000,
  });
}

export function useAccessFamilies() {
  return useQuery({
    queryKey: ['access-families'],
    queryFn: fetchAccessFamilies,
    staleTime: 5 * 60_000,
  });
}

export function useVisitorAssignments(terminalId: number, active = true) {
  return useQuery({
    queryKey: assignmentsKey(terminalId, active),
    queryFn: () => fetchVisitorAssignments({ terminalId, active }),
    refetchInterval: ASSIGNMENTS_POLL_MS,
  });
}

export function useAssignVisitorCard(terminalId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: AssignVisitorCardPayload) => assignVisitorCard(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: availableCardsKey(terminalId) });
      await queryClient.invalidateQueries({ queryKey: assignmentsKey(terminalId, true) });
    },
  });
}

export function useRecordVisitorExit(terminalId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (assignmentId: string) => recordVisitorExit(assignmentId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: availableCardsKey(terminalId) });
      await queryClient.invalidateQueries({ queryKey: assignmentsKey(terminalId, true) });
    },
  });
}
