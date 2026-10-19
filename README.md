# Igor Ponce — blog pessoal e projetos

Site estático em Hugo Extended, publicado em <https://iponce.com/>. O conteúdo é mantido em Markdown, com português brasileiro como idioma principal e inglês em `/en/`. Não há banco de dados, CMS hospedado ou chave de API. Os artigos usam Disqus para comentários.

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

## Aparência

O visual editorial é definido em `assets/css/editorial.css`, com cores para os modos claro e escuro, fontes do sistema e adaptação para telas pequenas. Esse CSS é processado pelo Hugo, sem dependências ou fontes externas. A página inicial fica em `layouts/home.html`; os textos da seção de artigos estão em `i18n/pt-br.yaml` e `i18n/en.yaml`. Os índices continuam sendo gerados pelo script, sem edição manual.

O banner compacto do livro na página inicial usa `data/book.yml` para título, link e descrição nos dois idiomas. A capa fica em `assets/images/entre-ceus-e-sonhos.jpg` e é otimizada pelo Hugo para WebP; nenhuma imagem é carregada da Amazon durante a visita. Os rótulos do banner ficam nos arquivos de `i18n/`.

## Idiomas

Português fica em `/`; inglês fica em `/en/`. Na primeira visita à raiz, o site escolhe português se o idioma preferido do navegador começar com `pt` e inglês nos demais casos. A escolha explícita no seletor de idioma é lembrada no navegador. A detecção usa as preferências do navegador, sem geolocalização, cookies de terceiros ou chamadas a APIs externas.

Para traduzir uma página, crie o arquivo `.en.md` correspondente e mantenha `translationKey` igual entre os idiomas. O seletor só ativa o idioma quando a tradução daquela página existe.

## Vitrine de projetos

As páginas [Projetos](/projects/) e [Projects](/en/projects/) exibem uma vitrine responsiva a partir do catálogo bilíngue em `data/projects.yml`. Para adicionar um projeto, inclua `name`, descrições curtas em `pt-br` e `en`, `platform` (`web` ou `ios`), uma imagem local em `image` e, se existir, o link oficial em `url`. As descrições ocupam no máximo uma linha, com reticências quando necessário; o texto completo continua disponível para leitores de tela e no tooltip.

Os ícones oficiais ficam em `assets/images/projects/`; o campo `image` usa o caminho relativo a `assets/`. Hugo otimiza as imagens para WebP no build, sem buscar imagens ou dados nos sites dos projetos durante a visita. Não adicione endereços ou funcionalidades que ainda não foram confirmados.

## Publicação no GitHub Pages

O workflow `.github/workflows/pages.yaml` publica cada push para `master`; também pode ser iniciado manualmente pela aba **Actions**. Não são necessários tokens ou segredos de terceiros.

Configuração inicial do repositório:

1. Em **Settings → Pages**, selecione **GitHub Actions** como origem do deploy.
2. Confirme que `master` é a branch padrão.
3. Configure o domínio personalizado `iponce.com` no GitHub Pages e o DNS com um registro `CNAME` de `www` para `igorponce.github.io`.
4. O arquivo `static/CNAME` já é copiado para o artefato publicado. Configure o domínio raiz `iponce.com` no provedor DNS para apontar ao GitHub Pages ou redirecioná-lo para `iponce.com`, conforme os recursos do provedor.

Cada build apaga os arquivos antigos de `public/` antes de gerar o site, evitando publicar páginas ou metadados que não existem mais na fonte. Não edite `public/`: é apenas saída de build.

## SEO e serviços externos

Hugo gera sitemap, robots.txt, RSS, URLs canônicas, metadados Open Graph/Twitter, dados estruturados e `hreflang` nas páginas traduzidas. Escreva uma descrição própria em cada idioma publicado e use imagens com texto alternativo. O site não carrega fontes hospedadas. Disqus faz conexões externas apenas nas postagens com comentários habilitados; vídeos incorporados do YouTube só fazem uma conexão externa quando um artigo opta por usar o shortcode correspondente.

### Comentários

O Disqus usa o shortname próprio `iponce`, definido em `services.disqus.shortname` no `hugo.yaml`, e o template nativo do Hugo. O widget aparece abaixo dos artigos com data, não na página inicial, em Sobre ou em Projetos. Ele depende de JavaScript e pode carregar cookies e recursos de terceiros.

Para desabilitar comentários em um artigo, adicione `comments: false` ao front matter e mantenha a opção sincronizada nas traduções existentes. Para desabilitar o Disqus no site inteiro, configure `privacy.disqus.disable: true` no `hugo.yaml`.

Não altere identificadores de conversas existentes. O template respeita `disqus_identifier`, `disqus_url` e `disqus_title` quando definidos no front matter; sem esses campos, o Disqus identifica a conversa pela URL da página. Recuperar comentários antigos exige o mesmo shortname e a associação correta com as URLs ou identificadores anteriores.

Em `localhost` e `127.0.0.1`, o template nativo mostra uma mensagem de prévia em vez de carregar o Disqus. O widget completo funciona no domínio publicado, desde que `iponce.com` esteja autorizado nas configurações do Disqus.

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
