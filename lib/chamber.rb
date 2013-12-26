require 'singleton'
require 'forwardable'
require 'yaml'
require 'hashie/mash'

class Chamber
  include Singleton

  class << self
    extend Forwardable

    def_delegators :instance, :load,
                              :basepath,
                              :[]

    alias_method :env, :instance
  end

  attr_accessor :basepath,
                :settings

  def load(options)
    self.basepath = options.fetch(:basepath)

    load_file(self.basepath + 'settings.yml')
  end

  def method_missing(name, *args)
    settings.public_send(name, *args) if settings.respond_to?(name)
  end

  def respond_to_missing(name)
    settings.respond_to?(name)
  end

  private

  def basepath=(pathlike)
    @basepath = Pathname.new(File.expand_path(pathlike))
  end

  def load_file(file_path)
    file_contents = File.read(file_path.to_s)
    yaml_contents = YAML.load(file_contents)

    settings.merge! yaml_contents
  end

  def settings
    @settings ||= Hashie::Mash.new
  end
end
