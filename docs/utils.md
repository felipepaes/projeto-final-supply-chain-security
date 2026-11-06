# Utils

```shell
conftest parse --parser dockerfile .\docker\Dockerfile > .\security\inputs\ok.dockerfile.json

conftest test --policy .\security\policies\docker --namespace docker --parser dockerfile .\docker\Dockerfile

opa test .\security\policies\docker -v

opa eval --data .\security\policies\docker --input .\security\inputs\insecure.dockerfile.json "data.security.policies.docker.deny"

conftest test --policy .\security\policies\docker --namespace docker --parser dockerfile .\security\inputs\Dockerfile.defeito

 podman run -t --rm -p 8000:8000 localhost/python-api-test

 podman run -t --rm -p 8000:8000 ghcr.io/felipepaes/projeto-final-supply-chain-security@digest
```