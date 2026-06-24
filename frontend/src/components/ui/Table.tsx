import type { ReactNode } from 'react';
import { cn } from '@/lib/cn';

export interface Column<TRow> {
  key: string;
  header: ReactNode;
  render: (row: TRow) => ReactNode;
  className?: string;
}

export interface TableProps<TRow> {
  columns: Array<Column<TRow>>;
  rows: TRow[];
  rowKey: (row: TRow) => string | number;
  emptyMessage?: string;
}

export function Table<TRow>({
  columns,
  rows,
  rowKey,
  emptyMessage = 'Sem dados para apresentar.',
}: TableProps<TRow>) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse text-sm">
        <thead>
          <tr className="border-b border-border text-left text-slate-500">
            {columns.map((column) => (
              <th key={column.key} className={cn('px-3 py-2 font-medium', column.className)}>
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="px-3 py-6 text-center text-slate-400">
                {emptyMessage}
              </td>
            </tr>
          ) : (
            rows.map((row) => (
              <tr key={rowKey(row)} className="border-b border-border last:border-0 hover:bg-brand-50">
                {columns.map((column) => (
                  <td key={column.key} className={cn('px-3 py-2 text-slate-700', column.className)}>
                    {column.render(row)}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
