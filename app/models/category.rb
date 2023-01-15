class Category < Sequel::Model
  def self.monthly_breakdown
    Expense
      .select_group(
        Sequel.extract(:year, :date).cast(Integer).as(:year),
        Sequel.extract(:month, :date).cast(Integer).as(:month),
        :category_id,
      )
      .exclude(:ignore)
      .select_append(Sequel.function(:sum, :amount).as(:total))
      .reverse(:year, :month)
      .naked
      .to_a
  end
end
