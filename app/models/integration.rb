# frozen_string_literal: true

class Integration < ApplicationRecord
  has_many :mapping_rules
  validates :name, presence: true
end
