import { Table } from '@/components/ui';
import type { Column } from '@/components/ui';
import { formatTime } from '@/lib/formatTime';
import type { AccessEvent } from '../types';
import { EventTypeBadge } from './EventTypeBadge';

export interface EventLogProps {
  events: AccessEvent[];
  isLoading: boolean;
  isError: boolean;
}

const columns: Array<Column<AccessEvent>> = [
  {
    key: 'timestamp',
    header: 'Hora',
    render: (event) => <span className="tabular-nums">{formatTime(event.timestamp)}</span>,
    className: 'w-24',
  },
  {
    key: 'personName',
    header: 'Pessoa',
    render: (event) => event.personName,
  },
  {
    key: 'cardCode',
    header: 'Cartão',
    render: (event) => <span className="font-mono text-xs">{event.cardCode}</span>,
    className: 'w-28',
  },
  {
    key: 'eventType',
    header: 'Movimento',
    render: (event) => <EventTypeBadge type={event.eventType} />,
    className: 'w-32',
  },
];

export function EventLog({ events, isLoading, isError }: EventLogProps) {
  if (isError) {
    return <p className="py-4 text-sm text-danger">Não foi possível carregar os eventos.</p>;
  }

  const emptyMessage = isLoading ? 'A carregar eventos…' : 'Sem eventos recentes neste circuito.';

  return (
    <Table
      columns={columns}
      rows={events}
      rowKey={(event) => `${event.cardCode}-${event.timestamp}`}
      emptyMessage={emptyMessage}
    />
  );
}
