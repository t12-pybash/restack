# Restack

Reproducible self-hosting infrastructure stack — NixOS flake with personal and organisational deployment profiles.

Built as part of the [NLnet Open Internet Stack / Restack](https://nlnet.nl/openinternet/) grant programme.

## Profiles

| Profile | Target | Scope |
|---|---|---|
| Personal | Individual | Single NixOS node, local data custody, document extractor |
| Organisational | SME / cooperative / non-profit | Multi-node HA, verifiable DR, no specialist required |

## Structure

```
profiles/       deployment profiles (personal, organisational)
modules/        reusable NixOS modules (base, ha, dr, document-extractor)
hosts/          per-host configuration and hardware stubs
docs/           user and operator documentation
```

## Getting started

Requires Nix with flakes enabled.

```bash
nix develop        # enter dev shell
nixos-rebuild switch --flake .#nix-node-1
```

## Licence

Code: [AGPL-3.0-only](LICENSE)
Documentation: [CC-BY-SA-4.0](docs/)

REUSE compliant — see [REUSE.toml](REUSE.toml).
