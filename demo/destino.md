# Arquitetura Proposta
 
## Visão Geral
 
A arquitetura proposta visa modernizar a aplicação, promovendo desacoplamento, segurança, escalabilidade e facilidade de manutenção, alinhada com práticas cloud-native e serviços Azure.
 
## Diagrama de Arquitetura (Mermaid)
 
```mermaid
graph LR
    A["🖥️ SPA React/Angular"] -->|REST| B["🚪 API Gateway"]
    B -->|REST| C["⚙️ .NET 6+ Web API"]
    C -->|Event| D["⚡ Azure Functions"]
    C -->|DB| E["🗄️ Azure SQL/Cosmos DB"]
    D -->|DB| E
    C -->|Logs| F["📊 Azure Monitor"]
    C -->|Auth| G["🔐 Azure AD B2C"]
    H["📄 WebForms (Legacy)"] -.->|Migração| C
   
    style A fill:#e6f3ff,stroke:#0066cc,stroke-width:2px
    style B fill:#fff0e6,stroke:#ff9900,stroke-width:2px
    style C fill:#e6ffe6,stroke:#00cc00,stroke-width:2px
    style D fill:#f0e6ff,stroke:#9933ff,stroke-width:2px
    style E fill:#ffe6e6,stroke:#cc0000,stroke-width:2px
    style F fill:#f0f0f0,stroke:#333,stroke-width:2px
    style G fill:#fff5e6,stroke:#cc6600,stroke-width:2px
    style H fill:#f0f0f0,stroke:#999,stroke-width:2px
```
 
## Componentes Principais
 
- **Frontend SPA:** Aplicação moderna (React/Angular) para UI responsiva
- **API Gateway:** Centraliza autenticação, logging e roteamento
- **Web API (.NET 6+):** Lógica de negócio, exposta via REST
- **Azure Functions:** Processamento assíncrono e integração
- **Base de Dados:** Azure SQL Database ou Cosmos DB
- **Monitorização:** Azure Monitor, Application Insights
- **Autenticação:** Azure AD B2C/Entra ID
- **Integração Legada:** WebForms em modo read-only durante transição
 
## Estratégia de Migração
 
- **Fase 1:** Rehost WebForms em Azure App Service
- **Fase 2:** Extrair APIs e lógica de negócio para .NET 6+
- **Fase 3:** Migrar UI para SPA
- **Fase 4:** Substituir integrações e módulos legados
 
## Benefícios Esperados
 
- Redução de riscos de segurança
- Facilidade de manutenção e evolução
- Escalabilidade horizontal
- Observabilidade e automação
 
## Considerações Técnicas
 
- Utilização de pipelines CI/CD (GitHub Actions/Azure DevOps)
- Infraestrutura como código (Bicep/Terraform)
- Gestão centralizada de segredos (Key Vault)
- Monitorização contínua e alertas
 