# require 'rails/generators/migration'
require 'rails/generators/active_record'

module HasLineage
  class MigrationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_migration_file
      @migration_class_name = "add_has_lineage_fields_to_#{custom_file_name}"
      @table_name = custom_file_name
      migration_template "migration.rb", "db/migrate/#{@migration_class_name}"
    end

    private

      def custom_file_name
        custom_name = class_name.underscore.downcase
        custom_name = custom_name.pluralize if ActiveRecord::Base.pluralize_table_names
        custom_name
      end

  end
end