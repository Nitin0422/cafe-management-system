# frozen_string_literal: true

class Order < ApplicationRecord
  include Attributable

  enum :status, { draft: 0, open: 1, closed: 2, cancelled: 3 }
  enum :closure_type, { cash: 0, card: 1, tab: 2, other: 3 }, prefix: true

  belongs_to :customer, class_name: "User", optional: true
  belongs_to :closed_by, class_name: "User", optional: true

  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :points_entries, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: statuses.keys }
  validates :closure_type, inclusion: { in: closure_types.keys }, allow_nil: true
  validates :created_by, presence: true
  # total_cents is a monetary amount; a negative order total is invalid.
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # A closed order must carry full per-staff closure attribution (FR-11):
  # how it was closed, when, and by whom.  These columns are nullable in the
  # schema (closure_type/closed_at/closed_by_id) so the requirement is enforced
  # at the model level for the `closed` status.
  with_options if: -> { status == "closed" } do
    validates :closure_type, presence: true
    validates :closed_at, presence: true
    validates :closed_by, presence: true
  end

  before_validation :generate_order_number, on: :create

  private

  def generate_order_number
    self.order_number ||= "ORD-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
