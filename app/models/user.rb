# frozen_string_literal: true

class User < ApplicationRecord
  include Attributable

  has_secure_password

  enum :role, { admin: 0, staff: 1, customer: 2 }

  scope :employees, -> { where(role: %w[admin staff]) }

  # created_by_id is NOT NULL → must not nullify on destroy.
  has_many :created_orders, class_name: "Order", foreign_key: :created_by_id, dependent: :restrict_with_error
  # closed_by_id is nullable, so nullifying is safe.
  has_many :closed_orders, class_name: "Order", foreign_key: :closed_by_id, dependent: :nullify
  has_one :credit_account, dependent: :destroy
  has_many :points_entries, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :role, inclusion: { in: roles.keys }
  validates :phone, uniqueness: true, allow_nil: true
end
