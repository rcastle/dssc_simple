
gem_name = 'dssc_simple'
require File.join( File.dirname(__FILE__), 'lib', gem_name )

Gem::Specification.new do |s|
  s.name        = gem_name
  s.version     = DsscSimple::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Castle"]
  s.email       = ["richard.castle156@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{ruby library for dssc revision control system }
  s.description = %q{ruby library for dssc revision control system.
  Binary dssc_simple_report included for short status reports modeled after 'svn status -u' 
  }

  s.files         = `git ls-files`.split("
")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("
")
  s.executables   = `git ls-files -- bin/*`.split("
").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('slop', '~> 2.3')
end
