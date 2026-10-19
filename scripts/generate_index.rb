#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'date'
require 'cgi'

CONTENT_DIR = 'content'
INDEX_FILE = "#{CONTENT_DIR}/_index.md"
INDEX_FILE_EN = "#{CONTENT_DIR}/_index.en.md"
FRONTMATTER_DELIMITER = '---'
TAG_TAXONOMY = YAML.safe_load_file('data/tag_taxonomy.yml')
ALLOWED_TAGS = {
  pt: TAG_TAXONOMY.fetch('tags').values.map { |values| values.fetch('pt') },
  en: TAG_TAXONOMY.fetch('tags').values.map { |values| values.fetch('en') }
}.transform_values(&:freeze).freeze

# Homepage theme cards. Adjust the tag slug here if a theme's target tag changes.
THEME_CARDS = [
  { pt: '✈️ Aviação', en: '✈️ Aviation', tag_pt: 'aviacao', tag_en: 'aviation' },
  { pt: '💻 Tecnologia', en: '💻 Technology', tag_pt: 'tecnologia', tag_en: 'tech' },
  { pt: '🏆 Motivação', en: '🏆 Motivation', tag_pt: 'motivacao', tag_en: 'motivation' }
].freeze

def escape_markdown(text)
  text.to_s.gsub('[', '\\[').gsub(']', '\\]')
end

def escape_html(text)
  CGI.escapeHTML(text.to_s)
end

def tag_url(tag, lang: :pt)
  prefix = lang == :en ? '/en' : ''
  "#{prefix}/tags/#{CGI.escape(tag).gsub('+', '%20')}/"
end

