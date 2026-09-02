---
name: portfolio-malt
description: "Use when writing, auditing or restructuring a Malt portfolio case study, or optimizing a Malt profile (titre, TJM, compétences, expériences). Triggers: 'portfolio Malt', 'étude de cas Malt', 'projet Malt', 'remplir mon portfolio', 'mes réalisations Malt', 'auditer mon profil Malt', 'image de couverture portfolio', 'Malt inspiration'."
---

# Portfolio et profil Malt

Normes mesurées en août 2026 sur **l'intégralité des 64 items** de la galerie d'inspiration officielle, extraits via l'API `/profile/api/profiles/portfolios/{id}` (session authentifiée requise). Ce n'est pas un échantillon : c'est le corpus complet. Les chiffres marqués « tiers » viennent d'analyses non officielles de l'algorithme.

## Ce que le lecteur fait vraiment

Un client compare plusieurs freelances : **6 à 30 secondes** pour décider de continuer, et 80 % passent moins de 3 minutes sur un portfolio entier. Au-delà de 300 mots, la fiche est fermée avant d'être jugée.

## La pratique observée, par catégorie Malt

| | Étude de cas (15) | Exemple de création (30) | Offre de service (15) |
|---|---|---|---|
| Corps médian | **138 mots** (13-443) | 82 mots | 94 mots |
| Images | 1 | 2 | 1 |
| Titres H2 | 2 | 1 | 1 |
| Puces | 4 | 0 | 0 |
| Avec témoignage | 40 % | 17 % | 13 % |
| Avec chiffres | **80 %** | 37 % | 60 % |
| Sans aucun H2 | 13 % | 40 % | 20 % |

Sur les 64 items : corps médian 105 mots, quartiles 48 et 198, et **20 % n'ont quasiment aucun texte**.

Deux enseignements contre-intuitifs :

- **Une seule image médiane**, pas une galerie. Une couverture soignée suffit ; empiler les captures n'est pas la norme et n'apporte rien.
- **80 % des études de cas portent un chiffre.** C'est le standard, pas le différenciateur. Sans chiffre, une fiche décroche par rapport au lot.

Le vrai différenciateur reste le témoignage : 60 % des études de cas n'en ont aucun.

Attention au contresens : ces chiffres décrivent ce que les gens **font**. Viser 130-220 mots, dans le haut de la pratique sans excès.

## Le squelette

```
TITRE           Client — Mission (Année)
IMAGE HERO      composée, jamais une capture brute
INTRO           25-40 mots, 2-3 phrases
## Contexte     30-60 mots
## Réalisations clés    4-6 puces de 10-15 mots
## Stack technique      une seule ligne
## Témoignage client    30-50 mots + attribution
```

L'éditeur Malt accepte de vrais H2. Ne pas se limiter aux blocs du menu `/` (Image, Video, Divider, Table, Quote) : les titres se tapent directement.

## Section par section

### Titre

`Client — Mission (Année)`. Le lecteur doit savoir en trois secondes de quoi il s'agit.

- Bon : `Acme Capital — Refonte FinTech (2024)`, `Medscan — Pipeline DICOM & IA médicale`
- Sous NDA : `Billetterie événementielle — Dashboard temps réel (NDA)`
- Mauvais : `Process Architecture & Workflow Optimization` (aucun client, aucun contexte)

Un chiffre dans le titre accroche : `ResellStats, side project +100€ MRR`.

### Intro (25-40 mots)

Deux phrases. Rôle, client et secteur, puis la mission et son angle distinctif.

Ouvertures relevées dans la galerie :
- `CTO & Architecte sur [client], plateforme [secteur].`
- `Mission freelance chez [client] ([domaine], [ville]) au sein d'une équipe de N personnes.`
- `[Client] est un [type d'organisation] spécialisé dans [domaine].`

Ne jamais ouvrir sur une liste de technologies. Le client achète une solution à son problème.

### Contexte (30-60 mots)

Le problème métier tel que le client le vivait. Construction efficace : `Le projet partait d'un constat assez simple : [symptôme visible par le client].`

### Réalisations clés (4-6 puces de 10-15 mots)

73 % des études de cas utilisent des puces, médiane de 4.

Une puce = une action, avec une technologie ou un chiffre. Pas de phrase complète, pas de point final.

> - 57 applications de destination résolues en deep link natif
> - Refonte d'un système legacy monolithique en 14 microservices
> - 5+ déploiements en production par semaine

Au moins une puce chiffrée : 80 % des études de cas en ont une, c'est le standard attendu.

### Stack technique (une ligne)

Liste séparée par des virgules. **Pas de tableau** : Malt affiche déjà les compétences en tags sous l'article.

### Témoignage client (30-50 mots)

Citation puis `— Prénom, Société · Source ★★★★★`. Seules 40 % des études de cas en ont un : c'est le levier de différenciation le plus fort et le moins cher. Si un avis Malt existe pour cette mission, le recopier ici, le lecteur ne va pas le chercher ailleurs.

