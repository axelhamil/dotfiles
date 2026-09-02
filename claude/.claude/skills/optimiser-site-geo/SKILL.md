---
name: optimiser-site-geo
description: "Use when auditing or building the technical GEO/SEO infrastructure of a website so it gets cited by ChatGPT, Perplexity, Google AI Overviews and Claude: structured data, entity signals, metadata, crawlability, indexation. Triggers: 'audit SEO/GEO', 'mon site n'est pas cité par les IA', 'schema.org', 'JSON-LD', 'données structurées', 'robots.txt', 'sitemap', 'IndexNow', 'llms.txt', 'AI Overviews', 'GPTBot', 'metadata Next.js', 'pourquoi je ressors pas sur ChatGPT'."
---

# Optimiser un site pour le GEO (citations par les IA)

## Principe

Le SEO classique optimise pour un **ranking** : une position dans une liste de liens. Le GEO optimise pour une **extraction** : est-ce que cette phrase est réutilisable telle quelle dans une réponse générée ? Tout découle de là. Une phrase qui a besoin de son contexte pour être vraie ne sera jamais citée. Un fait sans date, sans chiffre et sans source ne sera jamais repris. Une entité floue ne sera jamais nommée.

Corollaire à garder en tête pendant tout audit : **être premier sur Google ne garantit pas d'être cité par une IA**. Le recouvrement entre les deux jeux de résultats est partiel (~20-25 % selon les analyses 2025-2026). Un site peut très bien ranker et rester invisible dans les réponses génératives, et l'inverse est vrai aussi.

## Périmètre de ce skill

Ce skill couvre **l'infrastructure d'un site** : données structurées, signaux d'entité, métadonnées, crawlabilité, indexation, garde-fous de build.

Il ne couvre PAS la rédaction. Pour le contenu :
- **REQUIRED pour rédiger** : skill `rediger-article-blog-seo-geo` (answer-first, anti-AI-slop, sources, E-E-A-T).
- **REQUIRED pour le maillage** : skill `mailler-articles-blog` (topic cluster, liens internes).

Si la demande porte sur « pourquoi mon article n'est pas cité », le problème est presque toujours dans le contenu, pas dans l'infra. Commencer par ces deux skills.

## Ordre de priorité (ne pas commencer par le bas)

L'erreur classique est d'attaquer par `llms.txt` parce que c'est visible et rapide, alors que son effet est non prouvé. Ordre réel par ratio impact/effort :

1. **Crawlabilité** : si le contenu n'est pas dans le HTML servi, rien d'autre ne compte.
2. **Surface d'URL** : sous 5 pages de contenu, créer des pages passe avant tout réglage d'infra.
3. **Contenu answer-first** sur les pages qui comptent (voir skill rédaction).
4. **Entité** : `Person` / `Organization` avec `@id` stable, `sameAs`, identifiant légal, et balisage local si zone de chalandise.
5. **JSON-LD par type de page** : BlogPosting, Service, BreadcrumbList, FAQPage.
6. **Métadonnées** : canonical, robots `max-snippet: -1`, OG images.
7. **Indexation rapide** : sitemap avec `lastModified` réels, IndexNow, Search Console.
8. **Arbre d'accessibilité valide** : c'est l'interface que lisent les agents (section 8), et le HTML invalide y casse aussi le sens du contenu.
9. **Garde-fous de build** pour que ça ne régresse pas.
10. `llms.txt` en dernier, si c'est trivial.

## 1. Crawlabilité (le piège numéro un)

**La plupart des crawlers IA n'exécutent pas le JavaScript.** Un H1 monté côté client par une lib d'animation, une FAQ ouverte par du state React, une liste chargée en `useEffect` : invisible. C'est le défaut le plus fréquent et le plus coûteux sur les stacks modernes.

