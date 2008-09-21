($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'rat'
require 'rake'
require 'yard'
require 'yard/rake/yardoc_task'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'stringray/core_ext/spec/rake/verify_rcov'

begin
  require 'echoe'
  
  namespace :echoe do
    Echoe.new('rat', Rat::VERSION) do |g|
      g.author = ['elliottcable']
      g.email = ['rat@elliottcable.com']
      g.summary = 'Flexible terminal messaging (IM/IRC) client'
      g.url = 'http://github.com/elliottcable/rat'
      g.dependencies = ['stringray >=2', 'ncurses'] #, 'yard >=0.2.3'
      g.manifest_name = '.manifest'
      g.ignore_pattern = /^\.git\/|^meta\/|^logs\/|\.gemspec/
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
      t.threshold = 50
      t.index_html = 'meta' / 'coverage' / 'index.html'
      t.require_exact_threshold = false
    end

    task :open do
      system 'open ' + 'meta' / 'coverage' / 'index.html' if PLATFORM['darwin']
    end
  end
  
  namespace :yard do
    YARD::Rake::YardocTask.new :generate do |t|
      t.files   = ['lib/**/*.rb']
      t.options = ['--output-dir', "meta/documentation", '--readme', 'README.mkdn']
    end
    
    YARD::Rake::YardocTask.new :dot_yardoc do |t|
      t.files   = ['lib/**/*.rb']
      t.options = ['--no-output', '--readme', 'README.mkdn']
    end
    
    task :open do
      system 'open ' + 'meta' / 'documentation' / 'index.html' if PLATFORM['darwin']
    end
  end
  
  namespace :git do
    task :status do
      `git status`
    end
  end
  
  desc 'Check everything over before commiting'
  task :aok => [:'yard:generate', :'yard:open',
                :'echoe:manifest',
                :'rcov:run', :'rcov:verify', :'rcov:open',
                :'git:status']

  # desc 'Task run during continuous integration' # Invisible
  task :ci => [:'yard:generate', :'rcov:plain', :'rcov:verify']
end