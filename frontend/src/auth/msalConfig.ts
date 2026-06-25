import type { Configuration, RedirectRequest } from '@azure/msal-browser';
import { LogLevel } from '@azure/msal-browser';

/**
 * MSAL configuration for Azure AD B2C (Authorization Code + PKCE).
 * Values are sourced from Vite environment variables (see .env.example).
 */
export const msalConfig: Configuration = {
  auth: {
    clientId: import.meta.env.VITE_AAD_CLIENT_ID,
    authority: import.meta.env.VITE_AAD_AUTHORITY,
    redirectUri: import.meta.env.VITE_AAD_REDIRECT_URI,
    postLogoutRedirectUri: import.meta.env.VITE_AAD_REDIRECT_URI,
  },
  cache: {
    cacheLocation: 'sessionStorage',
    storeAuthStateInCookie: false,
  },
  system: {
    loggerOptions: {
      logLevel: LogLevel.Warning,
      piiLoggingEnabled: false,
      loggerCallback: () => {
        // Intentionally silent in the browser console; wire to telemetry later.
      },
    },
  },
};

/** Scopes requested at sign-in. */
export const loginRequest: RedirectRequest = {
  scopes: ['openid', 'profile'],
};

/** Scope required to call the SICA backend API. */
export const apiScopes: string[] = [import.meta.env.VITE_AAD_API_SCOPE];
