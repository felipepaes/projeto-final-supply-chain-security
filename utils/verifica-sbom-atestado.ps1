$sbomPath = ".\security\artifacts\sbom.cdx.json"
$attestationPath = ".\security\artifacts\verified-attestation.json"
$imageName = "ghcr.io/felipepaes/projeto-final-supply-chain-security"
$identity = "https://github.com/felipepaes/projeto-final-supply-chain-security/.github/workflows/supply-chain.yml@refs/heads/main"
$issuer = "https://token.actions.githubusercontent.com"

$digest = python -c "import json,sys; print(json.load(open(sys.argv[1], encoding='utf-8-sig'))['metadata']['component']['version'])" $sbomPath
if ($LASTEXITCODE -ne 0) { throw "Não foi possível ler o digest do SBOM." }
if ($digest -notmatch '^sha256:[0-9a-f]{64}$') { throw "Digest inválido no SBOM: $digest" }

$image = "${imageName}@${digest}"
Write-Host "Verificando imagem: $image"

cosign verify --certificate-identity $identity --certificate-oidc-issuer $issuer $image
if ($LASTEXITCODE -ne 0) { throw "Falha ao verificar a assinatura da imagem." }

cosign verify-attestation --type cyclonedx --certificate-identity $identity --certificate-oidc-issuer $issuer $image > $attestationPath
if ($LASTEXITCODE -ne 0) { throw "Falha ao verificar o atestado CycloneDX." }

@'
import base64
import json
import sys
from pathlib import Path

sbom_path, attestation_path, expected_digest = sys.argv[1:4]

def read_text(path):
    data = Path(path).read_bytes()
    if data.startswith((b"\xff\xfe", b"\xfe\xff")):
        return data.decode("utf-16")
    if data.startswith(b"\xef\xbb\xbf"):
        return data.decode("utf-8-sig")
    return data.decode("utf-8")

def parse_json_after_cosign_output(text):
    decoder = json.JSONDecoder()
    for index, char in enumerate(text):
        if char not in "[{":
            continue
        try:
            value, _ = decoder.raw_decode(text[index:])
            if isinstance(value, (dict, list)):
                return value
        except json.JSONDecodeError:
            pass
    raise ValueError("Não encontrei o JSON do atestado na saída do Cosign.")

def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)

sbom = json.loads(read_text(sbom_path))
records = parse_json_after_cosign_output(read_text(attestation_path))
if not isinstance(records, list):
    records = [records]

for record in records:
    statement = json.loads(base64.b64decode(record["payload"], validate=True))

    subject_matches = any(
        subject.get("digest", {}).get("sha256") == expected_digest.removeprefix("sha256:")
        for subject in statement.get("subject", [])
    )
    if (
        statement.get("predicateType") == "https://cyclonedx.org/bom"
        and subject_matches
        and canonical(statement.get("predicate")) == canonical(sbom)
    ):
        print("OK: o SBOM local corresponde exatamente ao atestado verificado para este digest.")
        Path(attestation_path).unlink(missing_ok=True)
        raise SystemExit(0)

raise SystemExit("FALHA: nenhum atestado verificado corresponde exatamente ao SBOM local.")
'@ | python - $sbomPath $attestationPath $digest

if ($LASTEXITCODE -ne 0) { throw "A comparação do SBOM com o atestado falhou." }