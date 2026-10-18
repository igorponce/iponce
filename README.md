# Igor Ponce — blog pessoal e projetos

Site estático em Hugo Extended, publicado em <https://iponce.com/>. O conteúdo é mantido em Markdown, com português brasileiro como idioma principal e inglês em `/en/`. Não há banco de dados, CMS hospedado, chave de API ou serviço de comentários.

## Começar a escrever

1. Instale Hugo Extended 0.161.1 ou use Docker.
2. Crie um rascunho:

   ```sh
   ./scripts/dev.sh new-post "Título do artigo"
   ```

   O comando funciona sem Docker e cria um arquivo em `content/AAAA/MM/DD/slug/index.md` como rascunho (`draft: true`).
3. Escreva o artigo, preencha uma descrição concreta, escolha tags existentes em `TAGGING.md` e mantenha `draft: true` enquanto revisa.
4. Para publicar, mude `draft` para `false`. A tradução em inglês é opcional; quando existir, salve-a como `index.en.md` ao lado do artigo em português.
5. Faça commit e push para `master`. O GitHub Actions valida as tags, gera os índices, compila e publica o site automaticamente.

Antes do push, você pode validar e regenerar os índices localmente:

   ```sh
   ruby scripts/tag_catalog.rb --check
   ruby scripts/generate_index.rb
   ```

Posts existentes devem ser editados nas duas línguas quando houver os dois arquivos. Os índices da página inicial são gerados; não os edite manualmente.

### Desenvolvimento local

Com Docker:

```sh
./scripts/dev.sh start
# http://localhost:1313
./scripts/dev.sh stop
```

Com Hugo e Ruby instalados:

```sh
ruby scripts/generate_index.rb
hugo server --disableFastRender -p 1313
```

Build local de produção:

```sh
ruby scripts/tag_catalog.rb --check
ruby scripts/generate_index.rb
hugo --minify --cleanDestinationDir
```

## Idiomas

Português fica em `/`; inglês fica em `/en/`. Na primeira visita à raiz, o site escolhe português se o idioma preferido do navegador começar com `pt` e inglês nos demais casos. A escolha explícita no seletor de idioma é lembrada no navegador. A detecção usa as preferências do navegador, sem geolocalização, cookies de terceiros ou chamadas a APIs externas.

Para traduzir uma página, crie o arquivo `.en.md` correspondente e mantenha `translationKey` igual entre os idiomas. O seletor só ativa o idioma quando a tradução daquela página existe.

## Vitrine de projetos

As páginas [Projetos](/projects/) e [Projects](/en/projects/) usam o catálogo bilíngue em `data/projects.yml`. Para adicionar um projeto, inclua nome, descrição em `pt-br` e `en` e, se existir, o link oficial em `url`. Não adicione endereços ou funcionalidades que ainda não foram confirmados.

## Publicação no GitHub Pages

O workflow `.github/workflows/pages.yaml` publica cada push para `master`; também pode ser iniciado manualmente pela aba **Actions**. Não são necessários tokens ou segredos de terceiros.

Configuração inicial do repositório:

1. Em **Settings → Pages**, selecione **GitHub Actions** como origem do deploy.
2. Confirme que `master` é a branch padrão.
3. Configure o domínio personalizado `iponce.com` no GitHub Pages e o DNS com um registro `CNAME` de `www` para `igorponce.github.io`.
4. O arquivo `static/CNAME` já é copiado para o artefato publicado. Configure o domínio raiz `iponce.com` no provedor DNS para apontar ao GitHub Pages ou redirecioná-lo para `iponce.com`, conforme os recursos do provedor.

Cada build apaga os arquivos antigos de `public/` antes de gerar o site, evitando publicar páginas ou metadados que não existem mais na fonte. Não edite `public/`: é apenas saída de build.

## SEO e serviços externos

Hugo gera sitemap, robots.txt, RSS, URLs canônicas, metadados Open Graph/Twitter, dados estruturados e `hreflang` nas páginas traduzidas. Escreva uma descrição própria em cada idioma publicado e use imagens com texto alternativo. O site não carrega fontes hospedadas nem comentários de terceiros; vídeos incorporados do YouTube só fazem uma conexão externa quando um artigo opta por usar o shortcode correspondente.

## Agradecimentos e créditos

Agradeço a Fabio Akita e ao trabalho publicado no AkitaOnRails, que serviu de referência e ponto de partida para este fork. Este site foi adaptado para Igor Ponce, com conteúdo, identidade e configuração próprios.

O site é gerado com [Hugo](https://gohugo.io/) e utiliza o tema [Hextra](https://github.com/imfing/hextra). Agradeço aos mantenedores e contribuidores desses projetos pelo trabalho que torna este blog possível.

## Estrutura

- `content/`: páginas e artigos em Markdown
- `data/projects.yml`: catálogo da vitrine de projetos
- `data/tag_taxonomy.yml` / `TAGGING.md`: tags controladas
- `layouts/`: templates e shortcodes
- `scripts/new_post.rb`: criação de rascunhos
- `scripts/generate_index.rb`: geração dos índices PT/EN
- `scripts/tag_catalog.rb`: busca e validação de tags
- `.github/workflows/pages.yaml`: build e publicação automática
