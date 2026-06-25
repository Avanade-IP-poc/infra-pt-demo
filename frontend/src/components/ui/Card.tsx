import type { HTMLAttributes, ReactNode } from 'react';
import { cn } from '@/lib/cn';

export interface CardProps extends Omit<HTMLAttributes<HTMLDivElement>, 'title'> {
  title?: ReactNode;
  actions?: ReactNode;
}

export function Card({ title, actions, className, children, ...props }: CardProps) {
  return (
    <section
      className={cn(
        'rounded-[var(--radius-card)] border border-border bg-surface shadow-sm',
        className,
      )}
      {...props}
    >
      {(title || actions) && (
        <header className="flex items-center justify-between border-b border-border px-5 py-4">
          {title && <h2 className="text-base font-semibold text-slate-800">{title}</h2>}
          {actions && <div className="flex items-center gap-2">{actions}</div>}
        </header>
      )}
      <div className="px-5 py-4">{children}</div>
    </section>
  );
}