- Le contenu qui doit être cité est rendu serveur. En Next.js App Router : Server Components par défaut, `'use client'` réservé à l'interaction. Attention à `dynamic(..., { ssr: false })` qui vide le HTML initial.
- Les animations d'apparition sont acceptables tant que le texte est servi **d'un seul tenant**. Exception à vérifier systématiquement : les effets qui découpent un titre lettre par lettre ou mot par mot (`LetterReveal`, `SplitText`, machine à écrire) produisent des dizaines de `<span>` avec `opacity:0` inline. Le texte est bien dans le HTML, mais tout extracteur qui insère un séparateur entre balises (BeautifulSoup `get_text(separator=' ')`, trafilatura, readability, plusieurs pipelines de crawl IA) lit `D é v e l o p p e u r`. Sans exécution du JS, ce titre reste en plus invisible visuellement. Réserver ces effets aux éléments décoratifs, jamais au H1 ni aux titres de section.

```bash
# Le H1 survit-il à un extracteur qui sépare les balises ?
python3 - <<'PY'
import re
h = open('page.html', encoding='utf-8', errors='replace').read()
t = re.search(r'(?is)<h1[^>]*>(.*?)</h1>', h).group(1)
print("brut   :", re.sub(r'<[^>]+>', '', t)[:100])
print("separe :", re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', t)).strip()[:120])
print("spans:", t.count('<span'), "| opacity:0:", t.count('opacity:0'))
PY
```
- `robots.txt` : ne rien interdire aux bots IA. Vérifier qu'il n'y a pas de `Disallow` visant `GPTBot`, `ClaudeBot`, `OAI-SearchBot`, `PerplexityBot`, `Google-Extended`, `Applebot-Extended`, `CCBot`. Beaucoup de sites les bloquent par réflexe ou par défaut d'un plugin, puis se demandent pourquoi ils ne sont jamais cités. Bloquer seulement l'admin, l'API et les pages privées.
- Directives robots des métas : `max-snippet: -1`, `max-image-preview: large`, `max-video-preview: -1`. Un `max-snippet` court limite l'extrait que Google peut reprendre en AI Overview.
- Décision explicite à faire remonter au client : autoriser les crawlers d'entraînement est un choix (donner son contenu contre de la visibilité). Ne pas le trancher à sa place, mais signaler que bloquer `GPTBot` bloque aussi, en pratique, une partie de la surface de citation.

## 2. Entité : le levier structurel le plus rentable

Les IA ne citent pas des pages, elles citent des **entités** dont elles sont sûres. La confiance se construit par recoupement de signaux cohérents.

- Un schéma `Person` (ou `Organization`) avec un **`@id` stable et absolu** : `https://site.com/#person`. Tous les autres schémas y font référence (`author`, `publisher`, `provider`, `creator`) au lieu de dupliquer l'objet inline. Un seul nœud, référencé partout.
- **`sameAs` vers 5 profils vérifiables ou plus** : LinkedIn, GitHub, plateformes métier, fiche Google Business, Wikidata si elle existe. C'est le mécanisme de désambiguïsation principal.
- **Identifiant légal** quand il existe : SIRET, numéro de TVA, `identifier` structuré. Un identifiant vérifiable sépare une entité réelle d'une page marketing.
- **Cohérence stricte cross-plateforme** : même nom, même intitulé de poste, même photo, mêmes URLs, sur le site, les profils externes et les fichiers texte. Une variation d'intitulé entre le site et LinkedIn fabrique deux entités faibles au lieu d'une forte.
- Figer la formulation canonique quelque part (constante partagée, `CLAUDE.md` du projet) pour qu'elle ne dérive pas au fil des refontes.

## 2 bis. Activité locale : le balisage manque presque toujours

Dès que l'activité a une zone de chalandise (agence, commerce, artisan, cabinet, freelance rattaché à une ville), c'est le levier le plus rentable et le plus souvent absent. Les coordonnées existent en clair sur le site, dans les mentions légales ou le pied de page, mais ne sont dans aucun balisage : illisibles en machine.

