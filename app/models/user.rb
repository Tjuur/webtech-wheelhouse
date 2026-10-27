class User < ApplicationRecord
  has_secure_password validations: false

  belongs_to :staff, optional: true

  has_many :sessions, dependent: :destroy

  enum :role, {
    owner: "owner",
    mechanic: "mechanic",
    counter: "counter"
  }, default: :counter

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :email_address,
    presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }

  validates :password,
    length: {
      minimum: 10,
      message: "must be at least 10 characters"
    },
    if: -> { new_record? || password.present? }

  validates :password,
    presence: true,
    on: :create

  validates :password,
    confirmation: true,
    if: -> { password.present? }
end