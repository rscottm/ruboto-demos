# callback_reflection.rb creates the interfaces.txt (JRuby can't do YAML with ruby 1.8, so it's just
# and inspect on the hash) on a device. Bring it off the device and put it in the callback_gen dir.
#
# Move this into a rake task later.
#


require 'rake/clean'
require 'rexml/document'

generated_libs     = 'generated_libs'
jars = Dir['libs/*.jar']
stdlib             = jars.grep(/stdlib/).first #libs/jruby-stdlib-VERSION.jar
jruby_jar          = jars.grep(/core/).first   #libs/jruby-core-VERSION.jar
stdlib_precompiled = File.join(generated_libs, 'jruby-stdlib-precompiled.jar')
jruby_ruboto_jar   = File.join(generated_libs, 'jruby-ruboto.jar')
dirs = ['tmp/ruby', 'tmp/precompiled', generated_libs]
dirs.each { |d| directory d }

CLEAN.include('tmp', 'bin', generated_libs)


task :debug   => :generate_libs
task :release => :generate_libs

task :default => :debug

task :tag => :release do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag #{version}"
  sh "git push origin master --tags"
  #sh "gem push pkg/#{name}-#{version}.gem"
end

task :sign => :release do
  sh "jarsigner -keystore #{ENV['RUBOTO_KEYSTORE']} -signedjar bin/#{build_project_name}.apk bin/#{build_project_name}-unsigned.apk #{ENV['RUBOTO_KEY_ALIAS']}"
end

task :align => :sign do
  sh "zipalign 4 bin/#{build_project_name}.apk #{build_project_name}.apk"
end

task :publish => :align do
  puts "#{build_project_name}.apk is ready for the market!"
end

task :update_scripts do
  Dir['assets/scripts/*.rb'].each do |script|
    `adb push #{script} /data/data/#{package}/files/scripts`
  end
end

def manifest
  @manifest ||= REXML::Document.new(File.read('AndroidManifest.xml'))
end

def strings(name)
  @strings ||= REXML::Document.new(File.read('res/values/strings.xml'))
  value = @strings.elements["//string[@name='#{name.to_s}']"] or raise "string '#{name}' not found in strings.xml"
  value.text
end

def package() manifest.root.attribute('package') end
def version() strings :version_name end
def app_name()  strings :app_name end
def build_project_name() @build_project_name ||= REXML::Document.new(File.read('build.xml')).elements['project'].attribute(:name).value end

task :callbacks do
  ruboto_dir = "../ruboto-core/bin/"

  [
    %w(android.opengl.GLSurfaceView.Renderer GLSurfaceViewRenderer),
    %w(android.app.DatePickerDialog.OnDateSetListener),
    %w(android.app.TimePickerDialog.OnTimeSetListener),
    %w(android.hardware.SensorEventListener),
  ].each do |c, n|
    puts `#{ruboto_dir}ruboto gen interface #{c} --name Ruboto#{n ? n : c.split(".")[-1]} --force`
  end
end

