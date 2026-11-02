// Service Worker simples — permite "Adicionar à tela inicial" e guarda
// a casca do site (HTML/CSS) em cache para abrir mais rápido depois.
// Os dados (crianças, rotinas, fotos) sempre vêm do Supabase, nunca do cache.
const CACHE_NAME = 'cei-luz-aprendizagem-v1';
const ASSETS = ['./', './index.html', './manifest.json'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(names.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Nunca cacheia chamadas ao Supabase — sempre busca dado fresco da rede.
  if (event.request.url.includes('supabase.co')) return;

  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});