def render_tag_links(tags, lang:, modifier:)
  links = tags.map do |tag|
    %(<a class="iponce-tag-link" href="#{escape_html(tag_url(tag, lang: lang))}">##{escape_html(tag)}</a>)
  end
  return '' if links.empty?

  %(<span class="iponce-post-tags iponce-post-tags--#{modifier}">#{links.join}</span>)
end

def extract_frontmatter(content)
  return nil unless content.start_with?("#{FRONTMATTER_DELIMITER}\n")

  end_index = content.index("\n#{FRONTMATTER_DELIMITER}\n", 4)
  return nil unless end_index

  yaml_content = content[4..end_index]
  YAML.safe_load(yaml_content, permitted_classes: [Date, Time])
end

def parse_post(path, lang: :pt)
  content = File.read(path)
  frontmatter = extract_frontmatter(content)
  return nil unless frontmatter&.dig('title') && frontmatter&.dig('date')

  date = DateTime.parse(frontmatter['date'].to_s)
  base_path = path.sub(%r{/index(\.en)?\.md\z}, '')
  dir_url = base_path.delete_prefix("#{CONTENT_DIR}/") # e.g. 2026/04/06/rag-esta-morto-contexto-longo

  # Honor a `slug:` frontmatter override (used by EN translations to get a
  # translated URL while keeping the original PT directory name on disk).
  if frontmatter['slug'] && !frontmatter['slug'].to_s.empty?
    slug = frontmatter['slug'].to_s
    parts = dir_url.split('/')
    parts[-1] = slug
    dir_url = parts.join('/')
  end

  url = '/' + dir_url + '/'
  url = '/en' + url if lang == :en

  has_en = File.exist?("#{base_path}/index.en.md")
  tags = Array(frontmatter['tags']).map(&:to_s)
  unknown_tags = tags - ALLOWED_TAGS.fetch(lang)
  unless unknown_tags.empty?
    raise "#{path}: unknown #{lang.to_s.upcase} tag(s): #{unknown_tags.join(', ')}. Run scripts/tag_catalog.rb --search QUERY."
  end

  {
    title: frontmatter['title'],
    description: frontmatter['description'].to_s,
    url: url,
    date: date,
    has_en: has_en,
    lang: lang,
    tags: tags
  }
rescue ArgumentError, Psych::SyntaxError => e
  warn "Error parsing #{path}: #{e.message}"
  nil
end

def collect_posts(include_future: false)
  now = DateTime.now
  Dir.glob("#{CONTENT_DIR}/**/index.md")
     .reject { |path| path == "#{CONTENT_DIR}/index.md" || path == "#{CONTENT_DIR}/_index.md" }
     .filter_map { |path| parse_post(path, lang: :pt) }
     .select { |post| include_future || post[:date] <= now }
end

def collect_posts_en(include_future: false)
  now = DateTime.now
  Dir.glob("#{CONTENT_DIR}/**/index.en.md")
     .filter_map { |path| parse_post(path, lang: :en) }
     .select { |post| include_future || post[:date] <= now }
end

def group_by_month(posts)
  posts
    .sort_by { |post| post[:date] }
    .reverse
    .group_by { |post| [post[:date].year, post[:date].month] }
end

PT_MONTHNAMES = [nil, 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'].freeze

def render_months(grouped_posts, lang: :pt, show_tags: false)
  sorted_months = grouped_posts.keys.sort.reverse
  lines = []

  sorted_months.each do |(year, month)|
    month_name = lang == :pt ? PT_MONTHNAMES[month] : Date::MONTHNAMES[month]
    lines << "## #{year} - #{month_name}\n"

    grouped_posts[[year, month]].each do |post|
      line = %(- <a class="iponce-index-list__main-link" href="#{escape_html(post[:url])}" title="#{escape_html(post[:description])}">#{escape_html(post[:title])}</a>)
      line += %(<span class="iponce-index-list__description">#{escape_html(post[:description])}</span>)
      if show_tags
        tags = render_tag_links(post[:tags], lang: lang, modifier: 'index-list')
        line += tags
      end
      lines << line
    end

    lines << ''
  end

  lines
end

def render_post_card(post, lang: :pt)
  date_label = if lang == :pt
                 post[:date].strftime('%d/%m/%Y')
               else
                 post[:date].strftime('%b %-d, %Y')
               end

  <<~HTML.chomp
    <article class="iponce-post-card" title="#{escape_html(post[:description])}">
      <time class="iponce-post-card__date" datetime="#{post[:date].to_date.iso8601}">#{escape_html(date_label)}</time>
      <h3 class="iponce-post-card__title"><a class="iponce-post-card__title-link" href="#{escape_html(post[:url])}">#{escape_html(post[:title])}</a></h3>
      <p class="iponce-post-card__description">#{escape_html(post[:description])}</p>
      #{render_tag_links(post[:tags], lang: lang, modifier: 'card')}
    </article>
  HTML
end

def render_grid_months(grouped_posts, lang: :pt)
  sorted_months = grouped_posts.keys.sort.reverse
  lines = ['<div id="iponce-index-grid" class="iponce-index-grid" data-index-view="grid">']

  sorted_months.each do |(year, month)|
    month_name = lang == :pt ? PT_MONTHNAMES[month] : Date::MONTHNAMES[month]
    posts = grouped_posts[[year, month]]
    count_label = "#{posts.length} #{posts.length == 1 ? 'post' : 'posts'}"
    heading_id = "iponce-grid-#{year}-#{format('%02d', month)}"

    lines << <<~HTML.chomp
      <section class="iponce-index-month" aria-labelledby="#{heading_id}">
        <div class="iponce-index-month__header">
          <h2 id="#{heading_id}">#{escape_html("#{year} - #{month_name}")}</h2>
          <span>#{escape_html(count_label)}</span>
        </div>
        <div class="iponce-post-grid">
    HTML

    posts.each { |post| lines << render_post_card(post, lang: lang) }

    lines << <<~HTML.chomp
        </div>
      </section>
    HTML
  end

  lines << '</div>'
  lines << ''
  lines
end

def index_view_labels(lang)
  if lang == :pt
    { list: 'Lista', grid: 'Grade', group: 'Visualização dos posts' }
  else
    { list: 'List', grid: 'Grid', group: 'Post view' }
  end
end

def render_index_view_toggle(lang: :pt)
  labels = index_view_labels(lang)

  [
    %({{< index-view-toggle list="#{labels[:list]}" grid="#{labels[:grid]}" label="#{labels[:group]}" >}}),
    ''
  ]
end

def render_index_views(grouped_posts, lang: :pt)
  lines = []

  lines << '{{% index-list %}}'
  lines.concat(render_months(grouped_posts, lang: lang, show_tags: true))
  lines << '{{% /index-list %}}'
  lines << ''
  lines.concat(render_grid_months(grouped_posts, lang: lang))
  lines
end

def render_theme_cards(lang: :pt)
  lines = ['<div class="iponce-theme-cards">']

  THEME_CARDS.each do |theme|
    title = lang == :pt ? theme[:pt] : theme[:en]
    tag = lang == :pt ? theme[:tag_pt] : theme[:tag_en]
    lines << %(  <a class="iponce-theme-card" href="#{escape_html(tag_url(tag, lang: lang))}">#{escape_html(title)}</a>)
  end

  lines << '</div>'
  lines << ''
  lines
end

def generate_index(grouped_posts)
  lines = ["#{FRONTMATTER_DELIMITER}\ntitle: Igor Ponce\n#{FRONTMATTER_DELIMITER}\n"]
  lines.concat(render_theme_cards(lang: :pt))
  lines.concat(render_index_view_toggle(lang: :pt))
  lines.concat(render_index_views(grouped_posts, lang: :pt))
  lines.join("\n")
end

def generate_index_en(grouped_posts)
  lines = ["#{FRONTMATTER_DELIMITER}\ntitle: Igor Ponce\n#{FRONTMATTER_DELIMITER}\n"]
  lines.concat(render_theme_cards(lang: :en))
  if grouped_posts.empty?
    lines << "_No posts translated to English yet. Check back soon._\n"
  else
    lines.concat(render_index_view_toggle(lang: :en))
    lines.concat(render_index_views(grouped_posts, lang: :en))
  end
  lines.join("\n")
end

include_future = ARGV.include?('--future')
posts = collect_posts(include_future: include_future)
grouped = group_by_month(posts)

File.write(INDEX_FILE, generate_index(grouped))
count = grouped.values.flatten.size
puts "Generated #{INDEX_FILE} with #{count} posts.#{' (including future posts)' if include_future}"

posts_en = collect_posts_en(include_future: include_future)
grouped_en = group_by_month(posts_en)

File.write(INDEX_FILE_EN, generate_index_en(grouped_en))
count_en = grouped_en.values.flatten.size
puts "Generated #{INDEX_FILE_EN} with #{count_en} posts."
