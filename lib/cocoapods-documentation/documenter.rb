require 'jazzy'
require 'pathname'
require 'uri'

module CocoaPodsDocumentation
  class Documenter
    attr_accessor :source_dir
    attr_accessor :output_dir
    attr_reader   :local
    alias_method  :local?, :local

    def initialize(spec, local)
      @spec = spec
      @local = local
      @output_dir = Pathname.pwd + 'docs'
    end

    def document!
      download_pod unless local
      check_source_files
      config = jazzy_config
      Dir.chdir(source_dir) do
        Jazzy::DocBuilder.build(config)
      end
    end

    private

    def download_pod
      require 'tmpdir'
      @source_dir = Dir.mktmpdir
      downloader = Downloader.for_target(@source_dir, spec.source)
      UI.title "Downloading pod from #{downloader.url}" do
        downloader.download
      end
    end

    def file_accessor
      @file_accessor ||= begin
        consumer = spec.consumer(spec.available_platforms.first)
        Sandbox::FileAccessor.new(source_dir, consumer)
      end
    end

    def check_source_files
      source_files = file_accessor.source_files
      swift_files, non_swift_files = source_files.partition { |f| f.extname == 'swift' }
      UI.puts 'No swift files were found to document' if swift_files.empty?
      UI.puts 'Non-swift source files were found, which cannot be documented at this time' unless non_swift_files.empty?
    end

    def jazzy_config
      Jazzy::Config.new.tap do |config|
        config.author_name        = spec.authors.join(', ')
        config.author_url         = spec.social_media_url
        config.github_file_prefix = github_file_prefix
        config.github_url         = github_url
        config.module_name        = spec.name
        config.output             = output_dir
      end
    end

    def github_file_prefix
      if url = spec.source[:url]
        if url =~ %r{github.com[:/]+(.+)/(.+)}
          org, repo = Regexp.last_match
          if org && repo
            repo.sub!(/\.git$/, '')
            if rev = spec.source[:tag] || spec.source[:commit]
              "https://github.com/#{org}/#{repo}/blob/#{rev}"
            end
          end
        end
      end
    end

    def github_url
      homepage = spec.homepage
      if homepage && homepage =~ URI.regexp && URI.parse(homepage).hostname.end_with?('github.com')
        homepage
      end
    end
  end
end
