class Expense < Sequel::Model
  many_to_one :category
  many_to_one :fio_transaction

  def self.last_updated
    reverse(:updated_at).first
  end
end
