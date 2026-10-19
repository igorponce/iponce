# Instruções para agentes — Igor Ponce

Este repositório contém o blog pessoal e a vitrine de projetos de Igor Ponce, em Hugo Extended, publicados em `https://iponce.com/`. Português brasileiro é o idioma principal; inglês fica em `/en/`. O conteúdo deve refletir a experiência e os projetos de Igor, sem introduzir identidade, autoria, referências ou ativos de outros blogs.

## Objetivo do trabalho

Deixe o site pronto para manter por arquivos Markdown e YAML, compilar como site estático e publicar automaticamente pelo GitHub Pages. Prefira recursos nativos do Hugo e evite serviços, chaves, fontes remotas e chamadas externas desnecessárias. O seletor de idioma e o conteúdo devem continuar utilizáveis sem APIs externas.

## Comandos

```sh
./scripts/dev.sh new-post "Título"      # cria um rascunho, sem exigir Docker
./scripts/dev.sh start                  # servidor local com Docker
./scripts/dev.sh stop
ruby scripts/tag_catalog.rb --search "assuntos centrais"
ruby scripts/tag_catalog.rb --check
ruby scripts/generate_index.rb
hugo --minify --cleanDestinationDir
```

O workflow `.github/workflows/pages.yaml` valida tags, regenera índices e publica automaticamente cada push para `master`. `public/` é saída gerada, nunca fonte. Para testar a publicação localmente, use a mesma versão do workflow: Hugo Extended 0.161.1.

## Conteúdo

- Artigos: `content/AAAA/MM/DD/slug/index.md`; tradução inglesa opcional: `index.en.md` no mesmo diretório.
- Páginas traduzidas usam a mesma `translationKey`; o seletor só aponta para traduções existentes.
- Ao editar um artigo que já tem versão nos dois idiomas, mantenha ambas sincronizadas.
- Ao redigir artigo novo, escreva primeiro no idioma pedido e aguarde revisão antes de traduzir; não publique nem faça commit sem aprovação explícita do usuário.
- Artigo publicado precisa de título, data ISO 8601 com fuso `-03:00`, descrição concreta em cada idioma disponível, duas a quatro tags canônicas e `draft: false`.
- Gere a descrição em português a partir do texto final; traduza fielmente a descrição final para inglês. Não resuma cada versão de forma independente.
- Antes de escolher tags, consulte `TAGGING.md` com `ruby scripts/tag_catalog.rb --search "..."`; use apenas `data/tag_taxonomy.yml`. Não crie variações de idioma, grafia ou plural.
- `content/_index.md` e `content/_index.en.md` são gerados por `scripts/generate_index.rb`; nunca edite manualmente.

## Vitrine de projetos

As páginas `/projects/` e `/en/projects/` usam `data/projects.yml` através de `layouts/shortcodes/projects.html`. Adicione cada projeto uma única vez ao YAML, com descrições em `pt-br` e `en`; só inclua URL oficial quando confirmada. Não invente produtos, resultados ou links.

A vitrine usa ícones locais em `assets/images/projects/`, indicados pelo campo `image`, e `platform: web` ou `ios`. Mantenha descrições curtas, exibidas em no máximo uma linha, e preserve os textos completos para acessibilidade.

## Idioma e SEO

O idioma inicial é escolhido no navegador: `pt-*` abre português e qualquer outro idioma abre inglês. A seleção manual é persistida em cookie próprio; não use geolocalização nem redirecione páginas internas. Mantenha canonical, `hreflang`, sitemap, robots, RSS, metadados sociais e Schema.org funcionais. Páginas traduzidas devem ter descrições localizadas.

## Alterações técnicas

- Use as versões/dependências já configuradas; não instale dependências sem necessidade.
- Mantenha o visual em `assets/css/editorial.css` e os textos da interface em `i18n/`; preserve os modos claro/escuro e o layout responsivo nos dois idiomas.
- Preserve o build estático e a publicação via GitHub Actions.
- Evite incorporar serviços externos. O shortcode YouTube é opcional e só deve ser usado quando solicitado pelo conteúdo.
- O Disqus usa a conta própria `iponce`, via template nativo do Hugo, apenas nos artigos com data. Respeite `comments: false`, `privacy.disqus.disable` e os identificadores existentes das conversas; não reutilize a conta do blog de origem.
- Atualize esta documentação e `README.md` quando mudar o fluxo de publicação ou manutenção.
