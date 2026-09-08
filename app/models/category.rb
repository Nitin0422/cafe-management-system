# frozen_string_literal: true

class Category < ApplicationRecord
  include Attributable

  has_many :menu_items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
