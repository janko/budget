class Expense < Sequel::Model
  many_to_one :category
  many_to_one :fio_transaction

  def self.last_updated
    reverse(:updated_at).first
  end

  def apply_rules(rules)
    rules.each do |rule|
      rule.apply(self) if rule.matches_expense?(self)
    end
  end
end