- Type précis plutôt que `Organization` générique : `LocalBusiness`, `ProfessionalService`, `Dentist`, etc.
- `address` (`PostalAddress` avec `addressLocality`, `postalCode`, `addressCountry`), `telephone`, `email`, `geo`, `areaServed` (villes et département réellement couverts), `openingHoursSpecification`, `priceRange`.
- `identifier` avec le SIRET, déjà présent dans les mentions légales.
- **Cohérence NAP** (nom, adresse, téléphone) strictement identique entre le site, la fiche Google Business et les annuaires. Une variante d'adresse fabrique une seconde entité faible.
- Reprendre ces données depuis la page mentions légales : c'est la source la plus fiable et déjà rédigée.

## 2 ter. Surface d'URL : combien de pages citables ?

Une IA cite une URL qui répond à une question. Un site one-page n'en offre qu'une, quel que soit le soin apporté au balisage : c'est un plafond structurel que ni les schémas ni les métadonnées ne franchissent.

Compter les URL indexables réellement porteuses de contenu (hors mentions légales, confidentialité, traductions). Sous 5, le sujet prioritaire n'est plus l'infra mais la création de pages : une page par service, par zone géographique servie, par cas client, puis des articles. Chaque page cible une question réelle et devient une cible de citation distincte. Le dire franchement plutôt que d'optimiser à la marge une page unique.

## 3. JSON-LD par type de page

| Page | Schémas |
|---|---|
| Toutes (layout) | `Person` ou `Organization` (`@id` stable) + `WebSite` |
| Home | + `FAQPage` si bloc Q&A réel |
| Article | `BlogPosting` (`datePublished`, `dateModified`, `author` par `@id`, `wordCount`, `inLanguage`) + `BreadcrumbList` |
| Liste / blog | `CollectionPage` + `ItemList` + `BreadcrumbList` |
| Service | `Service` + `hasOfferCatalog` + `priceSpecification` + `FAQPage` + `BreadcrumbList` |
| Entreprise / freelance | `ProfessionalService` ou `LocalBusiness` avec `areaServed`, `identifier`, `aggregateRating` |
| Profil / about | `ProfilePage` |
| Projet, case study | `CreativeWork` |

Points qui font la différence :

- **Prix réels dans `priceSpecification`** (`UnitPriceSpecification`, `billingDuration`, `eligibleDuration`). C'est ce qui permet à une IA de répondre à une question tarifaire en citant la source.
- **`Review` verbatim** avec `author` nommé, `datePublished` et `reviewBody` réel. Toujours accompagner d'un `aggregateRating` cohérent sur l'entité : un `Review` isolé sans `aggregateRating` déclenche des avertissements Search Console.
- **`FAQPage`** n'a plus de rich result Google (retiré en mai 2026 hors gouvernement et santé) mais reste lu par les LLM. L'ingrédient actif est le contenu Q&A visible, le balisage le double.
- **Cohérence date JSON-LD / date visible** : un mismatch est l'erreur la plus fréquente en audit.
- Ne jamais inventer une note, un avis ou une métrique. Un faux signal détecté détruit l'E-E-A-T au lieu de le construire.

## 4. Double signal pour les FAQ

Écrire les blocs Q&A en `<details>` / `<summary>` natifs **et** injecter le `FAQPage` JSON-LD correspondant. Les crawlers sans JS lisent le HTML statique, les autres lisent le markup. Les deux sources doivent dire exactement la même chose, mot pour mot. Sur un blog en MDX, générer le JSON-LD depuis le frontmatter `faq:` et rendre le même contenu dans le corps garantit la synchronisation.

Un accordéon dont les réponses sont conditionnées à un state React ne contient aucun texte crawlable.

**Ne pas envelopper les `<details>` dans un `<dl>`.** La spec HTML n'autorise comme enfants directs d'un `<dl>` que `<dt>`, `<dd>`, `<div>`, `<script>` et `<template>` : un `<details>` y est invalide, et un `<dd>` sans `<dt>` frère l'est aussi. axe-core le remonte en `definition-list` (échec Accessibilité) **et** en `agent-accessibility-tree` (échec Agentic Browsing dans Lighthouse 13), soit exactement la catégorie qui mesure la lisibilité par les agents IA. Le balisage sémantique de la FAQ passe par le JSON-LD, pas par le `<dl>`. Structure correcte :

