# Projeto Final DevSecOps Policy as Code, SBOM e Supply Chain Security

Checklist binário de 5 itens, sem rubrica de 0–100:
- [x] Escreveu e testou a policy Rego.
- [x] Gerou o SBOM.
- [x] Encontrou e registrou 1 vulnerabilidade real.
- [x] Assinou/verificou com Cosign.
- [] Conectou o exercício com um caso real de ataque à cadeia de suprimentos.

## Pipeline de supply chain

O workflow `.github/workflows/supply-chain.yml` executa os testes em pull requests e
pushes para `main`. Em pushes, também constrói a imagem de produção, publica uma
tag SHA no GHCR, gera um SBOM CycloneDX com Syft e falha o job se o Trivy encontrar
vulnerabilidades HIGH ou CRITICAL. Se o scan passar, assina a imagem pelo digest
com Cosign keyless, anexa o SBOM como attestation e verifica ambos.

O workflow usa `GITHUB_TOKEN` e OIDC do GitHub Actions; não é necessário criar uma
API key. Os relatórios são publicados como artefato da execução. Habilite Actions
no repositório e permita que o `GITHUB_TOKEN` leia e publique packages.
Após a verificação do atestado, o workflow atualiza
`security/artifacts/sbom.cdx.json` no branch `main` quando o conteúdo mudar. Para
isso, o job precisa de permissão `contents: write`. Esse push com `GITHUB_TOKEN`
não dispara outra execução do workflow.
