class FioTransaction < Sequel::Model
  one_to_one :expense
end
