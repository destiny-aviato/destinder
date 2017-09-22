class Vote < ApplicationRecord
  scope :for_voter, ->(*args) { where(['voter_id = ? AND voter_type = ?', args.first.id, args.first.class.base_class.name]) }
  scope :for_voteable, ->(*args) { where(['voteable_id = ? AND voteable_type = ?', args.first.id, args.first.class.base_class.name]) }
  scope :recent, ->(*args) { where(['created_at > ?', (args.first || 2.weeks.ago)]) }
  scope :descending, -> { order('created_at DESC') }

  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  attr_accessible :vote, :voter, :voteable if ActiveRecord::VERSION::MAJOR < 4

  # Comment out the line below to allow multiple votes per user.
  validates :voteable_id, uniqueness: { scope: %i[voteable_type voter_type voter_id] }
end
