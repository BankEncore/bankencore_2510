# spec/factories/sequences.rb (or any factory file)
FactoryBot.define do
  sequence :ein_seq do |n|
    # 9 digits, avoid leading zeros.
    base = 10_000_000 + n
    format("%09d", base % 1_000_000_000)
  end
end
