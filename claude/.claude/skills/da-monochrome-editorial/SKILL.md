---
name: da-monochrome-editorial
description: "Use when building or restyling a website with a monochrome editorial art direction — one saturated flat color + one paper, high-contrast display serif against monospace, 1-bit dithered imagery. A grammar to compose with, not a template to reproduce. Triggers: 'DA Hermes', 'DA Nous Research', 'style Blasphemous web', 'monochrome éditorial', 'duotone dithering', 'bichromie', 'DA brutaliste éditoriale', 'poster d'expo en web', 'je veux un site qui ressemble pas à un SaaS'."
---

# DA monochrome éditoriale

Une grammaire, pas un gabarit. Référence d'origine : `hermes-agent.nousresearch.com`. Mais reproduire cette page, c'est produire un plagiat reconnaissable au premier coup d'œil — le but est d'écrire une DA *du même sang*, jamais la même page.

Deux temps obligatoires : le noyau (invariant, sinon ce n'est plus cette DA) puis le parti pris (à réinventer à chaque projet, avant d'écrire une ligne de code).

## Le noyau — quatre règles, rien de plus

1. **Deux valeurs, jamais trois.** Un aplat saturé, un papier. Aucun gris intermédiaire, aucune couleur secondaire, aucun accent de succès ou d'erreur. La profondeur se fabrique par inversion, jamais par ombre. Corollaire : `--radius: 0`, aucun `box-shadow`, aucun dégradé.
2. **Deux familles typographiques opposées.** Une à très fort contraste de graisse pour le display, une machine pour tout le reste. C'est l'écart entre les deux qui porte la DA — pas leur identité.
3. **Toute image passe par une trame 1-bit.** Photo, gravure, rendu, capture : réduite à deux valeurs par dithering ou halftone. Une image en niveaux de gris ou en couleur casse le système instantanément.
4. **Un geste d'échelle qui déborde.** Quelque part dans la page, un élément est trop grand pour son cadre et se fait couper par un bord. Un seul.

Tout ce qui suit est ouvert.

## Le parti pris — à décider avant de coder

Écrire trois lignes explicites (couleur / typo / composition) et les justifier par le sujet, pas par la référence. Le sujet dicte : un outil de finance et un label de musique ne tirent pas le même endroit de cet espace.

**L'aplat.** Saturation maximale, luminance moyenne-basse. Vermillon `#E5140A`, IKB `#1400FF`, cyan `#00A6E0`, vert bouteille `#0A5B3C`, magenta `#D6008C`, jaune de sécurité `#F2C200` (papier devient encre : texte noir sur jaune), noir d'encre sur papier écru. Le papier n'est pas forcément blanc : ivoire, gris ciment, bleu pâle de papier carbone.
Refuser toute couleur pastel ou désaturée : elle transforme la DA en template.

