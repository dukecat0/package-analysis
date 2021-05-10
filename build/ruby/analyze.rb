#!/usr/bin/env ruby
#
require 'find'
require 'pathname'

if ARGV.length < 1
  puts "Usage: #{$0} package version"
  exit 1
end

package = ARGV.shift
version = ARGV.shift

cmd = "gem install #{package}"
if version
  cmd += " -v #{version}"
end

if not system(cmd)
  exit 1
end

spec = Gem::Specification.find_by_name(package)

spec.require_paths.each do |require_path|
  if Pathname.new(require_path).absolute?
    lib_path = Pathname.new(require_path)
  else
    lib_path = Pathname.new(File.join(spec.full_gem_path, require_path))
  end

  Find.find(lib_path.to_s) do |path|
    if path.end_with?('.rb')
      relative_path = Pathname.new(path).relative_path_from(lib_path)

      require_path = relative_path.to_s.delete_suffix('.rb')
      puts "Loading #{require_path}"
      begin
        require require_path
      rescue Exception => e
        puts "Failed to load #{require_path}: #{e}"
      end
    end
  end
end
