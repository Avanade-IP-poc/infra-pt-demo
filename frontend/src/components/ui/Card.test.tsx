import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Card } from './Card';

describe('Card', () => {
  it('renders the title and children', () => {
    render(<Card title="Resumo">Conteúdo</Card>);
    expect(screen.getByRole('heading', { name: 'Resumo' })).toBeInTheDocument();
    expect(screen.getByText('Conteúdo')).toBeInTheDocument();
  });

  it('omits the header when no title or actions are provided', () => {
    render(<Card>Apenas corpo</Card>);
    expect(screen.queryByRole('heading')).not.toBeInTheDocument();
  });

  it('renders actions when provided', () => {
    render(
      <Card title="Com acções" actions={<button type="button">Editar</button>}>
        Corpo
      </Card>,
    );
    expect(screen.getByRole('button', { name: 'Editar' })).toBeInTheDocument();
  });
});
