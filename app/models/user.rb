# frozen_string_literal: true

class User < ApplicationRecord
  include Attributable

  has_secure_password

  # Precomputed bcrypt digest for a dummy password. Compared against when the
  # login identifier is unknown so that known- and unknown-identifier paths
  # both execute exactly one bcrypt comparison, preventing identifier
  # enumeration via response timing.
  DUMMY_PASSWORD_DIGEST = BCrypt::Password.create("dummy-password").freeze

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
  # Customers must register with both an email and a phone (T7, FR-1). Employee
  # accounts may leave phone unset, but a set phone must be unique and
  # well-formed. `allow_nil` keeps the format/length/uniqueness checks off nil
  # phones, so the customer-only presence check below is what requires a phone.
  validates :phone, uniqueness: true, allow_nil: true,
                    format: { with: /\A\+?[0-9\s\-()]+\z/ },
                    length: { in: 7..20 }
  validates :phone, presence: true, if: :customer?

  before_validation :normalize_email
  before_validation :normalize_phone

  # Look up a user by either identifier: email (case-insensitive,
  # whitespace-trimmed) or phone (whitespace-trimmed). Used by the login forms
  # so customers can sign in with email OR phone (T7, FR-7).
  def self.find_by_identifier(identifier)
    find_by(email: identifier.to_s.downcase.strip) || find_by(phone: identifier.to_s.strip)
  end

  # Authenticate by identifier (email or phone) + password. Returns the user on
  # success or nil on any failure. Performs exactly one bcrypt comparison on
  # both known and unknown identifiers via the shared dummy digest.
  def self.authenticate_identifier(identifier, password)
    user = find_by_identifier(identifier)

    authenticated =
      if user
        user.authenticate(password)
      else
        BCrypt::Password.new(DUMMY_PASSWORD_DIGEST).is_password?(password.to_s)
      end

    authenticated ? user : nil
  end

  private

  # Match the login form's normalization (sessions#create downcases and strips
  # the looked-up email) so stored emails and uniqueness checks are consistent.
  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  # Strip surrounding whitespace only; the internal format is preserved so
  # stored phones match what the customer typed (and later submits at login).
  def normalize_phone
    self.phone = phone.strip if phone.present?
  end
end
