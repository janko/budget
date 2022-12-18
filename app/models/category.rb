class Category < Sequel::Model
  def self.spent_for_period(date_range)
    spending = Expense
      .where(date: date_range)
      .select_group(:category_id)
      .select_append(Sequel.function(:sum, :amount))
      .naked
      .to_a
  end
end
