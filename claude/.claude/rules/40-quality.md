# Code quality

- **TS strict** : protéger accès `arr[0]` undefined.
- **Zod** : gérer edge cases `parse` vs `safeParse`.
- **SSR** : compat libs client-only (ex: `immediatelyRender: false` Tiptap).
- **Jamais** avaler les erreurs dans catch → logger ou re-throw.
- **Next.js** : jamais wrapper `redirect()` en try/catch (`NEXT_REDIRECT` doit propager).

## UI
- Figma/screenshots = **référence absolue**. Pixel-perfect ou c'est faux.
- Contrainte technique empêche ? Signaler AVANT d'implémenter.
- **shadcn = la brique de base.** Un `<button>`, `<input>`, `<select>`, `<dialog>` écrit à la main alors qu'une primitive shadcn existe = faux. `pnpm dlx shadcn@latest add <primitive>` puis composer.
- **Zéro style inline sauf positionnement et layout.** Autorisé : `flex`, `grid`, `gap`, `w-`, `h-`, `p-`, `m-`, `col-span`, `items-`, `justify-`. Interdit inline : couleurs, bordures, radius, ombres, typographie, états hover/focus.
- **Custom shadcn = via le thème CSS global**, jamais au point d'appel. Les variables (`--primary`, `--radius`, `--muted-foreground`...) dans le CSS global ; les variantes via `cva` dans le fichier de la primitive. Un `className="bg-blue-500"` sur un `<Button>` = faux, la couleur appartient au thème.

## Patterns DDD/Clean Arch (transversaux, tous projets)
- **No `throw` en domain/application** → return `Result<T, E>`.
- **No `null`/`undefined` pour absence** → `Option<T>`.
- **Value Objects valident via zod** dans `protected validate()`.
- **`get id()` seul getter sur aggregates** ; autres props via `entity.get('propName')`.
- **Use case = orchestre ≥ 1 aggregate avec infra**. Pas d'aggregate → `<Noun>Service` avec N méthodes, jamais "use case avec `.execute()`". Décide selon l'aggregate, pas le nombre d'I/O.
- **Aggregates owned (porteurs `userId`/`organizationId`) → `ScopedRepository<T, TScope>`**, jamais `BaseRepository<T>`. Wrong-owner = `Option.none()` (read) / `NOT_FOUND` (write), jamais `403` (leak existence). Middleware ownership ne survit pas hors HTTP (cron, queue, events) ; port-level seul est étanche.

## DDD scope
- **DDD = métier pur uniquement**. Agrégats / VOs / events / use cases réservés au cœur produit (ce que les users paient).
- **JAMAIS DDD pour** : billing, auth, feature gating, quota gating, plans, entitlements. Ces couches restent en infra pragmatique : config typée (`PLANS = {...}`) + middleware (`requireFeature()`) + hook (`useEntitlements()`).
- **Test décisif** : si la règle tient en `array.includes()`, `switch`, `count(*)`, ou un lookup config → c'est de l'infra, pas du DDD. Ratio test/code > 3x sur ce type de code = signal de sur-engineering.
- **Leçon OpenUp** : ~6 400 LOC écrites en DDD pour billing/feature-gating, ~70-75% éliminables avec config + guard (~330 LOC auraient suffi). Ne pas refaire.

## React/TS patterns (transversaux)
- **Component props = `interface`**, jamais `type` (declaration merging, IDE hover). `type` réservé aux unions / intersections / mapped / `z.infer`.
- **`void navigate(...)` dans mutation callbacks**, pas `await`. `await` garde `isPending: true` pendant la transition (bloque le submit). `await` seulement pour chaîner *après* navigation.
- **No barrel `index.ts`** dans les apps/packages. Import direct.
- **No inline comments** sauf si le WHY est non-évident (le code se documente).
