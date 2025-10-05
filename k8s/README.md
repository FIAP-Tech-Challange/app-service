# Kubernetes Deployment

Este diretório contém os manifestos Kubernetes para fazer o deploy da aplicação Tech Challenge no cluster EKS.

## Estrutura Simplificada

```
k8s/
├── namespace.yaml                 # Namespace da aplicação
├── configmap.yaml                 # ConfigMap com configurações não-sensíveis
├── deployment.yaml                # Deployment da aplicação
├── service.yaml                   # Service para exposição interna
├── loadbalancer.yaml              # LoadBalancer para acesso externo
├── hpa.yaml                       # Horizontal Pod Autoscaler
├── kustomization.yaml             # Kustomization principal
├── README.md                      # Esta documentação
```

## Configuração

### Secrets necessários no GitHub Actions

Para que o deploy funcione corretamente, você precisa configurar os seguintes secrets no seu repositório GitHub:

#### AWS e ECR:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY` 
- `AWS_SESSION_TOKEN`
- `ECR_REPOSITORY_URL` - URL completa do seu repositório ECR (ex: `123456789012.dkr.ecr.us-east-1.amazonaws.com/tech-challenge`)

#### EKS:
- `EKS_CLUSTER_NAME` - Nome do seu cluster EKS

#### Aplicação:
- `DB_PG_NAME` - Nome do banco de dados
- `DB_PG_PORT` - Porta do banco (geralmente 5432)
- `API_KEY` - Chave da API
- `JWT_SECRET` - Secret para JWT

### Parâmetros SSM

O sistema busca automaticamente os seguintes parâmetros do AWS Systems Manager:
- `/main/rds_endpoint` - Endpoint do RDS
- `main/db_username` - Usuário do banco
- `main/db_password` - Senha do banco

## Como funciona o Deploy

1. **Build e Push**: O CI faz build da imagem Docker e push para o ECR com tag `latest`
2. **Deploy**: Após o push bem-sucedido, o sistema:
   - Conecta no cluster EKS
   - Busca credenciais do banco no SSM
   - Atualiza os manifests Kubernetes com as configurações corretas
   - Aplica os recursos usando Kustomize
   - Aguarda o rollout completar

## Deploy Manual

Se precisar fazer deploy manual:

```bash
# Configurar AWS CLI e kubectl
aws eks update-kubeconfig --region us-east-1 --name SEU_CLUSTER_NAME

# Navegar para o overlay de produção
cd k8s/overlays/production

# Atualizar kustomization.yaml com sua URL do ECR
sed -i "s|YOUR_ECR_REPOSITORY_URL_HERE|SUA_URL_ECR|g" kustomization.yaml

# Aplicar os recursos
kustomize build . | kubectl apply -f -

# Verificar status
kubectl rollout status deployment/tech-challenge-app
```

## Recursos da Aplicação

- **Replicas**: 2 pods em produção
- **Resources**: 
  - Request: 512Mi RAM, 500m CPU
  - Limit: 1Gi RAM, 1000m CPU
- **Health Checks**: Liveness e Readiness probes na rota `/health`
- **Port**: 3000 (interno), exposto via Service na porta 80

## Configurações de Ambiente

### ConfigMap (configurações não-sensíveis):
- `NODE_ENV=production`
- `DB_PG_PORT=5432`
- `DB_PG_NAME=postgres`
- `DB_PG_LOGGING=false`
- `JWT_ACCESS_TOKEN_EXPIRATION_TIME=1h`
- `JWT_REFRESH_TOKEN_EXPIRATION_TIME=86400`

### Secret (dados sensíveis):
- `DB_PG_HOST` - Endpoint do RDS
- `DB_PG_USER` - Usuário do banco
- `DB_PG_PASSWORD` - Senha do banco  
- `API_KEY` - Chave da API
- `JWT_SECRET` - Secret JWT

## Auto Scaling (HPA)

### Configuração do HPA:
- **Min Replicas**: 2 pods (sempre disponível)
- **Max Replicas**: 8 pods (máximo para evitar custos excessivos)
- **CPU Target**: 70% (scale up quando CPU média > 70%)
- **Memory Target**: 80% (scale up quando memória média > 80%)

### Comportamento de Scaling:
- **Scale Up**: Até 100% mais pods a cada 60s (máximo 2 pods por vez)
- **Scale Down**: Máximo 50% menos pods a cada 60s (com estabilização de 5min)

### Monitorar HPA:
```bash
# Ver status do HPA
kubectl get hpa -n tech-challenge

# Detalhes do HPA
kubectl describe hpa tech-challenge-app-hpa -n tech-challenge

# Ver métricas em tempo real
kubectl top pods -n tech-challenge
```

## Troubleshooting

### Verificar status dos pods:
```bash
kubectl get pods -l app=tech-challenge
```

### Ver logs da aplicação:
```bash
kubectl logs -l app=tech-challenge -f
```

### Verificar eventos:
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Verificar configurações:
```bash
kubectl describe configmap tech-challenge-config
kubectl describe secret tech-challenge-secrets
```

## Atualizações

Para fazer uma nova versão da aplicação:
1. Faça push das alterações para a branch `main`
2. O CI automaticamente fará build da nova imagem com tag `latest`
3. O deploy será executado automaticamente
4. Os pods serão atualizados com rolling update (zero downtime)

A tag `latest` garante que sempre que uma nova imagem for enviada ao ECR, o próximo deploy usará a versão mais recente.
