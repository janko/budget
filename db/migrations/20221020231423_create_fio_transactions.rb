Sequel.migration do
  change do
    create_table :fio_transactions do
      primary_key :id
      String :external_id, null: false, unique: true
      Float :amount, null: false
      Date :date, null: false
      String :account
      String :note
      String :message
      String :type
    end

    alter_table :expenses do
      add_foreign_key :fio_transaction_id, :fio_transactions, on_delete: :cascade, unique: true
    end
  end
end
