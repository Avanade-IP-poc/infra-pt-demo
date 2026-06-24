import { MsalProvider } from '@azure/msal-react';
import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { msalInstance } from '@/auth/msalInstance';
import { queryClient } from '@/api/queryClient';
import { router } from '@/router';

export function App() {
  return (
    <MsalProvider instance={msalInstance}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </MsalProvider>
  );
}
