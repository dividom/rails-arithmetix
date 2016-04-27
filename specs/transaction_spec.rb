require_relative '../lib/rails_arithmetix/transaction.rb'
require 'rspec'


# --- Data Attributes
# @month,
# @cost_interest,
# @recovery_capital == @amount
# @due_capital,
# @cost_insurance
# TODO @date

describe RailsArithmetix::Transaction do

    describe "a basic transaction of 200000.00 at first month, whit 375 cost of interest" do

      before(:all) do
        # def initialize(month, interest, insurance_cost, recovery_capital, due_capital = 0.0, date = nil)
        @transaction = RailsArithmetix::Transaction.new(1,375.25, 12.5, 200000.0, 0, :standard)
      end

      it 'should have an recovery_capital of 200000.00' do
        expect(@transaction.amount).to eql(200000.0)
        expect(@transaction.recovery_capital).to eql(200000.0)
      end
      it 'should be the first month' do
        expect(@transaction.month).to eql(1)
      end
      it 'should have a due_capital of 0' do
        expect(@transaction.due_capital).to eql(0)
      end
      it 'should have an interest_cost of 375.25' do
        expect(@transaction.cost_interest).to eql(375.25)
      end
      it 'should have an insurance_cost of 12.35' do
        expect(@transaction.insurance_cost).to eql(12.5)
      end
    end
end
