import { Button } from '@/components/ui';
import { formatTime } from '@/lib/formatTime';
import type { AvailableVisitorCard } from '../types';

export interface AvailableCardsListProps {
  cards: AvailableVisitorCard[];
  selectedCardId: string | null;
  onSelectCard: (cardId: string) => void;
  isLoading: boolean;
  isError: boolean;
}

export function AvailableCardsList({
  cards,
  selectedCardId,
  onSelectCard,
  isLoading,
  isError,
}: AvailableCardsListProps) {
  if (isError) {
    return <p className="text-sm text-danger">Não foi possível carregar os cartões disponíveis.</p>;
  }

  if (isLoading && cards.length === 0) {
    return <p className="text-sm text-slate-400">A carregar cartões…</p>;
  }

  if (cards.length === 0) {
    return <p className="text-sm text-slate-400">Não há cartões disponíveis neste momento.</p>;
  }

  return (
    <ul className="flex flex-col gap-2">
      {cards.map((card) => {
        const selected = selectedCardId === card.cardId;
        return (
          <li key={card.cardId} className="rounded-lg border border-border p-3">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="font-mono text-sm font-semibold text-slate-800">{card.cardCode}</p>
                <p className="text-xs text-slate-500">{card.label ?? 'Sem etiqueta'}</p>
                <p className="text-xs text-slate-400">
                  Último uso: {card.lastUsed ? formatTime(card.lastUsed) : 'Nunca'}
                </p>
              </div>
              <Button
                variant={selected ? 'secondary' : 'primary'}
                size="sm"
                onClick={() => onSelectCard(card.cardId)}
              >
                {selected ? 'Selecionado' : 'Selecionar'}
              </Button>
            </div>
          </li>
        );
      })}
    </ul>
  );
}
