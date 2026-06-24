import { forwardRef, useId } from 'react';
import type { InputHTMLAttributes } from 'react';
import { cn } from '@/lib/cn';

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  { label, error, id, className, ...props },
  ref,
) {
  const generatedId = useId();
  const inputId = id ?? generatedId;
  const errorId = error ? `${inputId}-error` : undefined;

  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label htmlFor={inputId} className="text-sm font-medium text-slate-700">
          {label}
        </label>
      )}
      <input
        ref={ref}
        id={inputId}
        aria-invalid={error ? true : undefined}
        aria-describedby={errorId}
        className={cn(
          'h-10 rounded-lg border border-border bg-white px-3 text-sm text-slate-900',
          'focus:border-brand-500 focus:outline-2 focus:outline-offset-0 focus:outline-brand-500',
          error && 'border-danger focus:border-danger focus:outline-danger',
          className,
        )}
        {...props}
      />
      {error && (
        <span id={errorId} className="text-xs text-danger">
          {error}
        </span>
      )}
    </div>
  );
});
