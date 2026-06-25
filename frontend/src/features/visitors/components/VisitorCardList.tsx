import { Button, Table } from '@/components/ui';
import type { Column } from '@/components/ui';
import { formatTime } from '@/lib/formatTime';
import type { VisitorAssignment } from '../types';

export interface VisitorCardListProps {
  assignments: VisitorAssignment[];
  isLoading: boolean;
  isError: boolean;
  exitingAssignmentId: string | null;
  onRecordExit: (assignmentId: string) => void;
}

const columns = (
  onRecordExit: (assignmentId: string) => void,
  exitingAssignmentId: string | null,
): Array<Column<VisitorAssignment>> => [
  {
    key: 'card',
    header: 'Cartão',
    render: (assignment) => <span className="font-mono text-xs">{assignment.cardCode}</span>,
    className: 'w-28',
  },
  {
    key: 'company',
    header: 'Empresa / Destinatário',
    render: (assignment) => assignment.company || assignment.visitedEntity || '—',
  },
  {
    key: 'entry',
    header: 'Entrada',
    render: (assignment) => formatTime(assignment.entryTime ?? ''),
    className: 'w-24',
  },
  {
    key: 'validUntil',
    header: 'Válido até',
    render: (assignment) => formatTime(assignment.validUntil),
    className: 'w-24',
  },
  {
    key: 'actions',
    header: 'Ações',
    render: (assignment) => (
      <Button
        size="sm"
        variant="secondary"
        disabled={exitingAssignmentId === assignment.assignmentId}
        onClick={() => onRecordExit(assignment.assignmentId)}
      >
        Registar saída
      </Button>
    ),
    className: 'w-40',
  },
];

export function VisitorCardList({
  assignments,
  isLoading,
  isError,
  exitingAssignmentId,
  onRecordExit,
}: VisitorCardListProps) {
  if (isError) {
    return <p className="py-2 text-sm text-danger">Não foi possível carregar as atribuições ativas.</p>;
  }

  const emptyMessage = isLoading
    ? 'A carregar atribuições…'
    : 'Sem visitantes ativos neste terminal.';

  return (
    <Table
      columns={columns(onRecordExit, exitingAssignmentId)}
      rows={assignments}
      rowKey={(assignment) => assignment.assignmentId}
      emptyMessage={emptyMessage}
    />
  );
}
