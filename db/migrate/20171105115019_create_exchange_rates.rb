
class CreateExchangeRates < ActiveRecord::Migration[5.0]
  def change
    create_table :exchange_rates do |t|
      t.date :on
      t.decimal :rate
      t.index :on, unique: true
      t.timestamps
    end
  end
end
