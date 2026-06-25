import { useMemo, useState } from 'react';
import { Card, Input } from '@/components/ui';
import { AvailableCardsList } from '@/features/visitors/components/AvailableCardsList';
import { VisitorCardAssignmentForm } from '@/features/visitors/components/VisitorCardAssignmentForm';
import { VisitorCardList } from '@/features/visitors/components/VisitorCardList';
import {
  useAccessFamilies,
  useAssignVisitorCard,
  useAvailableVisitorCards,
  useRecordVisitorExit,
  useVisitorAssignments,
} from '@/features/visitors/hooks';
import type { AssignVisitorCardPayload } from '@/features/visitors/types';

export function VisitorsPage() {
  const [terminalId, setTerminalId] = useState(1);
  const [selectedCardId, setSelectedCardId] = useState<string | null>(null);

  const availableCardsQuery = useAvailableVisitorCards(terminalId);
  const assignmentsQuery = useVisitorAssignments(terminalId, true);
  const accessFamiliesQuery = useAccessFamilies();

  const assignMutation = useAssignVisitorCard(terminalId);
  const exitMutation = useRecordVisitorExit(terminalId);

  const selectedCardStillAvailable = useMemo(() => {
    if (!selectedCardId) {
      return null;
    }
    const exists = (availableCardsQuery.data ?? []).some((card) => card.cardId === selectedCardId);
    return exists ? selectedCardId : null;
  }, [availableCardsQuery.data, selectedCardId]);

  async function handleAssign(payload: AssignVisitorCardPayload) {
    await assignMutation.mutateAsync(payload);
  }

  async function handleRecordExit(assignmentId: string) {
    await exitMutation.mutateAsync(assignmentId);
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-xl font-semibold text-slate-800">Gestão de visitantes</h1>
        <p className="text-sm text-slate-500">Atribuição e devolução de cartões de visitante.</p>
      </div>

      <Card title="Contexto do terminal">
        <div className="max-w-xs">
          <Input
            type="number"
            min={1}
            label="Terminal Id"
            value={String(terminalId)}
            onChange={(e) => setTerminalId(Math.max(1, Number(e.target.value || '1')))}
          />
        </div>
      </Card>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <Card title="Cartões disponíveis" className="xl:col-span-1">
          <AvailableCardsList
            cards={availableCardsQuery.data ?? []}
            selectedCardId={selectedCardStillAvailable}
            onSelectCard={setSelectedCardId}
            isLoading={availableCardsQuery.isLoading}
            isError={availableCardsQuery.isError}
          />
        </Card>

        <Card title="Atribuir cartão" className="xl:col-span-2">
          <VisitorCardAssignmentForm
            selectedCardId={selectedCardStillAvailable}
            accessFamilies={accessFamiliesQuery.data ?? []}
            isSubmitting={assignMutation.isPending}
            onSubmit={handleAssign}
          />
          {assignMutation.isError && (
            <p className="mt-3 text-sm text-danger">Não foi possível atribuir o cartão.</p>
          )}
        </Card>
      </div>

      <Card title="Atribuições ativas">
        <VisitorCardList
          assignments={assignmentsQuery.data ?? []}
          isLoading={assignmentsQuery.isLoading}
          isError={assignmentsQuery.isError}
          exitingAssignmentId={exitMutation.isPending ? exitMutation.variables ?? null : null}
          onRecordExit={handleRecordExit}
        />
      </Card>
    </div>
  );
}
