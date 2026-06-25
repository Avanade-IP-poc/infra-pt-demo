import { useMemo, useState } from 'react';
import { Button, Input } from '@/components/ui';
import type { AccessFamily, AssignVisitorCardPayload } from '../types';

export interface VisitorCardAssignmentFormProps {
  selectedCardId: string | null;
  accessFamilies: AccessFamily[];
  isSubmitting: boolean;
  onSubmit: (payload: AssignVisitorCardPayload) => Promise<void>;
}

function getInitialValidityWindow() {
  const now = new Date();
  const plusEightHours = new Date(now.getTime() + 8 * 60 * 60 * 1000);

  const toLocalInput = (date: Date) => {
    const offsetDate = new Date(date.getTime() - date.getTimezoneOffset() * 60 * 1000);
    return offsetDate.toISOString().slice(0, 16);
  };

  return {
    validFrom: toLocalInput(now),
    validUntil: toLocalInput(plusEightHours),
  };
}

export function VisitorCardAssignmentForm({
  selectedCardId,
  accessFamilies,
  isSubmitting,
  onSubmit,
}: VisitorCardAssignmentFormProps) {
  const [company, setCompany] = useState('');
  const [visitedEntity, setVisitedEntity] = useState('');
  const [vehiclePlate, setVehiclePlate] = useState('');
  const [visitorId, setVisitorId] = useState<string>(() => crypto.randomUUID());
  const [selectedFamilyIds, setSelectedFamilyIds] = useState<string[]>([]);
  const [validity, setValidity] = useState(getInitialValidityWindow());
  const [error, setError] = useState<string | null>(null);

  const familyOptions = useMemo(
    () => accessFamilies.map((family) => ({ id: family.id, label: family.name })),
    [accessFamilies],
  );

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);

    if (!selectedCardId) {
      setError('Selecione um cartão disponível antes de atribuir.');
      return;
    }

    if (!company.trim() && !visitedEntity.trim()) {
      setError('Indique a empresa ou o destinatário visitado.');
      return;
    }

    if (selectedFamilyIds.length === 0) {
      setError('Selecione pelo menos uma família de acesso.');
      return;
    }

    const validFromDate = new Date(validity.validFrom);
    const validUntilDate = new Date(validity.validUntil);

    if (Number.isNaN(validFromDate.getTime()) || Number.isNaN(validUntilDate.getTime())) {
      setError('A janela de validade é inválida.');
      return;
    }

    if (validUntilDate <= validFromDate) {
      setError('A data de fim deve ser posterior ao início.');
      return;
    }

    const payload: AssignVisitorCardPayload = {
      cardId: selectedCardId,
      visitorId,
      firstName: null,
      lastName: null,
      company: company.trim() || null,
      visitedEntity: visitedEntity.trim() || null,
      vehiclePlate: vehiclePlate.trim() || null,
      accessFamilyIds: selectedFamilyIds,
      validFrom: validFromDate.toISOString(),
      validUntil: validUntilDate.toISOString(),
    };

    await onSubmit(payload);

    setCompany('');
    setVisitedEntity('');
    setVehiclePlate('');
    setSelectedFamilyIds([]);
    setVisitorId(crypto.randomUUID());
    setValidity(getInitialValidityWindow());
  }

  return (
    <form className="flex flex-col gap-3" onSubmit={handleSubmit}>
      <Input label="Visitor Id" value={visitorId} onChange={(e) => setVisitorId(e.target.value)} />
      <Input label="Empresa" value={company} onChange={(e) => setCompany(e.target.value)} />
      <Input
        label="Destinatário visitado"
        value={visitedEntity}
        onChange={(e) => setVisitedEntity(e.target.value)}
      />
      <Input
        label="Matrícula"
        value={vehiclePlate}
        onChange={(e) => setVehiclePlate(e.target.value)}
      />

      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-slate-700" htmlFor="access-families-select">
          Famílias de acesso
        </label>
        <select
          id="access-families-select"
          multiple
          value={selectedFamilyIds}
          onChange={(event) => {
            const values = Array.from(event.target.selectedOptions).map((option) => option.value);
            setSelectedFamilyIds(values);
          }}
          className="min-h-28 rounded-lg border border-border bg-white px-3 py-2 text-sm text-slate-900 focus:border-brand-500 focus:outline-2 focus:outline-brand-500"
        >
          {familyOptions.map((family) => (
            <option key={family.id} value={family.id}>
              {family.label}
            </option>
          ))}
        </select>
      </div>

      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
        <Input
          label="Validade início"
          type="datetime-local"
          value={validity.validFrom}
          onChange={(e) => setValidity((prev) => ({ ...prev, validFrom: e.target.value }))}
        />
        <Input
          label="Validade fim"
          type="datetime-local"
          value={validity.validUntil}
          onChange={(e) => setValidity((prev) => ({ ...prev, validUntil: e.target.value }))}
        />
      </div>

      {error && <p className="text-sm text-danger">{error}</p>}

      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Atribuir...' : 'Atribuir cartão'}
      </Button>
    </form>
  );
}