**La trame.** C'est là que se joue le caractère, et chaque trame raconte autre chose :
Floyd–Steinberg (grain organique, photo d'archive) · Bayer ordonné (rigueur mécanique, informatique) · lignes de scanline (télévision, surveillance) · halftone à points rotatifs (presse, sérigraphie) · hachures croisées (gravure, taille-douce) · seuil dur sans trame (affiche politique, pochoir).
Choisir *une* trame et s'y tenir sur toute la page.

**Le registre iconographique.** Ne pas reprendre par défaut l'ésotérisme gravure — c'est la signature d'Hermes, pas la DA. L'espace est large : planche botanique, schéma d'ingénierie, imagerie médicale, photo de presse, cartographie, sculpture antique, macro textile, capture satellite, diagramme de brevet. Le registre doit venir du sujet du site.

**La composition — à dériver du sujet, jamais à choisir dans un catalogue.**
Le rythme d'Hermes (nav trois colonnes → hero → capture → six features numérotées → wordmark → footer) est *son* rythme, et le rythme hero/features/témoignages/CTA est celui de n'importe quel SaaS. Les deux sont disqualifiés d'office.

Procédé, dans l'ordre :

1. **Nommer l'objet-source.** Quel artefact physique le sujet manipule-t-il déjà ? Un livre annoté, un bordereau de douane, une partition, un plan cadastral, une fiche d'herbier, un registre de pharmacie, une carte de vol, un chemin de fer d'imprimeur, un journal de bord, une planche contact. Un seul, et il doit être vrai du métier — pas une métaphore décorative.
2. **En tirer trois conséquences structurelles**, et les écrire noir sur blanc avant de coder :
   - *l'unité de découpe* — ce que l'objet répète (une entrée, une mesure, une parcelle, une prise de vue) devient le module de la page ;
   - *le sens de lecture* — vertical continu, tabulaire, en double page, en spirale, de droite à gauche, par colonne de glose ;
   - *le dispositif d'index* — comment l'objet se repère (cote, date, coordonnée, numéro de mesure, poids, indice de vue) ; c'est lui qui remplace les étiquettes décoratives, et il ne s'invente pas.
3. **Faire porter au layout une information vraie.** Si la page range ses blocs par ordre chronologique, par densité ou par échelle, ce classement doit être celui du sujet, pas un habillage.
4. **Placer le geste d'échelle là où l'objet-source le justifie** : le grand format tombe sur ce qui compte dans cet objet, pas systématiquement sur le wordmark en pied de page.

**Test de singularité, avant de coder.** Retirer mentalement tout le contenu et ne garder que le squelette : est-ce qu'on devine encore de quel projet il s'agit ? Si le squelette pourrait accueillir n'importe quel autre client, il est générique — recommencer à l'étape 1. Deuxième contrôle : ce layout, l'aurais-je produit pour le projet précédent ? Si oui, ce n'est pas une DA, c'est un gabarit.

Deux projets sous cette DA ne doivent donc pas se ressembler structurellement. Seuls le noyau et le parti chromatique les rattachent à la même famille.

**Le rôle de la typo.** Le display peut porter le titre, ou au contraire être réservé aux chiffres, aux citations, à un unique wordmark, laissant la mono tenir toute la page. Une DA plus radicale supprime le display et joue mono seule à cinq échelles.

**Le choix du display — contraste, pas fragilité.** Le contraste de graisse ne doit jamais se payer en déliés qui disparaissent à l'écran. Les didones pures (Bodoni Moda, Didot) cassent : leurs traits fins s'effacent au rendu, et la page devient illisible dès qu'un titre descend sous 2 rem.

- **Défaut de la maison : Fraunces** (variable, axes `opsz` / `WONK` / `SOFT`). Contraste franc, fûts pleins, un caractère de vieille casse qui tient jusqu'en corps 1,5 rem. `WONK=1` pour les formes anguleuses. Chargée en 500-800, jamais en 400, et toujours `font-optical-sizing: auto`.
- Autres pistes tenables si le sujet l'exige : Instrument Serif, Newsreader, DM Serif Display, Redaction. Une grotesque très grasse (Archivo Black) fonctionne aussi quand le sujet refuse le serif.
- Règle de contrôle : baisser le display à sa plus petite occurrence de la page et vérifier que le trait le plus fin est encore franchement visible. S'il vibre ou disparaît, la face est disqualifiée — changer de face, pas monter la taille.

L'interdit du bold sur le display porte sur les didones fines, pas sur une variable robuste : Fraunces en 700-800 sur le geste d'échelle est le bon usage.

**La numérotation et les étiquettes.** `#1 CONNECT` sous une étiquette mono, c'est le tic d'Hermes. N'utiliser un dispositif structurel (numéro, dates, cotes d'archive, coordonnées, versions, poids en grammes) que s'il encode une information vraie du sujet. Sinon, rien.

**Le mouvement.** Options : inversion de palette au scroll · trame qui se recompose à l'entrée · défilement horizontal d'un bandeau · rien du tout (souvent le plus fort). Jamais de parallaxe molle ni de spring.

