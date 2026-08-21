# Restack Changelog

## 2026-08-21

**Housekeeping**
- Added `CHANGELOG.md` (this file) — restack-specific history, separate from homelab gitops changelog
- UUID check: all three hardware-configuration.nix files have unique UUIDs; verify against live disks next time VMs are running

**feat/ferretdb branch**
- Created `feat/ferretdb` branch — FerretDB module (Apache-2.0, MongoDB wire protocol over PostgreSQL)
- `modules/ferretdb/default.nix` — FerretDB systemd service on port 27017, PostgreSQL backend via `ensureDatabases`/`ensureUsers`; enabled in org profile on this branch
- PyMongo code unchanged — point connection at `mongodb://localhost:27017`
- `mongodb-ha-working` tag preserved for Helpintrip MongoDB fallback

## 2026-08-19

**Docker, document extractor, DR modules**
- `modules/docker` — `virtualisation.docker.enable = true`, autoPrune, nixos user added to docker group; enabled in org profile
- `modules/document-extractor` — Apache Tika server as systemd service on port 8080, DynamicUser
- `modules/dr` — replaced MongoDB backup with `pg_dumpall | restic backup --stdin`; added `passwordFile` option (default `/etc/restack/restic-password`); restore check verifies CREATE TABLE count from latest snapshot; `Persistent = true` on timers
- Confirmed Alessandro only needs 1 NixOS VM on Proxmox (personal profile); 3-node HA is midir demo only

## 2026-08-18

**HA module: PostgreSQL streaming replication**
- Deployed flake profiles to all 3 nodes
- MongoDB removed (SSPL licence); tagged `mongodb-ha-working` for Helpintrip use
- PostgreSQL 16 streaming replication: nix-node-2 PRIMARY, nix-node-3 SECONDARY
- `postgresql-replica-init.service` bootstraps replica via `pg_basebackup -R` on first boot
- Failover tested: promoted nix-node-3, confirmed `pg_is_in_recovery() = f`; topology restored

## 2026-08-16

**All three NixOS nodes up**
- Fixed nix-node-1 UEFI boot (OVMF_CODE.4m.fd loader via VM XML edit)
- Applied static IPs: nix-node-1=.100, nix-node-2=.101, nix-node-3=.102 (192.168.122.x/24)
- Created `libvirt-forward.service` on midir to persist iptables FORWARD rules for the VM subnet
- All three `hardware-configuration.nix` files committed; all nodes SSH accessible

## 2026-08-15

**Initial setup**
- Repo created: `github.com/t12-pybash/restack` (AGPL-3.0, REUSE compliant)
- NixOS flake skeleton committed: 2 profiles (personal, organisational), 4 modules (base, ha, dr, document-extractor), 3 host stubs
- nix-node-1 VM spun up (4 vCPU / 6GB RAM / 20GB disk) via KVM/libvirt on midir
- NixOS 25.05 installed; UEFI boot issue identified and fixed in next session
