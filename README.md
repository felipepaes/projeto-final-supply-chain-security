# Projeto Final DevSecOps Policy as Code, SBOM e Supply Chain Security

Checklist binário de 5 itens, sem rubrica de 0–100:
- [x] Escreveu e testou a policy Rego.
- [x] Gerou o SBOM.
- [x] Encontrou e registrou 1 vulnerabilidade real.
- [x] Assinou/verificou com Cosign.
- [x] Conectou o exercício com um caso real de ataque à cadeia de suprimentos.

## Pipeline de supply chain

O workflow `.github/workflows/supply-chain.yml` executa os testes em pull requests e
pushes para `main`. Em pushes, também constrói a imagem de produção, publica uma
tag SHA no GHCR, gera um SBOM CycloneDX com Syft, assina a imagem pelo digest com
Cosign keyless, anexa o SBOM como attestation e verifica ambos. O passo de scan
Trivy está atualmente comentado no workflow.

O workflow usa `GITHUB_TOKEN` e OIDC do GitHub Actions; não é necessário criar uma
API key. Os relatórios são publicados como artefato da execução. Habilite Actions
no repositório e permita que o `GITHUB_TOKEN` leia e publique packages.
Após a verificação do atestado, o workflow atualiza
`security/artifacts/sbom.cdx.json` no branch `main` quando o conteúdo mudar. Para
isso, o job precisa de permissão `contents: write`. Esse push com `GITHUB_TOKEN`
não dispara outra execução do workflow.

## Caso real: backdoor no XZ Utils (CVE-2024-3094)

Em 2024, versões comprometidas do XZ Utils (5.6.0 e 5.6.1) incluíram um
backdoor que podia interferir na autenticação SSH em determinadas distribuições
Linux. O caso demonstra como uma dependência aparentemente legítima pode se
tornar um vetor de ataque antes de chegar ao artefato distribuído.
[CVE-2024-3094](https://www.cve.org/CVERecord?id=CVE-2024-3094)

### Mapa de ameaças: pontos de entrada e controles

| Onde o atacante entra | Controle deste projeto | O que bloqueia ou evidencia — e limite |
|---|---|---|
| Dependência comprometida chega à imagem (como no XZ) | Syft gera o SBOM; Trivy pode detectar versões com vulnerabilidades conhecidas | O SBOM facilita localizar imagens afetadas. O scan não detecta necessariamente um backdoor ainda desconhecido. |
| Imagem é substituída após a publicação | Cosign assina e verifica imagem e atestado pelo digest | Com verificação obrigatória e identidade restrita à Action, só se aceita imagem assinada pelo workflow; o digest vincula a assinatura ao conteúdo exato e evidencia/rejeita uma troca. Isso confirma que a imagem passou pelos gates configurados (como os testes), mas não que o build seja benigno ou que a pipeline não tenha sido comprometida. |
| Dockerfile usa base não aprovada ou executa como root | Policy Rego exige base allowlisted e usuário não-root | Pode bloquear essas violações quando executada como gate antes do build; não identifica código malicioso dentro de uma base aprovada. |

No caso do XZ, SBOM e scan ajudariam principalmente a encontrar versões afetadas
após a vulnerabilidade ser conhecida. A diferença entre o tarball e o código
revisado exigiria controles adicionais de proveniência e build reproduzível.

# Resultado Scan de Vulnerabilidades

<img width="1849" height="797" alt="image" src="https://github.com/user-attachments/assets/efb4c13a-7073-42d2-968b-ca89271f3c70" />
