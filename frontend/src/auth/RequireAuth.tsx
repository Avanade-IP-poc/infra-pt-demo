import { AuthenticatedTemplate, UnauthenticatedTemplate } from '@azure/msal-react';
import { Navigate, Outlet } from 'react-router-dom';

/**
 * Renders child routes only when authenticated; otherwise redirects to /login.
 */
export function RequireAuth() {
  return (
    <>
      <AuthenticatedTemplate>
        <Outlet />
      </AuthenticatedTemplate>
      <UnauthenticatedTemplate>
        <Navigate to="/login" replace />
      </UnauthenticatedTemplate>
    </>
  );
}
