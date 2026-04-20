# Code quality

- **TS strict** : protéger accès `arr[0]` undefined.
- **Zod** : gérer edge cases `parse` vs `safeParse`.
- **SSR** : compat libs client-only (ex: `immediatelyRender: false` Tiptap).
- **Jamais** avaler les erreurs dans catch → logger ou re-throw.
- **Next.js** : jamais wrapper `redirect()` en try/catch (`NEXT_REDIRECT` doit propager).

## UI
- Figma/screenshots = **référence absolue**. Pixel-perfect ou c'est faux.
- Contrainte technique empêche ? Signaler AVANT d'implémenter.
