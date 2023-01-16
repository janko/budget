Sequel.migration do
  change do
    create_table :rules do
      primary_key :id

      String :field, null: false
      String :operator, null: false
      String :value, null: false

      foreign_key :category_id, :categories, on_delete: :cascade
      boolean :ignore
    end
  end
end
