---
name: rediger-article-blog-seo-geo
description: "Use when writing or drafting a French blog article optimized for SEO and GEO/AEO (citations by ChatGPT, Perplexity, Google AI Overviews, Claude), without AI slop. Triggers: 'écris/rédige un article', 'article de blog', 'post SEO', GEO, AEO, AI Overviews, article sur un service (TMA, dev SaaS, lead tech), MDX blog."
---

# Rédiger un article de blog SEO/GEO (français, sans AI slop)

Skill généraliste réutilisable sur n'importe quel projet. La dernière section explique comment l'adapter au repo courant (MDX, schéma, frontmatter).

## Principe

Un bon article répond à une intention de recherche dès la première phrase, apporte une vraie valeur (faits, chiffres, expérience vécue), se lit sans effort, et reste citable par les moteurs génératifs. Il est écrit en français standard, jamais en bouillie d'IA.

La règle qui prime sur tout : **chaque phrase doit mériter d'exister.** Si elle ne dit rien de concret, elle saute.

**Originalité avant tout, sinon ne pas publier.** Le piège numéro un d'un article SEO/GEO est de devenir une compilation de ce que disent les autres : on enchaîne « selon X », « d'après Y », « l'étude Z montre », et on obtient un texte qui paraphrase les premiers résultats Google sans rien ajouter. C'est exactement ce que les IA produisent déjà à l'infini, donc invisible et non cité. Un article mérite d'exister seulement s'il apporte quelque chose que les autres n'ont pas : une thèse défendue, un vécu de praticien (situations réelles, décisions prises, erreurs, chiffres à soi), un angle contre-intuitif, une donnée propriétaire, une démonstration concrète. Les sources externes ÉTAYENT ce propos, elles ne le REMPLACENT jamais. **Test de la paraphrase : si on masque toutes les phrases en « selon/d'après [source] », ce qui reste doit déjà être un article autonome avec un point de vue. S'il ne reste qu'un squelette vide, l'article est à refondre, pas à publier.** L'ordre de travail compte : partir de la thèse et du vécu de l'auteur, PUIS chercher les sources qui appuient ou nuancent, jamais l'inverse.

