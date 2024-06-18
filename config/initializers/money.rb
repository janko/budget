require "money"

Money.default_currency = Money::Currency.new("CZK")
Money.locale_backend = :currency
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
