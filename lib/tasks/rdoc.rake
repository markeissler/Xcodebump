#
#  rdoc.rake
#
#  @author Mark Eissler (mark@mixtur.com)
#
require 'rdoc/task'

class XcodebumpRDocMarkup < RDoc::Markup::ToRdoc
  def initialize(markup = nil)
    super markup
    @markup.add_special(/\<code\>/, :TAG_OPEN_CODE)
    @markup.add_special(/\<\/code>/, :TAG_CLOSE_CODE)
    add_tag(:BLOCKQUOTE, "<blockquote>", "</blockquote>")
  end

  def wrap text
    return unless text && !text.empty?

    text_len = @width - @indent
    text_len = 20 if text_len < 20

    # wrap blockquote in tags, turn off hard wrap
    #
    # if !@prefix.nil? && @prefix.match(/^\>/)
    #   @res << "<blockquote>#{text}</blockquote>"
    #   @res << "\n"
    #   @prefix = nil
    #   return @res
    # end

    # preserve double new lines, except in blockquotes
    if text.match(/^(?!.*\n$).*$/)
      text << "\n\n"
    end

    re = /^(.{0,#{text_len}})[ \n]/
    next_prefix = ' ' * @indent
    # prefix blockquote lines with ">" symbol, hard wrap
    if !@prefix.nil? && @prefix.match(/^\>/)
      next_prefix = "\n" + @prefix
    end

    prefix = @prefix || next_prefix
    @prefix = nil

    @res << prefix

    while text.length > text_len
      if text =~ re then
        @res << $1
        text.slice!(0, $&.length)
      else
        @res << text.slice!(0, text_len)
      end

      @res << "\n" << next_prefix
    end

    if text.empty? then
      @res.pop
      @res.pop
    else
      # byebug
      @res << text
      @res << "\n"
    end
  end

  def accept_block_quote block_quote
    @indent += 2

    block_quote.parts.each do |part|
      @prefix = '> '

      part.accept self
    end

    @indent -= 2
  end

  def handle_special_TAG_OPEN_CODE(special)
    text = special.text
    text = text.sub(/<code>/, "")
    text
  end

  def handle_special_TAG_CLOSE_CODE(special)
    text = special.text
    text = text.sub(/<\/code>/, "")
    text
  end
end


namespace :doc do
  rdoc_converted_path = 'doc/rdoc_converted'

  desc 'Generate RDoc files from markdown files'
  task :convert_rdoc_markdown, [:paths] do |t, args|
    # paths could be a single string or an array of strings
    paths = nil
    if args.paths.is_a?(::String)
      paths = [args.paths]
    elsif args.paths.is_a?(::Array)
      paths = args.paths
    else
      raise ArgumentError, "invalid argument specified: #{paths.class.to_s}"
    end

    for path in paths do
      if path.nil? || path.strip.empty?
        raise ArgumentError, "invalid path specified for markdown file: undefined"
      end
      path_extension = File.extname(path)
      if path_extension != '.md' && path_extension != '.markdown'
        raise ArgumentError, "invalid input file specified, must be markdown format"
      end
      expanded_path = File.expand_path(path)
      markdown_content = File.open(expanded_path, 'r+'){ |file| file.read }
      # formatter = RDoc::Markup::ToHtml.new(RDoc::Options.new, nil)
      formatter = XcodebumpRDocMarkup.new(nil)
      rdoc_content = RDoc::Markdown.parse(markdown_content).accept(formatter)

      # write converted file
      filename_rdoc = File.basename(path, '.*') + '.rdoc'
      filename_path = [rdoc_converted_path, filename_rdoc].join('/')
      FileUtils.mkdir_p(rdoc_converted_path) unless File.directory?(rdoc_converted_path)
      File.open(filename_path, 'w+'){ |file| file.write(rdoc_content) }
    end
  end

  desc 'Cleanup RDoc converted markdown files'
  task :clobber_rdoc_converted do
    FileUtils.rm_r(rdoc_converted_path, { force: true, secure: true }) if File.directory?(rdoc_converted_path)
  end

  desc 'Generate ri locally for testing'
  task :ri do
    sh 'rdoc --ri -o ri .'
  end

  desc 'Remove ri products'
  task :clobber_ri do
    rm_r 'ri' rescue nil
  end

  desc 'Generate RDoc documentation'
  RDoc::Task.new do |rdoc|
    rdoc.before_running_rdoc do
      Rake::Task['doc:convert_rdoc_markdown'].invoke(['README.md', 'LICENSE.md', 'Changelog.md'])
      # Rake::Task['doc:convert_rdoc_markdown'].invoke(['LICENSE.md'])
      rdoc_files_glob = [rdoc_converted_path, '*.rdoc'].join('/')
      rdoc.rdoc_files.include(rdoc_files_glob)
    end
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.title    = "#{PKG_NAME}-#{PKG_VERSION} Documentation"
    rdoc.options << '--line-numbers' << 'cattr_accessor=object' << '--charset' << 'utf-8'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.main = [rdoc_converted_path, 'README.rdoc'].join('/')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/lib/**/*.rb')
  end

  desc 'Cleanup all RDoc generated files'
  task 'clobber' => ['doc:clobber_rdoc', 'doc:clobber_ri', 'doc:clobber_rdoc_converted']
end

