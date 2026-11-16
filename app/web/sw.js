// Service worker de Lumière : le jeu reste jouable sans réseau.
//
// - À l'installation, on met en cache tout le jeu (liste précalculée par
//   tools/web/precache.py), sauf la narration et les bruitages, gardés au fur
//   et à mesure qu'on les écoute (pour ne pas tout télécharger d'un coup).
// - Ensuite : le cache d'abord, le réseau sinon.
//
// La version ci-dessous est remplacée à chaque construction : un nouveau jeu
// publié remplace proprement l'ancien.
const VERSION = '__LUMIERE_VERSION__';
const CACHE = `lumiere-${VERSION}`;

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    try {
      const response = await fetch('precache.json', { cache: 'no-store' });
      const files = await response.json();
      // Par petits paquets, pour ne pas saturer une connexion lente.
      for (let i = 0; i < files.length; i += 8) {
        await cache.addAll(files.slice(i, i + 8));
      }
    } catch (error) {
      console.warn('Lumière : préchargement incomplet', error);
    }
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (key.startsWith('lumiere-') && key !== CACHE) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});

// La page envoie la liste des fichiers qu'elle a déjà chargés (dont le moteur
// d'affichage adapté à ce navigateur) : on les garde, depuis le cache du navigateur.
self.addEventListener('message', (event) => {
  const urls = (event.data && event.data.keep) || [];
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    for (const url of urls) {
      if (new URL(url).origin !== self.location.origin || await cache.match(url, { ignoreSearch: true })) continue;
      try {
        const response = await fetch(url);
        if (response.ok) await cache.put(url, response);
      } catch (_) {
        // Tant pis : il sera gardé à la prochaine visite.
      }
    }
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;

  // Pages : le réseau d'abord (pour les mises à jour), la copie sinon.
  if (request.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const fresh = await fetch(request);
        const cache = await caches.open(CACHE);
        if (fresh.ok) cache.put('./', fresh.clone());
        return fresh;
      } catch (_) {
        return (await caches.match(request, { ignoreSearch: true })) ||
          (await caches.match('./')) || (await caches.match('index.html')) || Response.error();
      }
    })());
    return;
  }

  // Le reste : le cache d'abord, puis le réseau (et on garde une copie).
  event.respondWith((async () => {
    const cached = await caches.match(request, { ignoreSearch: true });
    if (cached) return cached;
    const response = await fetch(request);
    if (response.ok && response.type === 'basic') {
      const cache = await caches.open(CACHE);
      cache.put(request, response.clone());
    }
    return response;
  })());
});