```tsx
{items.map((item) => (
  <details key={item.question} className="group border-b py-6">
    <summary>
      {item.question}
      <span aria-hidden="true">+</span>   {/* le chevron pollue le nom accessible */}
    </summary>
    <p className="mt-4">{item.answer}</p>
  </details>
))}
```

## 5. Métadonnées

- Template de titre (`%s · Marque`) pour que la marque suive sans dupliquer.
- **Canonical propre par page**, absolu, et cohérent en trailing slash avec l'URL réellement servie.
- **Multilingue** : chaque version linguistique porte un canonical vers **elle-même**, jamais vers la langue par défaut. Un canonical `/en` pointant vers la version française annule la page anglaise, même avec des `hreflang` corrects. Les `hreflang` doivent être réciproques et inclure `x-default`.
- Description answer-first, chiffrée, pas de slogan creux : elle est parfois reprise telle quelle.
- Open Graph et Twitter Card avec image 1200x630. Générer l'image dynamiquement côté serveur à partir du titre (`next/og` ou équivalent) évite les images fantômes ou obsolètes.
- Redirections 301 sur toutes les anciennes URLs et les raccourcis. Une page morte est une citation perdue.

## 6. Indexation

- **Sitemap** avec `lastModified` **réels**, dérivés du `dateModified` du contenu. Bumper les dates à vide est détecté et ignoré. Priorités cohérentes avec l'importance réelle des pages.
- **IndexNow** : soumission automatique au déploiement de production, pas au push. Fait passer l'indexation de plusieurs jours à quelques heures chez Bing, Yandex, Seznam, Naver et les autres participants. **Google ne supporte pas IndexNow** : pour lui, sitemap et Search Console. Le déclencheur fiable est l'événement de déploiement réussi en production (`deployment_status` sur GitHub Actions), sinon on ping des URLs pas encore en ligne.
- La clé IndexNow est un fichier `.txt` en racine publique dont le contenu vaut le nom. La supprimer ou la renommer casse la soumission avec un 403.

## 7. Garde-fous de build

Ce qui n'est pas vérifié au build régresse. Valider le frontmatter des contenus avec un schéma (Zod ou équivalent) qui **casse le build** plutôt que d'émettre un warning : titre sous 65 caractères, description entre 110 et 160, `date` et `dateModified` présentes, au moins un tag. Une méta tronquée en production est plus coûteuse qu'un build rouge.

## 8. Lisibilité par les agents (Lighthouse « Agentic Browsing »)

Lighthouse 13 ajoute une catégorie **Agentic Browsing** notée à part. Elle mesure ce qu'un agent IA qui pilote un navigateur peut comprendre de la page, et elle s'appuie sur l'**arbre d'accessibilité**. Conséquence pratique : l'accessibilité n'est plus seulement une question de conformité, c'est le canal par lequel un agent lit et actionne le site. Un seul `<dl>` mal formé fait tomber la catégorie à 67.

Ce qui casse l'arbre en priorité :

- **HTML sémantiquement invalide** : enfants interdits dans `<dl>`, `<ul>`, `<table>` ; titres sautés ; `<dd>` orphelin.
- **`aria-label` qui ne contient pas le texte visible** (`label-content-name-mismatch`). Un logo affichant `axel_hamilcaro()` avec `aria-label="Accueil"` casse la commande vocale et déroute l'agent : le nom accessible doit **inclure** le texte visible, donc `aria-label="axel_hamilcaro(), retour a l'accueil"`.
- **Icônes et chevrons décoratifs sans `aria-hidden="true"`** : ils polluent le nom accessible du bouton ou du `<summary>`.
- **Contraste insuffisant** : compté dans Accessibilité, et symptôme d'un texte que l'OCR d'un agent multimodal lira mal.

