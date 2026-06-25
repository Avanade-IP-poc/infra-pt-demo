/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_AAD_CLIENT_ID: string;
  readonly VITE_AAD_AUTHORITY: string;
  readonly VITE_AAD_REDIRECT_URI: string;
  readonly VITE_AAD_API_SCOPE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
