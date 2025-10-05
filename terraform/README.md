# Terraform para Tech Challenge - Deploy EKS

Este diretório contém os arquivos Terraform para fazer deploy da aplicação Tech Challenge no cluster EKS.

## 🏗️ Estrutura

```
terraform/
├── main.tf           # Providers e data sources
├── variables.tf      # Variáveis de entrada
├── kubernetes.tf     # Namespace, ConfigMap e Secret
├── deployment.tf     # Deployment da aplicação
├── services.tf       # Services (ClusterIP e LoadBalancer)
├── hpa.tf           # Horizontal Pod Autoscaler
├── outputs.tf       # Outputs do Terraform
└── README.md        # Esta documentação
```

## 🚀 Características

### ✅ **Recursos Criados:**
- **Namespace**: `tech-challenge` isolado
- **ConfigMap**: Configurações não-sensíveis
- **Secret**: Dados sensíveis (RDS via SSM, JWT, API Key)
- **Deployment**: 2 replicas com health checks e resource limits
- **Service**: ClusterIP para comunicação interna
- **LoadBalancer**: AWS NLB para acesso externo
- **HPA**: Auto scaling 2-8 pods (CPU 70%, Memory 80%)

### 🔧 **Configurações:**
- **Image**: `${ECR_URL}:latest` (sempre puxa a versão mais recente)
- **Resources**: 250m-500m CPU, 256Mi-512Mi Memory
- **Health Checks**: `/health` endpoint com timeouts configurados
- **Auto Scaling**: Inteligente com políticas de scale up/down

## 📋 Variáveis Necessárias

### **Via GitHub Secrets (Todos Obrigatórios):**
- `EKS_CLUSTER_NAME` - Nome do cluster EKS
- `ECR_REPOSITORY_URL` - URL do repositório ECR
- `JWT_SECRET` - Secret para JWT
- `API_KEY` - Chave da API
- `DB_PG_NAME` - Nome do banco de dados
- `DB_PG_PORT` - Porta do banco de dados
- `JWT_ACCESS_TOKEN_EXPIRATION_TIME` - TTL do access token JWT
- `JWT_REFRESH_TOKEN_EXPIRATION_TIME` - TTL do refresh token JWT
- `AWS_ACCESS_KEY_ID` - Credenciais AWS
- `AWS_SECRET_ACCESS_KEY` - Credenciais AWS
- `AWS_SESSION_TOKEN` - Token de sessão AWS

### **Via SSM Parameter Store:**
- `/main/rds_endpoint` - Endpoint do RDS
- `main/db_username` - Usuário do banco
- `main/db_password` - Senha do banco

## 🎯 Deploy Automático

O deploy é executado automaticamente via GitHub Actions:

1. **Build & Push** da imagem para ECR
2. **Terraform Init** - Inicializa o estado
3. **Terraform Plan** - Mostra mudanças planejadas
4. **Terraform Apply** - Aplica as mudanças
5. **Get LoadBalancer URL** - Exibe URL da aplicação

## 🌐 Acesso à Aplicação

Após o deploy, a aplicação fica disponível via LoadBalancer da AWS:

```bash
# Obter URL do LoadBalancer
kubectl get svc tech-challenge-loadbalancer -n tech-challenge

# A URL aparece automaticamente nos logs do CI
```

## 🔍 Comandos Úteis

```bash
# Ver status dos recursos
kubectl get all -n tech-challenge

# Ver logs da aplicação
kubectl logs -l app=tech-challenge -f -n tech-challenge

# Ver status do HPA
kubectl get hpa -n tech-challenge

# Ver métricas dos pods
kubectl top pods -n tech-challenge
```

## 🎯 Vantagens do Terraform

- ✅ **Infraestrutura como Código**: Versionamento e reprodutibilidade
- ✅ **Estado Gerenciado**: Controle preciso das mudanças
- ✅ **Planificação**: Preview das mudanças antes de aplicar
- ✅ **Rollback**: Fácil reversão se necessário
- ✅ **Modularidade**: Código organizado e reutilizável