### Auditer sans polluer le rapport

Un Lighthouse lancé depuis le Chrome de tous les jours est **inexploitable** : les extensions (bloqueur, traducteur, gestionnaire de mots de passe) génèrent de faux `errors-in-console`, `unminified-javascript`, `unused-javascript` et `legacy-javascript` qui n'ont rien à voir avec le site. Toujours auditer en Chrome propre, et sur **toutes les routes**, pas seulement la home : les pages secondaires (mentions légales, CGV, pages service) concentrent les régressions parce que personne ne les regarde.

```bash
# Chrome propre + toutes les routes. Le binaire Playwright fait très bien l'affaire.
export CHROME_PATH=~/.cache/ms-playwright/chromium-*/chrome-linux64/chrome
for r in / /about /services /blog /cgv /mentions-legales; do
  npx --yes lighthouse@13 "http://localhost:3000$r" --preset=desktop --quiet \
    --output=json --output-path="/tmp/lh$(echo "$r" | tr / _).json" \
    --chrome-flags="--headless=new --no-sandbox --disable-extensions"
done

# Ne lire que ce qui échoue, toutes catégories confondues
jq -r '.categories | to_entries[] | "\(.key) \(.value.score)"' /tmp/lh_.json
jq -r '[.audits[] | select(.score != null and .score < 1)] | .[] | "\(.id): \(.title)"' /tmp/lh_.json

# Agréger les paires de couleurs fautives plutôt que les nœuds : 30 nœuds = souvent 3 tokens
jq -r '.audits["color-contrast"].details.items[]?.node.explanation' /tmp/lh_*.json \
  | grep -oE 'foreground color: #\w+, background color: #\w+' | sort | uniq -c | sort -rn
```

### Contraste : trois sources d'échec, toujours les mêmes

Ne pas corriger nœud par nœud. Les dizaines de nœuds remontés se réduisent presque toujours à quelques tokens :

1. **La couleur d'accent de la marque.** Un orange, un ambre ou un cyan vif plafonne vers 3:1 sur blanc, alors qu'il en faut 4.5 sous 24 px (3:1 seulement au-delà, ou dès 18.66 px en gras). Corriger le token une fois vaut mieux que trier 200 usages : assombrir en multipliant les canaux RVB par un facteur unique préserve exactement la teinte et la saturation HSV, donc la couleur reste reconnaissable. Garder l'original sous un token séparé (`--accent-vivid`) pour les glows, gradients et pulses de titres, où la contrainte est à 3:1 ou nulle.

   **Quand la couleur ne se négocie pas** (charte client, logo d'un cas d'étude), ne pas la modifier : changer l'usage. Un jaune vif ne franchira jamais 4.5:1 sur blanc, mais en aplat plein avec du texte foncé il monte à 12:1 et reste le jaune de la marque. Dériver au point d'usage plutôt que dupliquer la palette : une fonction `textOn(brand)` qui choisit noir ou blanc selon la luminance, une fonction `inkOnLight(brand)` qui assombrit jusqu'au ratio pour les rares textes colorés (chiffres de stats, labels). La palette reste l'unique source de vérité, les aplats gardent la teinte exacte, et les icônes colorées ne sont pas concernées (`color-contrast` ne teste que le texte).
2. **Les opacités Tailwind.** `text-secondary/60`, `text-white/80`, `opacity-80` : chaque cran d'opacité mange du contraste, et un blanc à 80 % sur un aplat de marque tombe à 3,5:1. Sur un fond coloré, la hiérarchie visuelle se fait par la taille et la graisse, pas par l'opacité.
3. **Un token de surface utilisé comme couleur de texte.** Piège shadcn classique : `--muted` est une couleur de **fond**, `--muted-foreground` la couleur de texte associée. Tout `text-muted` est un échec de contraste par construction. Vérifier d'un coup : `grep -rEo "text-muted(-foreground)?" src | sort | uniq -c`.

