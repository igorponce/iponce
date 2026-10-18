#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'

title = ARGV.join(' ').strip
abort "Usage: ruby scripts/new_post.rb 'Post title'" if title.empty?

slug = title.downcase
             .unicode_normalize(:nfkd)
             .encode('ASCII', invalid: :replace, undef: :replace, replace: '')
             .gsub(/[^a-z0-9]+/, '-')
             .gsub(/\A-+|-+\z/, '')
abort 'The title must contain at least one ASCII letter or number.' if slug.empty?

now = Time.now.getlocal('-03:00')
post_dir = File.join('content', now.strftime('%Y/%m/%d'), slug)
post_file = File.join(post_dir, 'index.md')
abort "Post already exists: #{post_file}" if File.exist?(post_file)

FileUtils.mkdir_p(post_dir)
File.write(post_file, <<~MARKDOWN)
  ---
  title: #{JSON.generate(title)}
  date: '#{now.strftime('%Y-%m-%dT%H:%M:%S%:z')}'
  description: ""
  tags: []
  draft: true
  ---

  Escreva o rascunho do artigo aqui.
MARKDOWN

puts "Draft created: #{post_file}"
puts 'Before publishing: write a concrete description, choose canonical tags, and set draft: false.'
