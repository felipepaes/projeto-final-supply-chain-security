# ==============================================================================
# Estágio 1: Builder (Construção e verificação estrita de dependências)
# ==============================================================================
FROM python:3.13.17-slim-bookworm AS builder

# Instala o PDM de forma isolada no estágio de construção
RUN pip install --no-cache-dir pdm "hishel<2.0"

WORKDIR /app

# Copia apenas os arquivos de manifesto e bloqueio para aproveitar o cache do Docker
COPY pyproject.toml pdm.lock ./

# Configura o PDM para criar o ambiente virtual localmente na pasta .venv
RUN pdm config python.use_venv true

# GATE DE SEGURANÇA: Instala apenas dependências de produção.
# O parâmetro --check garante falha imediata caso o pdm.lock esteja dessincronizado
# com o pyproject.toml (garantindo rastreabilidade e integridade da cadeia de suprimentos).
RUN pdm install --prod --no-editable --no-self --check

# Copia o código-fonte da aplicação após a instalação segura das dependências
COPY src/ ./src/


# ==============================================================================
# Estágio 2: Runtime (Imagem final leve e segura para produção)
# ==============================================================================
FROM python:3.13.17-slim-bookworm AS runtime

WORKDIR /app

# SEGURANÇA: Criação de um usuário e grupo não-privilegiados (Non-root).
# Evita que a aplicação rode como root, mitigando riscos de escalação de privilégio em caso de invasão.
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -s /bin/bash -m appuser

# Copia apenas o ambiente virtual (.venv) compilado e o código-fonte do estágio anterior.
# Ferramentas de build (como o PDM) e arquivos intermediários ficam descartados aqui.
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src /app/src

# Configura as variáveis de ambiente para priorizar o ambiente virtual e o caminho dos módulos
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/src"

# Ajusta a propriedade de todos os arquivos da aplicação para o usuário não-privilegiado
RUN chown -R appuser:appuser /app

# Altera o contexto de execução para o usuário restrito
USER appuser

# Expõe a porta padrão da API Litestar
EXPOSE 8000

# Executa o servidor Uvicorn escutando em todas as interfaces de rede do container (0.0.0.0)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
