class Expense < Sequel::Model
  many_to_one :category
  many_to_one :fio_transaction

  dataset_module do
    def similar(expense)
      if expense.fio_transaction&.account
        where(fio_transaction: FioTransaction.where(account: expense.fio_transaction.account))
      elsif !expense.description.to_s.empty?
        where(description: expense.description)
      else
        nullify
      end
    end
  end

  def self.last_updated
    reverse(:updated_at).first
  end
end
