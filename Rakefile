($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'rat'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

begin
  require 'echoe'
  
  namespace :echoe do
    Echoe.new('rat', Rat::VERSION) do |g|
      g.author = ['elliottcable']
      g.email = ['rat@elliottcable.com']
      g.summary = 'Flexible terminal messaging (IM/IRC) client'
      g.url = 'http://github.com/elliottcable/rat'
      g.dependencies = ['stringray >=2', 'ncurses']
      g.manifest_name = '.manifest'
      g.ignore_pattern = ['.git', 'meta', 'logs', 'stringray.gemspec']
    end
  
    desc 'tests packaged files to ensure they are all present'
    task :verify => :package do
      # An error message will be displayed if files are missing
      if system %(ruby -e "require 'rubygems'; require 'merb-core'; require 'pkg/merb_strokedb-#{Rat::VERSION}/lib/merb_strokedb'")
        puts "\nThe library files are present"
      end
    end

    task :copy_gemspec => [:package] do
      pkg = Dir['pkg/*'].select {|dir| File.directory? dir}.last
      mv File.join(pkg, pkg.gsub(/^pkg\//,'').gsub(/\-\d+$/,'.gemspec')), './'
    end

    desc 'builds a gemspec as GitHub wants it'
    task :gemspec => [:package, :copy_gemspec, :clobber_package]

    # desc 'Run specs, clean tree, update manifest, run coverage, and install gem!'
    desc 'Clean tree, update manifest, and install gem!'
    task :magic => [:clean, :manifest, :install]
  end
  
  task :manifest => [:'echoe:manifest']
  
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
ensure
  task :default # No effect # Invisible

  # Runs specs, generates rcov, and opens rcov in your browser.
  namespace :rcov do
    Spec::Rake::SpecTask.new(:run) do |t|
      t.spec_opts = ["--format", "specdoc", "--colour"]
      t.spec_files = Dir['spec/**/*_spec.rb'].sort
      t.libs = ['lib']
      t.rcov = true
      t.rcov_opts = ['--exclude-only', '".*"', '--include-file', '^lib']
      t.rcov_dir = 'meta' / 'coverage'
    end

    Spec::Rake::SpecTask.new(:plain) do |t|
      t.spec_opts = ["--format", "specdoc"]
      t.spec_files = Dir['spec/**/*_spec.rb'].sort
      t.libs = ['lib']
      t.rcov = true
      t.rcov_opts = ['--exclude-only', '".*"', '--include-file', '^lib']
      t.rcov_dir = 'meta' / 'coverage'
    end

    RCov::VerifyTask.new(:verify) do |t|
      t.threshold = 75
      t.index_html = 'meta' / 'coverage' / 'index.html'
      t.require_exact_threshold = false
    end

    task :open do
      system 'open ' + 'meta' / 'coverage' / 'index.html' if PLATFORM['darwin']
    end
  end
  
  namespace :git do
    task :status do
      `git status`
    end
  end

  desc 'Check everything over before commiting'
  task :aok => [:'echoe:manifest', :'rcov:run', :'rcov:verify', :'rcov:open', :'git:status']

  # desc 'Task run during continuous integration' # Invisible
  task :cruise => [:'rcov:plain', :'rcov:verify', :'rcov:ratio']
end