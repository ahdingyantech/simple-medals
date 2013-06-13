require 'rails/generators'
require 'rails/generators/migration'

class SimpleMedalsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  desc 'Create Simple Medals related tables.'

  self.source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def generate_migration
    migration_template 'migration.rb',
                       'db/migrate/setup_simple_medals.rb'
  end
end
