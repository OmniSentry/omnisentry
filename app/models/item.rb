class Item
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :tag_id, type: String
  field :status, type: String
  field :image, type: String
end
