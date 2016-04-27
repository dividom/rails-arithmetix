module RailsArithmetix
  class Transaction
    #NB month == period
    attr_reader :month,
                :cost_interest,
                :recovery_capital,
                :amount,
                :cost_insurance

    attr_accessor :due_capital

    @month = @cost_interest = @recovery_capital = @due_capital = @cost_insurance = 0.00

    def initialize(month, interest,cost_insurance, recovery_capital, due_capital = 0.0, date = nil)
      @month = month
      @cost_interest = interest
      @due_capital = due_capital
      @recovery_capital = recovery_capital
      @amount = @recovery_capital
      @cost_insurance = cost_insurance
    end


    def to_s
      "#{@month} :: cost_interest: #{@cost_interest}; cost_insurance: #{@cost_insurance}; recovery_capital: #{@recovery_capital} ; due_capital: #{@due_capital}  \n"
    end
  end
end
