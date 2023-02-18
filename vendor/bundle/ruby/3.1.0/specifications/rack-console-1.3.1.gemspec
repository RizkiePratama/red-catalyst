# -*- encoding: utf-8 -*-
# stub: rack-console 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-console".freeze
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Celis".freeze]
  s.date = "2014-09-04"
  s.description = "Find yourself missing a `rails console` analogue in your other Ruby web\napplications? This lightweight gem provides a Rack::Console that will load\nyour Rack application's code and environment into an IRB or Pry session.\nEither use `Rack::Console.start` directly, or run the provided `rack-console`\nexecutable.\n".freeze
  s.email = ["me@davidcel.is".freeze]
  s.executables = ["rack-console".freeze]
  s.files = ["bin/rack-console".freeze]
  s.homepage = "https://github.com/davidcelis/rack-console".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.26".freeze
  s.summary = "`rails console` for your Rack applications".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rack>.freeze, [">= 1.1"])
    s.add_runtime_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.1"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
  end
end
