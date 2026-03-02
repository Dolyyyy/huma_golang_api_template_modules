# Huma Golang API Template Modules

This repository stores installable modules consumed by `templatectl`.

## Layout

Each module must live under `modules/<id>/` and include:

- `module.json`: module metadata used by `templatectl`
- template files referenced by `module.json` (usually under `files/`)

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
