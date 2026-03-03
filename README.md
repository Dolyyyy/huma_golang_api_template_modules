# Huma Golang API Template Modules

This repository stores installable modules consumed by `templatectl`.

## Related Repositories

- Modules repo (this project): [Dolyyyy/huma_golang_api_template_modules](https://github.com/Dolyyyy/huma_golang_api_template_modules)
- Base template repo: [Dolyyyy/huma_golang_api_template](https://github.com/Dolyyyy/huma_golang_api_template)

## Goenv Installer

This repository ships a reusable installer script:

- `scripts/goenv_install.sh`

Install `goenv` with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/Dolyyyy/huma_golang_api_template_modules/main/scripts/goenv_install.sh | bash
```

Then install and select a Go version:

```bash
goenv install 1.26.0
goenv global 1.26.0
go version
```

Optional per-project pin:

```bash
goenv local 1.26.0
```

## Layout

The repository includes:

- `modules.json`: global index used by `templatectl list` (remote listing without clone)
- `scripts/goenv_install.sh`: one-command installer for `goenv`
- `modules/<id>/module.json`: full module manifest used for installation
- template files referenced by each module manifest (usually under `files/`)

Each installable module must live under `modules/<id>/`.

Current modules:

- `auth-jwt`
- `auth-token`
- `cors`
- `http-timeout`
- `mail-smtp`
- `metrics-prometheus`
- `rate-limit`
- `request-id`
- `scheduler-cron`
- `secure-headers`
- `db-postgres`
- `db-sqlite`
- `db-mariadb`

## Manifest Schema (v1)

```json
{
  "id": "auth-token",
  "name": "API token auth",
  "description": "Protect API routes with a static token.",
  "package": "internal/modules/auth_token",
  "defaults": {
    "AUTH_TOKEN": "change-me"
  },
  "cleanup_env_keys": ["AUTH_TOKEN"],
  "files": [
    {
      "source": "files/module.go.tmpl",
      "destination": "internal/modules/auth_token/module.go"
    }
  ]
}
```

Template variables available in file templates:

- `ProjectModulePath`: target project module path from `go.mod`
