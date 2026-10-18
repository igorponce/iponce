# Instruções para Claude Code

Leia [AGENTS.md](./AGENTS.md) para as convenções completas do blog, idioma, conteúdo, SEO e publicação.

Este é um site Hugo estático e bilíngue de Igor Ponce. Não reintroduza conteúdo, identidade, comentários ou serviços do blog de origem do fork.

Comandos de referência:

```sh
./scripts/dev.sh new-post "Título"
./scripts/dev.sh start
ruby scripts/tag_catalog.rb --check
ruby scripts/generate_index.rb
hugo --minify --cleanDestinationDir
```

Posts são publicados por push para `master`, usando `.github/workflows/pages.yaml`. Não edite `public/` nem os índices gerados manualmente. Preserve a tradução e o idioma de cada conteúdo conforme [AGENTS.md](./AGENTS.md).
