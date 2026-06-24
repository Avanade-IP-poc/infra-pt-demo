import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { EventType } from '@azure/msal-browser';
import type { AuthenticationResult } from '@azure/msal-browser';
import { msalInstance } from '@/auth/msalInstance';
import { App } from '@/App';
import './index.css';

async function bootstrap() {
  await msalInstance.initialize();

  const account = msalInstance.getActiveAccount();
  if (!account && msalInstance.getAllAccounts().length > 0) {
    msalInstance.setActiveAccount(msalInstance.getAllAccounts()[0]);
  }

  msalInstance.addEventCallback((event) => {
    if (event.eventType === EventType.LOGIN_SUCCESS && event.payload) {
      const payload = event.payload as AuthenticationResult;
      msalInstance.setActiveAccount(payload.account);
    }
  });

  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  );
}

void bootstrap();
