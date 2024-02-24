require_relative '../application'

module DB
  class Seed
    class << self
      def attributes_from(data)
        puts "Importing values"
        data.each do |property_json|
          property_json['values'].each do |property_json|
            Serializers::Data::PropertyValueSerializer.deserialize(property_json).save!
          end
        end
        puts "✓ Imported #{PropertyValue.count} values"

        puts "Importing properties"
        data.each do |json|
          Serializers::Data::PropertySerializer.deserialize(json).save!
        end
        puts "✓ Imported #{Property.count} properties"
      end

      def categories_from(data)
        puts "Importing #{data.count} category verticals"
        data.each do |vertical_json|
          current_vertical = vertical_json.first.fetch("name")
          puts "  → #{current_vertical}"

          # create all categories
          failed_category_ids = []
          categories = vertical_json.filter_map do |category_json|
            begin
              category = Serializers::Data::CategorySerializer.deserialize(category_json.except("children_ids"))
              category.save!
              category
            rescue => _e
              puts "  ⨯ Failed to import category: #{category_json["name"]} <#{category_json["id"]}>"
              failed_category_ids << category_json["id"]
              next
            end
          end

          # assemble the tree
          categories.zip(vertical_json).each do |category, json|
            category.child_ids = json["children_ids"] - failed_category_ids
            category.save!
          end
        end
        puts "✓ Imported #{Category.count} categories"
      end
    end
  end
end
