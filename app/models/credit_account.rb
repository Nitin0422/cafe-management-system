# frozen_string_literal: true

class CreditAccount < ApplicationRecord
  include Attributable

  enum :status, { active: 0, suspended: 1 }

  belongs_to :user
  has_many :tab_payments, dependent: :destroy

  validates :user, presence: true
  validates :user_id, uniqueness: true
  validates :status, inclusion: { in: statuses.keys }

  # Ledger-derived outstanding balance: everything charged to the tab
  # (closed tab orders) minus everything paid against it. The denormalized
  # balance_cents column is maintained atomically by the credit flow tasks
  # (T10/T12); this method exists for verification and reporting.
  def outstanding_balance
    charged_amount - paid_amount
  end

  private

  def charged_amount
    Order.where(customer_id: user_id, status: :closed, closure_type: :tab).sum(:total_cents)
  end

  def paid_amount
    tab_payments.sum(:amount_cents)
  end
end
