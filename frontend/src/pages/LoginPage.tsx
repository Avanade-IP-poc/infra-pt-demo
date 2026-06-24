import { useMsal } from '@azure/msal-react';
import { AuthLayout } from '@/components/layout/AuthLayout';
import { Button, Card } from '@/components/ui';
import { loginRequest } from '@/auth/msalConfig';

export function LoginPage() {
  const { instance } = useMsal();

  return (
    <AuthLayout>
      <Card>
        <div className="flex flex-col gap-4 text-center">
          <h1 className="text-lg font-semibold text-slate-800">Iniciar sessão</h1>
          <p className="text-sm text-slate-500">
            Autentique-se com a sua conta organizacional para aceder ao painel de controlo.
          </p>
          <Button size="lg" onClick={() => void instance.loginRedirect(loginRequest)}>
            Entrar com Azure AD
          </Button>
        </div>
      </Card>
    </AuthLayout>
  );
}
