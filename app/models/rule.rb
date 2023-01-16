class Rule < Sequel::Model
  many_to_one :category

  def matching_expenses
    Expense
      .where(category_id: nil)
      .where(Sequel.like(field.to_sym, "%#{value}%"))
  end

  def matches_expense?(expense)
    return false if expense.category_id
    return false if ignore && expense.fio_transaction_id.nil?

    expense.send(field).to_s.include?(value)
  end

  def apply_all
    matching_expenses.each do |expense|
      apply(expense)
    end
  end

  def apply(expense)
    if category_id
      expense.update(category_id: category_id)
    elsif ignore
      expense.update(ignore: ignore)
    end
  end
end
