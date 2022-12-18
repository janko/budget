Sequel.migration do
  up do
    extension :pg_json

    create_table :expenses do
      primary_key :id
      foreign_key :category_id, :categories
      String :description
      Float :amount, null: false
      Date :date, null: false
      TrueClass :ignore, null: false, default: false
      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table :expenses
  end
end