## Ne pas cloner

Si la page reprend en même temps le bleu IKB, la gravure ésotérique, l'étiquette mono numérotée et le wordmark géant en bas, c'est un copier-coller. En reprendre un seul, choisi, c'est une citation.

## Fabrication

- `scripts/dither.sh <image> <hex>` : duotone + trame ordonnée via ImageMagick.
- Sans fichier image disponible (contexte Artifact, CSP), générer un champ de luminance en canvas (fbm, rayons, hachures) puis appliquer le seuil de trame en `ImageData` — deux couleurs en sortie, même grain.
- CSS : `--ink` / `--paper` / `--bg` / `--fg`, l'inversion se fait par une classe de section qui échange les deux. Tout le reste hérite.
- Tailwind/shadcn : l'aplat et le papier vivent dans le thème global (`--primary`, `--background`, `--foreground`, `--radius: 0`), jamais au point d'appel. Les primitives shadcn restent la base, re-skinnées par variables et variantes `cva`.

## Anti-patterns

Un gris de plus, une couleur d'accent secondaire, `border-radius`, ombre, dégradé, glassmorphism, une sans-serif d'interface qui s'infiltre dans la nav ou les boutons, une image non tramée, une photo de stock, une didone à déliés fantômes, un display en corps trop petit pour sa graisse, une section de lecture longue posée sur l'aplat, un hero saturé pleine hauteur.

## Lisibilité — la DA ne dispense de rien

C'est le point de rupture le plus fréquent : la DA reste lisible ou elle ne sert à rien.

- **Capitales : étiquettes et titres seulement.** Jamais un paragraphe, jamais une phrase de plus d'une ligne. Le corps est en casse normale.
- **Interlettrage inversement proportionnel à la longueur** : `0.14em` sur une étiquette de trois mots, `0.02em` maximum sur du texte courant.
- **Corps à 15px minimum en mono**, `line-height` 1.7–1.8, mesure de 55 à 65 caractères. Une mono paraît plus petite qu'une sans-serif à taille égale.
- **Sur l'aplat saturé, monter d'un demi-gras** (400 → 500) : le texte clair sur fond saturé s'amincit optiquement. Inutile dans le sens inversé.
- **L'aplat est un accent, jamais un fond de lecture.** C'est le point de rupture le plus fréquent de cette DA sur les pages longues : une couleur saturée en plein écran fatigue physiquement, et l'inversion perd tout effet à force d'être répétée. Règles chiffrées, à vérifier avant de publier :
  - **L'aplat plafonne à ~15 % de la hauteur totale de la page.** Mesurer, ne pas estimer : `let r=0; document.querySelectorAll('.inv').forEach(e=>r+=e.getBoundingClientRect().height); r/document.documentElement.scrollHeight`.
  - **Trois surfaces inversées au maximum sur une page**, quelle que soit sa longueur : l'ouverture, une planche d'images ou un bandeau au milieu, la clôture.
  - **Jamais plus de deux paragraphes d'affilée sur l'aplat.** Une section qui contient un tableau, une liste de features ou plusieurs sous-titres est une zone de lecture : elle va sur le papier, point.
  - Sur une page très longue, l'ouverture elle-même se comprime : un hero pleine hauteur en aplat saturé est déjà trop.
- **Rythmer sans inverser.** Pour signaler une section forte sans aplat, rester dans les deux valeurs : filet supérieur épaissi (3 px), encadré 1 px, cote en demi-gras, geste d'échelle. L'inversion n'est pas le seul outil de hiérarchie, c'est seulement le plus bruyant.
- **Une texture de fond derrière du texte plafonne à ~25 % d'opacité**, sinon la trame mange les contreformes.
- Vérifier le contraste dans les deux sens de l'inversion, prévoir `prefers-reduced-motion`, garder un `:focus-visible` net — la bordure 1px de la DA s'y prête.
