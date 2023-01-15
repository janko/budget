Sequel.migration do
  change do
    alter_table :expenses do
      drop_foreign_key [:category_id]
      add_foreign_key [:category_id], :categories, on_delete: :set_null
    end
  end
end
