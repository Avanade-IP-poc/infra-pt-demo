import type { Circuit } from '../types';

export interface CircuitSelectorProps {
  circuits: Circuit[];
  value: number | null;
  onChange: (circuitId: number) => void;
  disabled?: boolean;
}

export function CircuitSelector({ circuits, value, onChange, disabled }: CircuitSelectorProps) {
  const selectId = 'circuit-selector';

  return (
    <div className="flex flex-col gap-1">
      <label htmlFor={selectId} className="text-sm font-medium text-slate-700">
        Circuito
      </label>
      <select
        id={selectId}
        value={value ?? ''}
        disabled={disabled}
        onChange={(event) => onChange(Number(event.target.value))}
        className="h-10 rounded-lg border border-border bg-white px-3 text-sm text-slate-900 focus:border-brand-500 focus:outline-2 focus:outline-brand-500 disabled:opacity-50"
      >
        <option value="" disabled>
          Selecione um circuito
        </option>
        {circuits.map((circuit) => (
          <option key={circuit.id} value={circuit.id}>
            {circuit.name}
          </option>
        ))}
      </select>
    </div>
  );
}
