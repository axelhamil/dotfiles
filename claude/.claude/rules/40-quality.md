# Code quality

- **TS strict** : protéger accès `arr[0]` undefined.
- **Zod** : gérer edge cases `parse` vs `safeParse`.
- **SSR** : compat libs client-only (ex: `immediatelyRender: false` Tiptap).
- **Jamais** avaler les erreurs dans catch → logger ou re-throw.
- **Next.js** : jamais wrapper `redirect()` en try/catch (`NEXT_REDIRECT` doit propager).

## UI
- Figma/screenshots = **référence absolue**. Pixel-perfect ou c'est faux.
- Contrainte technique empêche ? Signaler AVANT d'implémenter.

## DDD scope
- **DDD = métier pur uniquement**. Agrégats / VOs / events / use cases réservés au cœur produit (ce que les users paient).
- **JAMAIS DDD pour** : billing, auth, feature gating, quota gating, plans, entitlements. Ces couches restent en infra pragmatique : config typée (`PLANS = {...}`) + middleware (`requireFeature()`) + hook (`useEntitlements()`).
- **Test décisif** : si la règle tient en `array.includes()`, `switch`, `count(*)`, ou un lookup config → c'est de l'infra, pas du DDD. Ratio test/code > 3x sur ce type de code = signal de sur-engineering.
- **Leçon OpenUp** : ~6 400 LOC écrites en DDD pour billing/feature-gating, ~70-75% éliminables avec config + guard (~330 LOC auraient suffi). Ne pas refaire.
