import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import type { AccessEvent } from '../types';
import { EventLog } from './EventLog';

const sampleEvents: AccessEvent[] = [
  {
    timestamp: '2026-06-24T10:15:00Z',
    cardCode: 'C001',
    personName: 'João Silva',
    circuitId: 10,
    circuitName: 'Entrada Principal',
    eventType: 'Entry',
  },
];

describe('EventLog', () => {
  it('renders an error message when isError is true', () => {
    render(<EventLog events={[]} isLoading={false} isError />);
    expect(screen.getByText('Não foi possível carregar os eventos.')).toBeInTheDocument();
  });

  it('shows a loading message when empty and loading', () => {
    render(<EventLog events={[]} isLoading isError={false} />);
    expect(screen.getByText('A carregar eventos…')).toBeInTheDocument();
  });

  it('shows the empty message when there are no events and not loading', () => {
    render(<EventLog events={[]} isLoading={false} isError={false} />);
    expect(screen.getByText('Sem eventos recentes neste circuito.')).toBeInTheDocument();
  });

  it('renders rows for each event', () => {
    render(<EventLog events={sampleEvents} isLoading={false} isError={false} />);
    expect(screen.getByText('João Silva')).toBeInTheDocument();
    expect(screen.getByText('C001')).toBeInTheDocument();
    expect(screen.getByText('Entrada')).toBeInTheDocument();
  });
});
