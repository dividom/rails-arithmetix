require_relative 'transaction'
require_relative 'finance'

module RailsArithmetix

  class Credit
    include Finance

    attr_reader :nb_month, :capital, :rate, :type, :amortization_table, :differe_duration, :insurance
    # attr_accessor :insurance


    def initialize(nb_month, capital, rate, insurance, type, differe_duration = 0)
      @nb_month = nb_month
      @capital = capital
      @rate = rate / 100.0
      @differe_duration = differe_duration
      @insurance = insurance / 100.0

      case type
      when :in_fine_partiel
        @type = type
        @amortization_table = compute_infine_partiel
      when :in_fine_total
        @type = type
        @amortization_table = compute_infine_total
      when :standard
        @type = type
        @amortization_table = compute_standard
      when :differe_partiel
        @type = type
        @amortization_table = compute_differe_partiel
      when :differe_total
        @type = type
        @amortization_table = compute_differe_total
      else
        raise "You gave me '#{type}' -- I have no idea which kind of credit is...\n => You can choose only: ':in_fine_partiel', ':differe_partiel'"
      end
    end

    # === Interest Methods Interface
    def interest
      return (@capital / 100) * @rate
    end

    def annualy_interest
      return @capital  * @rate * -1
    end

    def monthly_interest
      annualy_interest/12.0
    end

    def total_cost_interest
      total_interest = 0.0
      @amortization_table.each { |line| total_interest += line.cost_interest }
      return total_interest
    end
    # ---

    # === Interest Methods Interface
    def annualy_insurance
      return @capital  * @insurance * -1
    end
    #
    def monthly_insurance
      annualy_insurance/12.0
    end
    #
    def total_cost_insurance
      total_insurance = 0.0
      @amortization_table.each { |line| total_insurance += line.cost_insurance }
      return total_insurance
    end
    # ---


    def to_s
      puts "nb_month: #{@nb_month}; capital: #{@capital}; rate: #{@rate}; type: #{@type}"
    end



    private
      # === comput method
      # @desc: depend which kind of credit is

      def compute_infine_partiel
        #     def initialize(month, interest,cost_insurance, recovery_capital, due_capital = 0.0, date = nil)

          array = [Transaction.new(0, 0.00, 0.00, @capital)]
          for i in 1..(@nb_month - 1)
            array << Transaction.new(i, monthly_interest, monthly_insurance, 0.0, 0.00 )
          end
          array << Transaction.new(@nb_month, monthly_interest, monthly_insurance, 0.0, @capital * -1.0)
      end

      # def compute_infine_total
      #   array = [Transaction.new(0, 0.00,monthly_insurance, 0.00, @capital)]
      #   capital = @capital
      #   for month in 1..(@nb_month)
      #     interest = ipmt( @rate/12.0, 1, @nb_month, capital)
      #     capital -= interest
      #     array << Transaction.new(month,interest, monthly_insurance, capital, 0.0 )
      #   end
      #
      #   interest = ipmt( @rate/12.0, 1, @nb_month, capital)
      #   capital -= interest
      #   array << Transaction.new(@nb_month, interest,monthly_insurance, 0.00, capital)
      # end

      def compute_infine_total
        array = [Transaction.new(0, 0.00, monthly_insurance, @capital, 0.00)]
        array << Transaction.new(@nb_month, monthly_interest * @nb_month ,monthly_insurance * @nb_month, 0.00, @capital * -1)
      end

      def compute_standard
        # array = [Transaction.new(0, 0.00, 0.00, @capital)]
        array = [Transaction.new(0, 0.00, 0.00, 0.00, @capital)]

        for month in 1..(@nb_month)
          interest = ipmt( @rate/12.0, month, @nb_month, @capital)
          recovery_cap = ppmt(@rate/12.0, month, @nb_month, @capital)
          due_cap = array[month - 1].due_capital + recovery_cap

          array << Transaction.new(month,interest, monthly_insurance, recovery_cap,due_cap)
        end
          array.last.due_capital = 0
        return array
      end

      def compute_differe_partiel
        array = [Transaction.new(0, 0.00, 0.00, @capital)]
        # partiel
        for month in 1..(@differe_duration)
          array << Transaction.new(month,ipmt( @rate/12.0, 1, @nb_month, @capital),monthly_insurance, 0,  @capital)
        end

        # end partiel
        for month in 1..(@nb_month - @differe_duration)
          interest = ipmt( @rate/12.0, month, @nb_month - @differe_duration, @capital)
          recovery_cap = ppmt(@rate/12.0, month, @nb_month - @differe_duration, @capital)
          due_cap = array[(month + @differe_duration) - 1].due_capital + recovery_cap

          array << Transaction.new(month + @differe_duration, interest, monthly_insurance, recovery_cap, due_cap)
        end
          array[@nb_month].due_capital = 0
        return array
      end

      def compute_differe_total
        array = [Transaction.new(0, 0.00, 0.00, @capital)]

        #partiel
        capital = @capital
        for month in 1..(@differe_duration)
          interest = ipmt( @rate/12.0, 1, @nb_month, capital)
          capital -= interest
          array << Transaction.new(month,interest, 0, capital )
        end

        #end partiel
        for month in 1..(@nb_month - @differe_duration)
          interest = ipmt( @rate/12.0, month, @nb_month - @differe_duration, capital)
          recovery_cap = ppmt(@rate/12.0, month, @nb_month - @differe_duration, capital)
          due_cap = array[(month + @differe_duration) - 1].due_capital + recovery_cap

          array << Transaction.new(month + @differe_duration, interest, recovery_cap, due_cap)
        end
          array[@nb_month].due_capital = 0
        return array
      end



    end
end
