import { describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders its children', () => {
    render(<Button>Guardar</Button>);
    expect(screen.getByRole('button', { name: 'Guardar' })).toBeInTheDocument();
  });

  it('defaults to type "button"', () => {
    render(<Button>Acção</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('type', 'button');
  });

  it('invokes onClick when pressed', async () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Clica</Button>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('does not invoke onClick when disabled', async () => {
    const onClick = vi.fn();
    render(
      <Button disabled onClick={onClick}>
        Bloqueado
      </Button>,
    );
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).not.toHaveBeenCalled();
  });

  it('applies the danger variant classes', () => {
    render(<Button variant="danger">Eliminar</Button>);
    expect(screen.getByRole('button').className).toContain('bg-danger');
  });
});
