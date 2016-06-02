# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class DomainDirectory
    include ActiveModel::Model

    class LoadingError < StandardError
    end

    attr_accessor :domains

    delegate :size, :[], to: :domains

    def self.load(file)
      json = begin
        ActiveSupport::JSON.decode File.read(file)
      rescue JSON::ParserError, Errno::ENOENT => e
        raise LoadingError.new(e)
      end

      ds = json['domains'].flat_map do |j|
             d = TiSqlegalize::Domain.new(j)
             d.valid? ? [d] : []
           end

      new(domains: Hash[ds.map { |d| [d.id, d] }])
    end

    def initialize(attributes={})
      super
      @domains ||= {}
    end
  end
end