Cas voisin, `link-in-text-block` : un lien inline dans un paragraphe doit avoir 3:1 **avec le texte qui l'entoure**, pas seulement avec le fond. Un lien accent dans du gris échoue toujours. Le souligner (`underline underline-offset-2`) règle l'audit et l'accessibilité réelle ; `hover:underline` ne compte pas.

### Ce que le rapport remonte et qu'il ne faut PAS corriger

- `is-crawlable` sur une page volontairement en `noindex` (login, page d'erreur privée). Attendu.
- `errors-in-console` provoqué par des scripts d'analytics qui 404 en local ou sont bloqués par un adblock en prod. Vérifier la source avant de toucher au code.
- Un contraste mesuré sur un élément en cours d'animation de reveal : `text-primary` relevé à `#7b7b7b` est un artefact de l'opacité intermédiaire, pas un vrai défaut. Recouper avec la valeur du token.

Et un rapport à **jeter** plutôt qu'à corriger : des chunks en 404/500 ou servis en `text/plain`, un `landmark-one-main` qui échoue sur une page qui contient bien un `<main>`, un `<html>` mesuré à 143 px de haut. C'est un build écrasé sous le serveur qui tourne, ou deux serveurs sur le même port. Tuer tous les processus, rebuild, relancer un seul serveur, réauditer.

### Pièges de framework

Les attributs LCP ne suivent pas toujours l'API du composant. **Next.js 16 a déprécié `priority` sur `next/image` au profit de `preload`**, et `priority` seul n'émet plus `fetchpriority="high"` : l'audit `lcp-discovery` reste rouge alors que le code a l'air correct. Pour l'image LCP : `<Image preload fetchPriority="high" ... />`. Vérifier dans le rapport que la requête image est en priorité `High` et pas `Low`.

Autre piège des libs de composants : un `DialogTrigger asChild` (Radix) posé sur un `<div>` ou un `motion.div` y colle `aria-expanded` et `aria-haspopup`, attributs interdits sur un élément sans rôle (`aria-allowed-attr`). Le trigger doit envelopper le composant qui rend un vrai `<button>` et forwarde ses props.

## Workflow d'audit

1. **Vérifier le rendu serveur d'abord.** Tout le reste est inutile si le contenu n'est pas servi.
2. Extraire et valider les JSON-LD de chaque type de page.
3. Vérifier `robots.txt` et le sitemap.
4. Lire le contenu des pages clés avec l'œil answer-first (skill rédaction).
5. Vérifier la cohérence d'entité entre le site et les profils externes.
6. Passer Lighthouse sur **toutes** les routes en Chrome propre (section 8) et agréger les échecs par audit, pas par page : un même token fautif ressort sur quinze pages.
7. Restituer un plan classé par impact/effort, pas une liste à plat.

### Commandes de vérification

```bash
# 1. Le contenu est-il dans le HTML servi ? (JS désactivé = ce que voit un crawler IA)
curl -s https://site.com/ | grep -o 'phrase exacte du H1'          # vide = invisible pour les IA
curl -s https://site.com/blog/slug | grep -c 'question de la FAQ'  # doit valoir >= 1

# 2. Extraire tous les JSON-LD (tolère le HTML minifié et l'ordre des attributs)
#    Signale aussi les entités HTML littérales, invalides dans du JSON.
curl -s https://site.com/ > page.html
python3 - <<'PY'
import re, json
h = open('page.html', encoding='utf-8', errors='replace').read()
blocks = re.findall(r'(?is)<script[^>]*application/ld\+json[^>]*>(.*?)</script>', h)
print("blocs:", len(blocks), "| entites HTML dans le JSON-LD:",
      sum(b.count('&#39;') + b.count('&amp;') + b.count('&quot;') for b in blocks))
for b in blocks:
    try: print(json.dumps(json.loads(b), ensure_ascii=False, indent=1)[:2000])
    except Exception as e: print("JSON INVALIDE:", e)
PY

# 3. Les @id sont-ils stables et référencés partout ?
grep -o '"@id":"[^"]*"' page.html | sort -u          # vide = aucun graphe d'entité

# 4. robots.txt : aucun blocage des bots IA
curl -s https://site.com/robots.txt | grep -iE 'gptbot|claudebot|perplexity|google-extended|ccbot|oai-search'

# 5. Sitemap : le trouver via robots.txt, ne jamais supposer /sitemap.xml
curl -s https://site.com/robots.txt | grep -i '^sitemap:'
curl -s https://site.com/sitemap-0.xml | grep -oP '(?<=<lastmod>)[^<]+' | sort -u | tail
curl -s https://site.com/sitemap-0.xml | grep -c '<url>'   # surface d'URL indexables

# 7. Coordonnées présentes en texte mais absentes du balisage
curl -s https://site.com/mentions-legales | grep -oE 'SIRET[^<]*|0[1-9]([ .-]?[0-9]{2}){4}'

# 6. Directives snippet
curl -s https://site.com/ | grep -o '<meta name="robots"[^>]*>'
```

Validateurs externes : Rich Results Test (`search.google.com/test/rich-results`), Schema Markup Validator (`validator.schema.org`), et la Search Console pour les erreurs réelles constatées sur le site.

## Ce qui ne marche pas (ne pas y passer de temps)

- **`llms.txt` / `llms-full.txt`** : effet non prouvé, Google confirme ne pas le lire. À faire si c'est trivial, sans en attendre de gain mesurable, et jamais en premier.
- **Micro-chunking du contenu** : démenti par Google. Des H2/H3 clairs suffisent.
- **Densité de mots-clés** : mythe mort.
- **Gonfler les FAQ** pour le volume : du padding, détecté.
- **`HowTo`** : déprécié depuis 2023.
- **Empiler des schémas** sans contenu visible correspondant : un balisage qui décrit ce que la page ne dit pas est un signal contradictoire.

## Erreurs courantes

- Contenu monté côté client, donc absent du HTML servi. À vérifier en premier, systématiquement.
- `sameAs` vers des profils morts, ou intitulés incohérents entre le site et LinkedIn.
- `Review` sans `aggregateRating` : avertissement Search Console.
- Date du JSON-LD différente de la date affichée.
- `dateModified` bumpée sans modification de fond.
- FAQ visible et FAQ balisée désynchronisées après une réécriture.
- Canonical pointant vers la home sur toutes les pages (défaut de config classique), ou canonical d'une version traduite pointant vers la langue par défaut.
- **Entités HTML littérales dans le JSON-LD** (`d&#39;un`, `&amp;`, `&quot;`) quand le balisage est généré depuis un champ rich text de CMS. Le JSON n'interprète pas les entités HTML : la valeur citée contient le code source. Même cause, même origine : la concaténation de blocs sans espace (`résoudre.Une proposition`).
- Question de `FAQPage` balisée avec les guillemets décoratifs de la maquette : la question extraite n'est plus une question propre.
- Coordonnées, SIRET et zone d'intervention présents en clair dans les mentions légales mais absents de tout balisage.
- Prix affichés sur la page mais absents de `Offer` / `priceSpecification` : invisibles pour une réponse tarifaire générée.
- Profils d'avis dans `sameAs` sans `aggregateRating` correspondant : le signal de réputation reste inexploité (ne jamais le fabriquer, le brancher sur les avis réels).
- IndexNow déclenché au push et non au déploiement : soumission d'URLs pas encore en ligne.
- `<details>` d'une FAQ enveloppés dans un `<dl>` : HTML invalide, échec `definition-list` **et** `agent-accessibility-tree`.
- Lighthouse lancé depuis le navigateur personnel : les extensions faussent la moitié des audits perf et console.
- Lighthouse lancé sur la seule page d'accueil : les pages secondaires (légales, services, cas clients) concentrent les régressions.
- Audit rendu comme une liste à plat de 40 items sans priorisation : illisible, donc jamais appliqué.
