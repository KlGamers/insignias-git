# Insignias-Git

Repo privado para generar actividad que desbloquee insignias de GitHub.

## Cómo ejecutarlo

```bash
brew install gh
gh auth login          # GitHub.com, HTTPS, navegador
./run-badges.sh        # PRS=16 ./run-badges.sh para Pull Shark plata
```

## Qué insignias cubre

| Insignia | Cómo |
|---|---|
| Pull Shark | PRs propios fusionados (2 bronce, 16 plata, 128 oro) |
| YOLO | Fusionar un PR sin revisión (los PRs del script) |
| Quickdraw | Issue abierto y cerrado en menos de 5 min |
| Heart On Your Sleeve | Reacciones en issues |
| Pair Extraordinaire | Commit con `Co-Authored-By` fusionado vía PR (ver nota) |

## Qué NO se puede conseguir solo

Starstruck (estrellas de otros), Galaxy Brain (respuestas aceptadas de otros en
Discussions), Public Sponsor (patrocinar de verdad), Open Sourcer (PR fusionado
en repos públicos ajenos), Arctic Code Vault y Mars 2020 (históricas, ya cerradas).

## Notas

- **Repo privado:** las contribuciones privadas solo cuentan en el perfil si
  activas *Perfil → Contribution settings → Include private contributions*.
  Algunas insignias pueden no contar desde un repo privado; si no aparecen,
  haz público el repo.
- **Pair Extraordinaire:** el co-autor debe ser un usuario real de GitHub con su
  email asociado. `noreply@anthropic.com` no es una cuenta de GitHub, así que
  probablemente no cuente. Usa `CO_AUTHOR="Otro <id+usuario@users.noreply.github.com>"`
  con una segunda cuenta tuya.
- Las insignias tardan de minutos a horas en aparecer.
