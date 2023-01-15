require "http"
require "date"

# https://www.fio.cz/docs/cz/API_Bankovnictvi.pdf
class ImportTransactions < ApplicationService
  FIO_API_URL = "https://www.fio.cz/ib_api/rest"

  option :fio_token, Types::String
  option :from, Types::Date
  option :to, Types::Date

  def call
    transactions = fetch_transactions

    import_transactions(transactions)

    sync_expenses
  end

  private

  def sync_expenses
    new_transactions = FioTransaction
      .where{amount < 0}
      .exclude(expense: Expense.dataset)

    values = new_transactions.map do |transaction|
      {
        fio_transaction_id: transaction.id,
        description: transaction.message || transaction.note,
        amount: -transaction.amount,
        date: transaction.date,
      }
    end

    DB[:expenses].multi_insert(values, commit_every: 1000)
  end

  def import_transactions(transactions)
    values = transactions.map do |transaction|
      {
        external_id: transaction.fetch("ID pohybu"),
        amount: transaction.fetch("Objem"),
        date: Date.parse(transaction.fetch("Datum")),
        account: transaction["Protiúčet"] ? [transaction.fetch("Protiúčet"), transaction["Kód banky"]].compact.join(" / ") : nil,
        message: transaction["Zpráva pro příjemce"],
        note: transaction["Komentář"],
        type: transaction.fetch("Typ"),
      }
    rescue KeyError
      p transaction
      raise
    end

    DB[:fio_transactions].insert_ignore.multi_insert(values, commit_every: 1000)
  end

  def fetch_transactions
    transactions = request_transactions
    transactions.map do |transaction|
      transaction.values.each_with_object({}) do |col, result|
        result[col.fetch("name")] = col.fetch("value") if col
      end
    end
  end

  def request_transactions
    response = HTTP.get("#{FIO_API_URL}/periods/#{fio_token}/#{from}/#{to}/transactions.json")

    fail response.body.to_s unless response.status.ok?

    data = response.parse(:json)
    data["accountStatement"]["transactionList"]["transaction"]
  end
end
