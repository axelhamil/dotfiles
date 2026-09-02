---
name: mailler-articles-blog
description: "Use when auditing an existing blog's articles to add internal cross-links between them (maillage interne / internal linking, SEO/GEO topic cluster). Triggers: 'maillage interne', 'lier les articles entre eux', 'liens internes entre articles', 'relier les articles du blog', 'internal linking', 'cluster SEO', 'check si on peut se citer entre articles'."
---

# Mailler les articles d'un blog (liens internes, cluster)

Skill ciblé et réutilisable : on prend un blog déjà rempli et on ajoute les liens internes croisés qui manquent entre articles. Distinct de `rediger-article-blog-seo-geo`, qui gère le maillage au moment d'écrire UN article ; ici on traite un cluster EXISTANT en lot.

## Pourquoi

Un cluster d'articles qui se citent entre eux concentre l'autorité thématique : PageRank interne mieux réparti côté SEO, et côté GEO les moteurs génératifs suivent les liens et lisent le cluster comme un corpus cohérent sur un sujet. Le gain ne vient que de liens RÉELS. Un lien forcé entre deux articles sans rapport dilue le signal au lieu de le renforcer.

## Méthode

1. **Repérer le dossier de contenu** et le format (`content/blog`, `src/content`, `posts/`, CMS). Noter le port du dev server s'il tourne.
2. **Cartographier via un sous-agent** (Explore ou général), pour garder le contexte principal lean. Pour chaque article : slug, `title`, `category`, sujet en une phrase, 3 à 5 thèmes, et la liste des liens internes DÉJÀ présents (grep des `](/...)`).
3. **Exclure du maillage** : les traductions et reprises de texte tiers (pas de voix éditoriale propre, donc pas de liens sortants éditoriaux), et tout article hors du cluster thématique. Vérifier le champ `category`. Les signaler explicitement.
4. **Construire la matrice A vers B** : qui devrait citer qui, sur la base d'un lien thématique réel. Repérer les trous (article sans aucun lien sortant) et privilégier la réciprocité sur les paires fortes (si A lie B, B gagne souvent à lier A).
5. **Pour chaque opportunité retenue** : la section et la phrase exactes où insérer, la raison du lien, un anchor descriptif varié.
6. **Appliquer** en insérant le lien dans une phrase existante du flux, pas dans un bloc « À lire aussi » plaqué (sauf si le template du site en gère un, séparément).

## Règles

- **2 à 4 liens internes par article** au total, existants compris. Densité utile, pas spam.
- **Lien contextuel ou rien.** Pas de rapport thématique réel, pas de lien.
- **Anchors descriptifs et variés** : décrire la cible (« reprendre une base abandonnée par son prestataire »), jamais « cliquez ici », jamais l'exact-match du mot-clé répété d'un lien à l'autre.
- **Insérer dans le texte**, en prolongeant une phrase, pas en collant un paragraphe artificiel.
- **Vérifier que le slug cible existe** avant de lier (pas de lien mort).
- **Respecter les conventions du repo** : apostrophe, zéro tiret cadratin, registre, et les cibles que le projet veut éviter (ex : certaines marques ou pages exclues du corps, à vérifier dans les préférences du repo).
- **Réciprocité quand elle est naturelle**, jamais mécanique sur toutes les paires.

## Vérification

Après application, sur chaque fichier touché :

```bash
# liens internes existants, tous articles
grep -noE '\]\(/[^)]+\)' content/blog/*.mdx

# rendu + liens blog sortants d'un article (dev server lancé)
curl -s http://localhost:<port>/blog/<slug> -o /tmp/x.html -w "%{http_code}\n"
grep -oE 'href="/blog/[a-z-]+"' /tmp/x.html | sort -u

# aucun tiret cadratin introduit (doit ne rien lister)
grep -lE '—|–' content/blog/<slug>.mdx
```

Contrôle final : chaque article du cluster (hors exclusions) est atteignable, les trous sont comblés, tous les fichiers modifiés rendent en HTTP 200, et aucun cadratin n'a été introduit.

## Erreurs courantes

| Symptôme | Correction |
|---|---|
| Lien forcé entre deux articles sans rapport | Supprimer, ne mailler que les paires thématiques réelles |
| Bloc « Articles liés » plaqué en fin de texte | Insérer le lien dans une phrase du flux |
| Anchor « cliquez ici » ou exact-match répété | Anchor descriptif qui résume l'article cible, varié |
| Traduction qui reçoit/émet des liens éditoriaux | Exclure les `category: Traduction` du maillage |
| Article surchargé (5+ liens dans une section) | Plafonner à 2-4 liens utiles par article |
| Lien vers un slug inexistant | Vérifier le slug cible avant d'écrire le lien |
