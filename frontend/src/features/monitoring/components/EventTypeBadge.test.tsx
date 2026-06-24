import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { EventTypeBadge } from './EventTypeBadge';

describe('EventTypeBadge', () => {
  it('renders the Portuguese label for Entry', () => {
    render(<EventTypeBadge type="Entry" />);
    expect(screen.getByText('Entrada')).toBeInTheDocument();
  });

  it('renders the Portuguese label for Exit', () => {
    render(<EventTypeBadge type="Exit" />);
    expect(screen.getByText('Saída')).toBeInTheDocument();
  });

  it('renders the Portuguese label for Unknown', () => {
    render(<EventTypeBadge type="Unknown" />);
    expect(screen.getByText('Desconhecido')).toBeInTheDocument();
  });
});