Deux objectifs distincts mais alignés. Le **SEO** vise le classement dans les liens bleus. Le **GEO/AEO** vise la citation dans les réponses génératives. Bonne nouvelle 2026 : les signaux se recouvrent largement (autorité, fraîcheur, entité cohérente, densité d'info). Mauvaise nouvelle : être premier sur Google ne garantit pas d'être cité par les IA. Seules ~23 % des sources citées par les IA sont dans le top 10 Google pour la même requête. Il faut viser les deux explicitement.

## Standard français (anti-AI slop) : règles dures

Ces interdits ne se négocient pas. Les violer, c'est produire du slop détectable par Google (politique « scaled content abuse » de mars 2024, toujours active) et par les lecteurs.

- **Jamais de tiret cadratin ni demi-cadratin** (`—`, `–`). C'est le marqueur d'IA le plus fiable. Utiliser une virgule, des parenthèses, ou couper la phrase. Vérifier avec `grep -c '—' fichier.mdx` qui doit renvoyer `0`.
- **Pas de pattern « Titre : description » répété** ligne après ligne. Un deux-points isolé et justifié passe ; une cascade de deux-points en tête de chaque puce, non. Dans les listes, écrire des phrases (un terme en gras suivi d'une virgule, pas d'un deux-points).
- **Bannir la structure « Ce n'est pas X, c'est Y »** et ses variantes (« Non seulement X, mais aussi Y », « Voici le truc : », « Et c'est là que ça devient intéressant »). Reformulation mécanique typique des LLM.
- **Accents complets**, toujours. Jamais d'ASCII à la place (`à`, `é`, `ç`, `ê`, `«` `»`).
- **Bannir les formules creuses** : « Dans un monde où », « À l'ère de », « Il est important de noter que », « Il convient de souligner », « De nos jours », « n'hésitez pas à », « force est de constater », « plongeons dans », « en conclusion ».
- **Bannir le lexique IA surnoté** : « explorer/plonger » mécanique, « tirer parti de » (leverage), « robuste », « incontournable », « à la pointe », « qui change la donne », « pierre angulaire », « écosystème » métaphorique, « holistique », « transformateur ».
- **Pas de connecteurs académiques en pilote automatique** en tête de chaque paragraphe (« Cependant », « Néanmoins », « Toutefois », « En outre », « Par conséquent », « À cet égard »). Varier ou supprimer.
- **Pas d'adverbes-béquilles** répétés (« notamment », « particulièrement », « essentiellement », « fondamentalement »).
- **Pas de sycophancie** (« Excellente question », « Vous n'êtes pas le seul à... »), pas d'emoji, pas de conclusion qui répète l'article avec d'autres mots.
- **Pas de superlatifs vides** (« révolutionnaire », « la clé du succès ») sans fait derrière.
- **Pas de listes calibrées à 3, 5, 7 ou 10 items pile.** Mettre le nombre réel d'éléments utiles, même si c'est 4 ou 11.
- **Casser le rythme métronome.** Phrases de longueur variée, alterner court et long. Paragraphes de longueur variable. Un texte où chaque section et chaque phrase a la même taille sonne robotique.

## SEO/GEO SOTA 2026 : ce qui rend l'article citable

Hiérarchie par niveau de preuve. Les pourcentages viennent de l'étude Princeton (GEO, arXiv 2311.09735) et d'analyses de citations LLM 2025-2026 (Ahrefs, Semrush, Kevin Indig).

- **Citer ses sources inline (preuve la plus forte côté citation).** Référencer des sources nommées avec lien augmente les citations de 30 à 40 %, et jusqu'à +115 % pour un site peu connu. Attention au contresens : ce levier suppose un article qui a déjà un propos propre, les sources viennent l'étayer. Empiler des citations sur un contenu vide produit de la paraphrase, pas de l'autorité. Viser 2 ou 3 sources fortes par section, en appui d'une idée à soi, pas une source par phrase qui tient lieu de contenu.
- **Citations d'experts nommés (+37 %) et statistiques chiffrées (+22 %).** Une donnée avec source citée vaut dix affirmations vagues. Toujours préférer un chiffre précis et daté.
- **Answer-first / definition-first.** 44 % des citations LLM proviennent du premier tiers du contenu. Les 2-3 premières phrases répondent directement et définissent le sujet (`[Terme] consiste à [...]`), sans préambule. Mettre la phrase clé en gras. C'est le bloc que les IA extraient.
- **Une question par H2, une réponse autosuffisante dessous.** Chaque section doit pouvoir être lue et citée hors contexte. Titres formulés comme des questions ou intentions réelles (« Combien coûte X », « Comment choisir Y »). Répondre dans les 50 premiers mots de la section.
- **Voix autoritaire, sans hedging mou (+10-20 %).** Affirmer ce qu'on sait. Les nuances honnêtes sont bonnes ; les « il semblerait peut-être que » mécaniques diluent la citabilité.
- **Listes pour la citabilité.** Énumérations (types, critères, étapes) et tableaux comparatifs sont nettement plus cités que la prose dense. Garder de la prose entre les listes, jamais un mur de puces.
- **Structure naturelle, PAS de micro-chunking forcé.** Google a explicitement démenti le besoin de découper artificiellement le contenu pour les IA. Des H2/H3 clairs et des paragraphes de 40 à 80 mots suffisent. Ne pas hacher le texte en fragments.
- **E-E-A-T, surtout le premier E (Experience).** C'est le différenciateur 2026 que l'IA ne peut pas simuler : résultats mesurables précis (« 4,2 s à 1,1 s », pas « plus rapide »), outils et versions nommés, échecs documentés et leçons, données propriétaires, captures de ses propres écrans, avis nuancés ou désaccords argumentés avec le consensus.
- **Auteur identifiable = signal E-E-A-T sous-exploité.** Un article signé par une `Person` avec bio crédible et `sameAs` vers profils vérifiables (LinkedIn, GitHub, Wikidata, site perso) gagne en confiance auprès des IA. Cohérence d'entité cross-plateforme (même nom, titre, photo partout).
- **Mentions off-site, Reddit en tête.** Reddit pèse ~21 % des citations Google AI Overviews et ~24 % de Perplexity. Être mentionné authentiquement sur Reddit, forums de niche, Quora, sites tiers, compte autant que son propre contenu (~moitié des citations IA viennent de domaines tiers). Participer pour de vrai, jamais de fausses mentions (détectées, contre-productives, sentiment négatif = ton IA négatif).
- **Fraîcheur réelle.** Renseigner `dateModified` à chaque révision substantielle. Bumper la date sans changer le fond est détecté et ignoré. Ne jamais fabriquer une date.
- **Maillage interne et page source.** Un article sur un service DOIT citer et lier la page de service correspondante, avec ses chiffres réels (forfaits, SLA, prix). 2 à 5 liens contextuels pour 1000 mots, anchors descriptifs variés (jamais « cliquez ici » ni exact-match systématique), liens vers la page pilier du cluster.
- **Honnêteté absolue.** Jamais inventer une note, une métrique, une date, un avis. N'utiliser que des données réelles ou sourcées.
- **Hygiène des statistiques : traquer les stats fantômes.** Beaucoup de chiffres « SEO-friendly » circulent partout sans source primaire accessible (attribution secondaire en boucle, blogs qui se citent entre eux). Exemples vécus : « marché fractional à 5,7 Mds$ », « +68 % de demande en un an », « Gartner prévoit 30 % d'ici 2027 ». Avant de citer un chiffre, vérifier qu'il remonte à une source PRIMAIRE datée (rapport, étude, enquête méthodologiquement documentée). Sinon : soit l'écarter, soit l'attribuer prudemment (« selon plusieurs analyses sectorielles ») sans le mettre au compte d'une institution non vérifiée. Citer une fausse stat attribuée à Gartner ou à une étude inexistante détruit l'E-E-A-T au lieu de le renforcer. Demander au sous-agent de recherche de signaler explicitement ce qui n'est PAS vérifiable.

## Ce qui ne marche PAS en 2026 (mythes à enterrer)

- **`llms.txt` : effet non prouvé.** Google (John Mueller) confirme ne pas le lire. Aucune preuve empirique de gain. L'implémenter si c'est trivial, n'y investir aucune ressource sérieuse.
- **« Être premier sur Google = être cité par les IA » : faux.** Deux jeux de signaux qui divergent de plus en plus.
- **Micro-chunker tout le contenu : inutile** (voir plus haut).
- **Densité de mots-clés à X % : mythe mort.** Écrire naturellement.
- **Bourrer l'article de FAQ pour gonfler le nombre de mots : padding détecté.** N'ajouter une FAQ que si les questions sont réelles.
- **FAQPage / HowTo pour les rich results : terminé.** HowTo déprécié depuis 2023, FAQPage rich results retirés (mai 2026, hors gouvernement/santé). Le markup reste lu pour la structuration sémantique et le GEO, mais l'ingrédient actif est le contenu Q&A lui-même, pas le balisage.

## Lisibilité

- Paragraphes de 2 à 4 phrases, plafond ~100 mots. Une idée par paragraphe, sans l'entonnoir académique « topic sentence, preuve, conclusion » répété mécaniquement.
- Phrase moyenne sous 20 mots, avec ruptures volontaires (une phrase courte après une longue).
- Gras stratégique sur les termes définis et les chiffres clés, pour le scan.
- Chiffres avec symboles plutôt qu'en toutes lettres quand le nombre est en chiffres : `42 %` et `1 200 €`, pas « 42 pour cent ». Plus scannable, et plus facilement extrait comme fait par les IA. Espace avant le `%` et le `€`.
- Signaux de voix humaine bienvenus avec parcimonie : « en pratique », « franchement », « j'ai testé », une prise de position tranchée, une anecdote datée et précise.
- Longueur : écrire jusqu'à ce qu'il n'y ait plus rien d'utile à dire, puis retirer 20 %. Densité d'information avant volume. Repère pratique 1500 à 2400 mots pour un sujet de fond, moins si le sujet est étroit. Le long-form pour le long-form est mort.

## Données structurées (schema) : priorités 2026

Par ordre d'utilité pour un article (la plupart des CMS/sites le gèrent déjà, vérifier avant d'ajouter) :

1. **Article / BlogPosting** avec `author`, `datePublished`, `dateModified`. Toujours.
2. **Person** (auteur) avec `sameAs` vers profils vérifiables, référencé par `@id` stable plutôt que dupliqué inline. Levier E-E-A-T le plus rentable.
3. **BreadcrumbList**. Rich result encore actif, aide au crawl.
4. **Organization** + `sameAs` pour ancrer la marque dans le knowledge graph.
5. **FAQPage** uniquement si la page a un vrai bloc Q&A (plus de rich result, mais utile au GEO et cohérent avec le contenu visible). Le bloc visible se rend en `<details>` / `<summary>` natifs, **jamais enveloppés dans un `<dl>`** : un `<details>` y est un enfant interdit et fait échouer l'arbre d'accessibilité, donc la catégorie Agentic Browsing (détail dans le skill `optimiser-site-geo`).

Vérifier la cohérence entre la date du JSON-LD et la date visible sur la page (mismatch = signal contradictoire fréquent en audit).

## Adapter au repo courant

Avant d'écrire, détecter les conventions du projet plutôt que supposer :

1. Repérer le dossier de contenu (`content/blog`, `src/content`, `posts/`...) et le format (MDX, Markdown, CMS).
2. Lire un article existant pour copier la structure de **frontmatter** exacte (clés, format de date, slug).
3. **Caler le registre (tutoiement/vouvoiement) sur les articles de blog existants, pas sur les pages service.** Piège fréquent : un site peut tutoyer sur ses pages `/services` (ton direct, marketing) tout en vouvoyant dans son blog (ton éditorial). Le cluster blog doit rester homogène entre lui. Vérifier sur un article publié, pas sur la landing.
4. Vérifier quels schémas JSON-LD sont déjà câblés (souvent BlogPosting + Breadcrumb, parfois FAQPage et Person auto). Ne pas dupliquer ce qui est généré.
5. Repérer la page de service ou la page pilier à lier pour le maillage interne.

**Exemple de setup MDX courant** (ce portfolio, axelhamilcaro.com) :

- Fichier `content/blog/<slug>.mdx`. Le nom du fichier est le slug et l'URL (`/blog/<slug>`). Choisir un slug avec le mot-clé exact (ex : `tierce-maintenance-applicative`).
- **Pas de `# H1` dans le MDX** : le `title` du frontmatter est déjà rendu en H1 par la page. Commencer par l'intro, puis `##` (H2) et `###` (H3). Seuls H2/H3 alimentent la table des matières.

```yaml
---
title: "..."            # H1 de l'article, formulation éditoriale, max 65
seoTitle: "..."         # optionnel : <title> SERP si le H1 dépasse. Max 48 (le suffixe de marque ajoute 17)
subtitle: "..."         # sous-titre affiché sous le H1
date: "AAAA-MM-JJ"
dateModified: "AAAA-MM-JJ"
excerpt: "..."          # meta description + OG, 140-160 car., answer-first, sans deux-points
tags: ["...", "..."]
category: "Guide"       # label affiché (Guide, Étude de cas, Traduction...)
faq:                    # optionnel : déclenche le schéma FAQPage
  - question: "..."
    answer: "..."
---
```

- Le frontmatter est validé strictement (zod) au build : un `excerpt` de plus de 160 caractères casse le rendu en erreur 500, pas en avertissement. Vérifier la longueur avant de lancer (`python3 -c "import re;print(len(re.search(r'excerpt: \"(.*?)\"',open(F).read()).group(1)))"`). Même vigilance sur les autres champs requis.
- Si `faq:` est présent, la page injecte un JSON-LD `FAQPage` (en plus de `BlogPosting`, `BreadcrumbList`, et `Person`/`author` câblés). Le frontmatter ne rend AUCUNE section visible, il alimente seulement le JSON-LD. Pour que le contenu Q&A soit lu (le vrai levier GEO, le balisage seul ne suffit pas), écrire à la main une section `## Questions fréquentes` en markdown dans le corps, et la garder synchronisée mot pour mot avec le frontmatter `faq`. Réponses answer-first, sans deux-points.
- Images `![alt](/chemin)`, blockquotes `>`, tableaux Markdown stylés automatiquement. Pas d'import.
- SEO déjà géré (sitemap dynamique, BlogPosting lié au `#person`, OG dynamique). Écrire l'article suffit pour le référencer.

## Rechercher l'état de l'art (obligatoire avant de rédiger)

**Ne jamais rédiger un article de fond de mémoire.** Le modèle a un cutoff, et sur ces sujets (SEO, GEO, IA, marché, prix, réglementation) les chiffres et le consensus bougent en quelques mois. Un article sans données fraîches sort générique et daté, donc peu cité.

Avant de rédiger, lancer la recherche via sous-agent(s) `websearch` (un contexte principal lean, en parallèle si possible) :

1. **Passe fondamentaux** : définition de référence, taille et dynamique du marché, fourchettes de prix, distinctions clés, déclencheurs. C'est le socle.
2. **Passe SOTA** : ce qui a changé dans les 12 derniers mois, le débat en cours, l'impact d'une techno récente sur le sujet (en 2026, presque toujours : que change l'IA sur ce métier/produit ?). C'est l'angle qui rend l'article non générique et le rend citable. Demander explicitement « les angles les plus récents et pointus, pas du remplissage ».

Exigences passées au sous-agent, pour CHAQUE fait : statistique ou citation exacte, organisme/auteur nommé, URL, année. Privilégier sources primaires et institutionnelles datées de moins de 18 mois. Écarter les blogs d'agence anonymes. **Exiger qu'il signale ce qui n'est PAS vérifiable** (voir « Hygiène des statistiques »). Viser une dizaine de sources solides nommées pour un article de fond, dont 2-3 vraiment récentes qui portent l'angle SOTA.

## Workflow

1. Cadrer l'angle, la cible, le registre (vouvoiement par défaut, à confirmer sur un article de blog existant), le mot-clé principal et le slug keyword-rich. **Pour un article signé (portfolio, expert), c'est ici que se joue l'originalité : définir une thèse défendable AVANT d'écrire, et récupérer le vécu de l'auteur.** En pratique, proposer 3-4 angles de thèse contrastés (dont un contre-intuitif) et laisser l'auteur choisir, puis lui demander la matière first-hand que le modèle ne peut pas inventer (situations vécues, décisions, chiffres à lui, refus assumés). Ne jamais fabriquer une anecdote ou une métrique : s'appuyer sur ce que l'auteur fournit ou sur des faits vérifiables de son parcours. Sans cette étape, l'article retombe en compilation de sources.
2. **Rechercher l'état de l'art** (section ci-dessus) : sous-agents `websearch`, passe fondamentaux + passe SOTA, sources datées et vérifiables.
3. Détecter les conventions du repo (section dédiée). Pour un article de service, lire la page source et reprendre ses faits réels (prix, durées, étapes).
4. Rédiger : intro answer-first en gras, sections H2 question/réponse autosuffisantes, sources citées inline, chiffres datés, au moins un tableau ou une liste citable, une citation d'expert en blockquote, section FAQ visible si pertinente, conclusion utile avec lien vers la page de conversion.
5. Renseigner le frontmatter (title court, excerpt 140-160, `faq` si pertinent, dates réelles).
6. Vérifier (commandes ci-dessous), passer la checklist anti-slop.
7. Lancer le dev server, ouvrir l'article, vérifier le rendu, les schémas et le temps de lecture.
8. **Review par agents spécialisés** (section dédiée plus bas), appliquer les corrections convergentes, re-vérifier le rendu.

### Commandes de vérification

```bash
# Anti-slop : tirets cadratin/demi-cadratin (doit valoir 0) + lexique IA résiduel
grep -cE '—|–' content/blog/<slug>.mdx
grep -niE 'à l.ère de|il convient de|plongeons|écosystème|tirer parti|robuste|incontournable|change la donne|ce n.est pas.*c.est' content/blog/<slug>.mdx

# Rendu réel (dev server lancé) : un seul H1, schémas injectés, méta answer-first
curl -s http://localhost:<port>/blog/<slug> -o /tmp/a.html -w "%{http_code}\n"
grep -o '<title>[^<]*</title>' /tmp/a.html | head -1
grep -c '<h1' /tmp/a.html                      # doit valoir 1 (pas de H1 doublé par le MDX)
grep -o 'FAQPage\|BlogPosting' /tmp/a.html | sort -u

# Indexation interne : présence sitemap + liste blog + liens internes rendus
curl -s http://localhost:<port>/sitemap.xml | grep -o '<slug>'
grep -oE 'href="/(services/[a-z-]+|tma|blog/[a-z-]+)"' /tmp/a.html | sort -u
```

## Review finale par agents spécialisés

Avant publication, lancer trois agents de review EN PARALLÈLE sur le fichier, chacun avec une spécialité. Ils relisent et rapportent, ils ne modifient pas le fichier. C'est le filet qui attrape les défauts que l'auteur ne voit plus après avoir écrit.

1. **Langue française** (de préférence sur un modèle haut de gamme) : orthographe, accords, conjugaison, ponctuation, typographie (conventions du repo), anglicismes, calques, lourdeurs, répétitions, tics d'AI slop résiduels, registre tenu. Doit citer chaque phrase fautive et proposer la correction.
2. **SEO/GEO SOTA** : answer-first par section, citabilité (listes, tableaux, faits datés), équilibre des sources (appui vs compilation), couverture de l'intention de recherche et angles manquants, mots-clés/entités, méta (title, excerpt), maillage interne, quick wins de citabilité.
3. **Lisibilité et éditorial** : facilité de lecture pour la cible, thèse tenue de bout en bout, test de la paraphrase, authenticité du vécu first-hand, structure et redites, équilibre des longueurs de section, qualité de la clôture.

Format imposé à chaque agent : findings ACTIONNABLES (citation exacte + défaut + correction), classés par impact, plus une note /10 et un verdict. Ensuite, appliquer ce qui CONVERGE entre les trois agents et les findings à fort impact ; arbitrer le reste (un agent peut sur-corriger, ou recommander d'introduire un chiffre non sourcé, à refuser). Les désaccords entre agents sont des signaux, pas des ordres. Re-vérifier le rendu après corrections.

Pièges déjà rencontrés que ces agents attrapent bien : motif « n'est pas X, c'est Y » répété (en garder un seul, volontaire), connecteurs oraux en tête de paragraphe (« Voilà », « Sauf qu' », « De même »), calques (« comme l'analyse X », « pas juste »), jargon technique qui perd la cible (DDD, event sourcing balancés sans traduction d'impact), paragraphe-fleuve qui devrait être une liste, paraphrase résiduelle d'une source, FAQ visible désynchronisée du frontmatter, absence de tableau comparatif citable.

## Checklist anti-slop (relecture avant publication)

- Zéro tiret cadratin (`grep`).
- Zéro formule creuse (« il convient de noter », « à l'ère de », « plongeons dans »).
- Pas de cascade « Mot : ... » en tête de puces.
- Au moins une source nommée et liée, au moins un chiffre précis daté.
- Au moins une prise de position tranchée ou un élément d'expérience first-hand.
- Sections de longueurs différentes, phrases de longueurs variées.
- Transitions variées, pas un connecteur académique par paragraphe.
- La conclusion dit autre chose que l'intro reformulée.
- Lien vers la page de service / pilier présent pour un article de conversion.
- **Test de la paraphrase passé** : en masquant les « selon/d'après [source] », il reste un article autonome avec une thèse et du vécu. Sinon, refondre.
- Au moins un passage de vécu concret et daté (situation réelle, décision, chiffre à soi), pas seulement la compilation des sources.
- Review par les trois agents spécialisés passée, corrections convergentes appliquées, rendu re-vérifié.

## Erreurs courantes

| Symptôme | Correction |
|---|---|
| Tiret cadratin dans le texte | Virgule, parenthèses, ou couper la phrase |
| « Ce n'est pas X, c'est Y », « Voici le truc : » | Reformuler en affirmation directe |
| Chaque puce commence par « Mot : ... » | Réécrire en phrases, gras + virgule |
| Intro qui tourne autour du pot | Définir le sujet dès la 1re phrase, en gras |
| Aucune source citée | Ajouter 2-3 sources nommées et liées (levier GEO majeur) |
| Affirmations vagues | Remplacer par un chiffre précis et sourcé |
| Mur de puces | Réintroduire de la prose entre les listes |
| Article service sans lien vers la page source | Citer et lier la page avec ses chiffres réels |
| Deux `# H1` (un dans le MDX) | Supprimer le H1 du MDX, commencer aux H2 |
| Date modifiée sans changer le fond | Ne bumper `dateModified` que sur révision réelle |
| Chiffres ou avis inventés | N'utiliser que des données réelles ou sourcées |
| Stat citée sans source primaire (« selon Gartner... » introuvable) | Vérifier la source primaire, sinon écarter ou attribuer en « plusieurs analyses sectorielles » |
| Article rédigé de mémoire, sans recherche | Lancer les passes fondamentaux + SOTA via `websearch` avant d'écrire |
| Angle générique, pas d'actualité | Ajouter l'angle SOTA (ce que les 12 derniers mois ont changé, impact IA) |
| Registre calé sur la landing service | Vérifier le registre sur un article de blog publié, pas sur `/services` |
| Frontmatter `faq` sans section visible | Écrire la section `## Questions fréquentes` en markdown, synchronisée |
| Article = compilation de « selon X / d'après Y » | Partir de la thèse et du vécu, sources en appui ; passer le test de la paraphrase |
| Structure identique à tous les concurrents | Trouver un angle propre (thèse, vécu, donnée perso) avant de plaquer le plan standard |
| Tout neutre, aucun avis | Assumer une position de praticien, montrer un cas concret daté |
