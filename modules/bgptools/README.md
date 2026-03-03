# bgptools module

This module downloads BGP.tools datasets into disk cache and serves IP/ASN lookups.

## Endpoints

- `GET /bgptools/health`
- `GET /bgptools/ip?ip=1.1.1.1,8.8.8.8`
- `POST /bgptools/ip` with body `{"ips":["1.1.1.1","8.8.8.8"]}`
- `GET /bgptools/asn?asn=13335,15169`
- `GET /bgptools/asns` (optional `q`, `tag`, `exclude_unknown`, `offset`, `limit` query params)
- `GET /bgptools/asn/{asn}`
- `GET /bgptools/asn/{asn}/prefixes` (optional `offset`, `limit`)
- `POST /bgptools/asn` with body `{"asns":[13335,15169]}`
- `POST /bgptools/reload`

## Behavior

- Loads prefixes + ASN metadata into RAM for fast lookups.
- Uses disk cache under `cache/bgptools/`.
- Auto-updates cache in the background.
- Falls back to existing cache file if remote download fails.
- Marks private/non-routable ranges as local.

## Environment Variables

- `BGPTOOLS_TABLE_URL` (default: `https://bgp.tools/table.jsonl`)
- `BGPTOOLS_ASNS_URL` (default: `https://bgp.tools/asns.csv`)
- `BGPTOOLS_CACHE_DIR` (default: `cache/bgptools`)
- `BGPTOOLS_TABLE_MAX_AGE` (default: `30m`)
- `BGPTOOLS_ASNS_MAX_AGE` (default: `24h`)
- `BGPTOOLS_UPDATE_INTERVAL` (default: `1h`)
- `BGPTOOLS_HTTP_TIMEOUT` (default: `5m`)
- `BGPTOOLS_USER_AGENT` (default: `huma-golang-api-template/bgptools`)
- `BGPTOOLS_PRELOAD` (default: `false`)
- `BGPTOOLS_MAX_BATCH` (default: `256`)

## Notes

- Cache ignore is auto-installed at `cache/bgptools/.gitignore`.
- To preload dataset at app startup, set `BGPTOOLS_PRELOAD=true`.
