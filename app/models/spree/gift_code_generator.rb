module Spree
  class GiftCodeGenerator

    # First, check if user of gem has override lexicon file. If not, fall back
    # on the one in this gem.
    def initialize
      file_location = Rails.root.join("db", "lexicon.yml")
      file_location = File.dirname(__FILE__) + '/../../../db/lexicon.yml' unless File.exist?(file_location)
      @@dictionary = YAML.load( File.open(file_location) )
    end

    def generate
      "#{adverb} #{adjective} #{noun}"
    end

    private
      def adverb
        adverbs = @@dictionary["adverbs"]
        adverbs[ rand(adverbs.length) ]
      end

      def adjective
        adjectives = @@dictionary["adjectives"]
        adjectives[ rand(adjectives.length) ]
      end

      def noun
        nouns = @@dictionary["nouns"]
        nouns[ rand(nouns.length) ]
      end
  end
end