import { PublicClientApplication } from '@azure/msal-browser';
import { msalConfig } from './msalConfig';

/** Singleton MSAL instance shared across the app. */
export const msalInstance = new PublicClientApplication(msalConfig);