## L'image hero

Les meilleurs items n'utilisent jamais de capture brute. Composition qui fonctionne : fond clair, titre incrusté, capture encadrée avec ombre, badges de compétences avec puce colorée.

`make-hero.sh` (fourni) compose ce format. Reprendre les couleurs du projet présenté, pas une palette générique.

La médiane est d'**une seule image** par item : soigne la couverture plutôt que d'empiler les captures. Chaque image ajoutée porte une légende qui **explique une décision**, elle ne décrit pas la capture.

## Les champs Malt

- **Catégorie** : `CASE_STUDY` (Étude de cas). Sur 64 items, 30 sont en `CREATIVE_SAMPLE`, la catégorie des fiches peu ou pas rédigées : la choisir signale un contenu faible.
- **Tags** : médiane de 4 par item
- **Branche d'activité** : celle du client, pas la tienne
- **Date de début** : le champ existe, l'année dans le titre reste facultative
- **Compétences** : les mots que le client tape dans la recherche

## Le profil autour du portfolio

Le portfolio ne compense pas un profil incomplet. Poids de ranking (source tierce) : pertinence sémantique titre/requête ~25 %, complétude ~15 %, activité récente ~12 %, taux de réponse ~10 %.

Bloquants absolus :
- **TJM absent** : le profil est exclu des recherches filtrées par budget
- **Disponibilité non confirmée** : disparition des résultats
- **Note sous 3,75** : profil pénalisé, à traiter avant tout travail de contenu

Leviers, par ordre d'impact :
1. **Cohérence sémantique** entre titre, cinq premières compétences, description et expériences. Depuis fin 2024, Malt fait de la recherche par intention : un champ dissonant dilue le matching.
2. **Titre** : expertise, spécialité, bénéfice client, dans le vocabulaire des requêtes. Pas « artisan du code ».
3. **Expériences** : présentées par Malt comme le moteur de visibilité depuis avril 2026. Détaillées, avec clients identifiables et résultats chiffrés.
4. **Connexion hebdomadaire** et réponse sous 24 h, même pour décliner.
5. **Avis clients** : ils pèsent plus que tout ce qu'on déclare soi-même. 4,5/5 minimum pour Super Malter.

## Combien de projets

3 à 5 études de cas documentées valent mieux que vingt vignettes. Ordonner par force de preuve : produits vivants avec avis client d'abord, missions courtes ou sous NDA ensuite.

## Checklist

- [ ] Corps dans la cible du métier (compter, ne pas estimer)
- [ ] Titre avec client nommé, ou NDA explicite
- [ ] Intro sans nom de technologie
- [ ] Au moins un chiffre dans les réalisations
- [ ] Stack sur une ligne, pas en tableau
- [ ] Témoignage si un avis client existe
- [ ] Image hero composée, aux couleurs du projet
- [ ] Légendes qui expliquent une décision
- [ ] Catégorie `Étude de cas`
- [ ] Aucun chiffre répété entre l'intro et le résultat

## Anti-patterns mesurés

| Anti-pattern | Coût |
|---|---|
| Bloc de texte sans H2 ni puces | Fermé avant lecture |
| Aucun résultat mesurable | Rien à comparer avec le concurrent |
| Titre sans client | Le lecteur ne sait pas ce qu'il regarde |
| Capture brute | Se noie dans la galerie |
| Plusieurs projets empilés dans un item | Dilue chacun d'eux |
| Reprise verbatim d'une page web | Ton marketing, longueur inadaptée |
| Langue étrangère sur un marché francophone | Perte de matching interne |

## Outillage

`~/DEV/perso/malt-audit` implémente ces règles : 13 règles profil, 14 règles portfolio, scoring et priorisation par sévérité et rareté. `auditerFiche(fiche, metier)` note une fiche, `auditer(profil)` note l'ensemble.

Extraction depuis une URL publique : la page profil répond 200 en `fetch` avec des en-têtes de navigateur complets, et expose le titre, le TJM, les avis, les compétences (JSON-LD) et les expériences (payload `__NUXT_DATA__`). Les items de portfolio viennent d'une API qui exige une session authentifiée.

## Actualiser ces normes

Ne pas visiter les fiches une par une, c'est lent et ça sature le contexte. Ouvrir la galerie dans un navigateur **connecté**, puis en JavaScript :

1. Collecter les identifiants : `document.querySelectorAll('a[href*="portfolio-item"]')`, extraire `/portfolio-item-([a-f0-9]+)/`
2. Pour chacun, `fetch('/profile/api/profiles/portfolios/' + id)` — l'API exige la session, elle renvoie 403 en anonyme
3. `contentBlocks` est un document ProseMirror : aplatir l'arbre par `content`, puis compter les nœuds `heading`, `image`, `listItem`, `blockquote`, `table` et concaténer les nœuds `text`
4. Ne renvoyer que les agrégats, jamais les textes

Les 64 items se traitent en une minute par lots de 8.
