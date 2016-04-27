require_relative '../lib/rails_arithmetix/credit.rb'

# NB Comparé (entre autres) avec http://www.lacentraledeRailsArithmetixment.fr/pret-credit-immobilier/les-simulateurs-de-prets-et-de-credit-immobilier/simulateur-tableau-amortissement-de-pret-immobilier/

describe RailsArithmetix::Credit do
  # def initialize(nb_month, capital, rate, type, differe_duration = 0)

  describe "\'s in_fine_partiel" do
    before(:all) do
      @in_fine_partiel = RailsArithmetix::Credit.new(24, 50000.00, 2.35, 0.3, :in_fine_partiel)
      # puts @in_fine_partiel.amortization_table
    end

    # --- Init (at month 0)
    it ' should have a duration of 24 month' do
      expect(@in_fine_partiel.nb_month).to eql(24)
    end
    it 'should have a rate of 2.35% (== 0.0235)' do
      expect(@in_fine_partiel.rate).to eql(0.0235)
    end
    it ' should have a capital of 50000.00' do
      expect(@in_fine_partiel.capital).to eql(50000.00)
    end
    it ' should have a type of differe_partiel' do
      expect(@in_fine_partiel.type).to eql(:in_fine_partiel)
    end
    it ' should have a differe_duration of 6 months' do
      expect(@in_fine_partiel.differe_duration).to eql(0)
    end
    it 'should have an insurance of 0.3%' do
      expect(@in_fine_partiel.insurance).to eql(0.003)
    end


    # --- Methods
    it 'should have an annualy_interest of -1175' do
      expect(@in_fine_partiel.annualy_interest.round).to eql(-1175)
    end

    it 'should have an mensualy_interest of -98' do
      expect(@in_fine_partiel.monthly_interest.round).to eql(-98)
    end

    it 'should have an annualy_insurance of -150' do
      expect(@in_fine_partiel.annualy_insurance.round).to eql(-150)
    end

    it 'should have an mensualy_insurance of -12.5' do
      expect(@in_fine_partiel.monthly_insurance.round(1)).to eql(-12.5)
    end
    #
    context 'should have an amortization_table with' do
      it 'should have at first months (month == 1) an interest_cost of -11.75 with a capital of 0.00' do
        # puts @in_fine_partiel.amortization_table[1]
        expect(@in_fine_partiel.amortization_table[1].cost_interest.round).to eql(-98)
        expect(@in_fine_partiel.amortization_table[1].recovery_capital).to eql(0.00)
        expect(@in_fine_partiel.amortization_table[1].due_capital).to eql(0.00)
      end
      it 'after 6 monthsan interest_cost of -11.75 with a capital of 0.00' do
        expect(@in_fine_partiel.amortization_table[6].cost_interest.round).to eql(-98)
        expect(@in_fine_partiel.amortization_table[6].recovery_capital).to eql(0.00)
        expect(@in_fine_partiel.amortization_table[6].due_capital).to eql(0.00)
      end
      it 'should have at the last month a due capital of 50000.00' do
        expect(@in_fine_partiel.amortization_table[@in_fine_partiel.amortization_table.length - 1].cost_interest.round).to eql(-98)
        expect(@in_fine_partiel.amortization_table[@in_fine_partiel.amortization_table.length - 1].recovery_capital).to eql(0.00)
        expect(@in_fine_partiel.amortization_table[@in_fine_partiel.amortization_table.length - 1].due_capital).to eql(- 50000.00)
      end

      it 'should have a total of interest (cost) of -2 350' do
        expect(@in_fine_partiel.total_cost_interest.round).to eql(-2350)
      end

      it 'should have a total of insurance (cost) of -300' do
        expect(@in_fine_partiel.total_cost_insurance.round).to eql(-300)
      end
    end
  end

  describe "\'s in_fine_total" do
    # === DataStructure Test
    before(:all) do
      @in_fine_total =  RailsArithmetix::Credit.new(24, 50000.00, 2.35, 0.3, :in_fine_total)
      puts @in_fine_total.amortization_table
    end

    # === Computation Test
    context 'should have an amortization_table with' do
      # 0 :: cost_interest: 0.0; cost_insurance: -12.5; recovery_capital: 50000.0 ; due_capital: 0.0
      it 'at the begining a result: cost_interest: 0.0; cost_insurance: -12.5; recovery_capital: 50000.0 ; due_capital: 0.0' do
        expect(@in_fine_total.amortization_table.first.cost_interest).to eql(0.0)
        expect(@in_fine_total.amortization_table.first.recovery_capital.round(2)).to eql(50000.00)
        expect(@in_fine_total.amortization_table.first.due_capital.round(2)).to eql(0.0)
      end
      it 'at the last month a result: cost_interest: -2350.0; cost_insurance: -300.0; recovery_capital: 0.0 ; due_capital: 50000.0' do
        expect(@in_fine_total.amortization_table.last.cost_interest.round(2)).to eql(-2350.0)
        expect(@in_fine_total.amortization_table.last.cost_insurance.round(2)).to eql(-300.00)
        expect(@in_fine_total.amortization_table.last.due_capital.round(2)).to eql(- 50000.00)
      end
    end
  end
  #
  describe "\'s standard" do
    before(:all) do
      @standard =  RailsArithmetix::Credit.new(180, 50000.00, 2.35, 0.3, :standard)
    end

    # --- Init (at month 0)
    it ' should have a duration of 180 month' do
      expect(@standard.nb_month).to eql(180)
    end
    it 'should have a rate of 1.8% (== 0.018)' do
      expect(@standard.rate).to eql(0.0235)
    end
    it ' should have a capital of 50000.00' do
      expect(@standard.capital).to eql(50000.00)
    end
    it ' should have a type of differe_partiel' do
      expect(@standard.type).to eql(:standard)
    end
    it ' should have a differe_duration of 0 month' do
      expect(@standard.differe_duration).to eql(0)
    end
    it 'should have an insurance of 0.3%' do
      expect(@standard.insurance).to eql(0.003)
    end

    # --- methods
    it 'should have an insurance with a annual cost of 150' do
      expect(@standard.annualy_insurance).to eql(-150.0)
    end


    context 'should have an amortization_table with' do
      #    transaction initialize(month, interest,cost_insurance, recovery_capital, due_capital = 0.0, date = nil)

      it 'should have at first months (month == 1) an interest_cost of -11.75 with a capital of 0.00' do
        # interest_cost
        expect(@standard.amortization_table[1].cost_interest.round(2)).to eql(-97.92)
        # recovery_capital
        expect(@standard.amortization_table[1].recovery_capital.round(2)).to eql(-231.96)
        # due_capital
        expect(@standard.amortization_table[1].due_capital.round(2)).to eql(49768.04)
      end
      it 'should have after 90 months an interest cost of 53.80, a recovery capital of 276.08, a due capital of 27195.30' do
        expect(@standard.amortization_table[90].cost_interest.round(2)).to eql(-53.80)
        expect(@standard.amortization_table[90].recovery_capital.round(2)).to eql(-276.08)
        expect(@standard.amortization_table[90].due_capital.round(2)).to eql(27195.30)
      end
       it 'should have at the last month: an interest cost of 0.64, a recovery capital of 329.23, a due capital of 0.00' do
        expect(@standard.amortization_table[@standard.amortization_table.length - 1].cost_interest.round(2)).to eql(-0.64)
        expect(@standard.amortization_table[@standard.amortization_table.length - 1].recovery_capital.round(2)).to eql(-329.23)
        expect(@standard.amortization_table[@standard.amortization_table.length - 1].due_capital.round(2)).to eql(0.00)
      end

      it 'should have a total of interest (cost) of -9377.6' do
        expect(@standard.total_cost_interest.round(2)).to eql(-9377.6)
      end
      #
      it 'should have a total of insurance (cost) of -3000' do
        expect(@standard.total_cost_insurance.round).to eql(-2250)
      end
    end
  end
  #
  describe "\'s differe_partiel" do
    before(:all) do
      @standard =  RailsArithmetix::Credit.new(180, 50000.00, 2.35, 0.3, :differe_partiel, 6)
      # puts @standard.amortization_table
    end
    # --- Init (at month 0)

    it ' should have a type of differe_partiel' do
      expect(@standard.type).to eql(:differe_partiel)
    end
    it ' should have a differe_duration of 6 months' do
      expect(@standard.differe_duration).to eql(6)
    end

    # --- methods
    it 'should have an insurance with a annual cost of 150' do
      expect(@standard.annualy_insurance).to eql(-150.0)
    end

    it 'should have an insurance with a monthly cost of 12.5' do
      expect(@standard.monthly_insurance).to eql(-12.5)
    end


    context 'should have an amortization_table with' do
      it 'after 1 month a result of  an interest cost of 98, a recovery capital of 0.00, a due capital of 0.00' do
        expect(@standard.amortization_table[1].cost_interest.round(2)).to eql(-97.92)
        expect(@standard.amortization_table[1].recovery_capital).to eql(0)
        expect(@standard.amortization_table[1].due_capital).to eql(50000.0)
      end
      # 90 :: cost_interest: -55.34624624517698; cost_insurance: -12.5; recovery_capital: -284.02204322602034 ; due_capital: 27977.890933033977
      it 'after 90 months a result of an interest cost of -55.35, a recovery capital of -284.02, a due capital of 27977.89' do
        expect(@standard.amortization_table[90].cost_interest.round(2)).to eql(-55.35)
        expect(@standard.amortization_table[90].recovery_capital.round(2)).to eql(-284.02)
        expect(@standard.amortization_table[90].due_capital.round(2)).to eql(27977.89)
      end
      # 180 :: cost_interest: -0.6632972763815133; cost_insurance: -12.5; recovery_capital: -338.7049921948158 ; due_capital: 0
      it 'at the last month a result of x'  do
        expect(@standard.amortization_table.last.cost_interest.round(2)).to eql(-0.66)
        expect(@standard.amortization_table.last.recovery_capital.round(2)).to eql(-338.70)
        expect(@standard.amortization_table.last.due_capital.round(2)).to eql(0.0)
      end
    end
  end

  # @TODO
  # ex: http://www.capvie.com/amortissement-emprunt.php
  describe "\'s differe_total" do
    before(:all) do
      @standard =  RailsArithmetix::Credit.new(180, 128000.00, 2.45, 0.3, :differe_total, 27)
    end
      # montant: 128000€
      # taux nominal: 2.45%
      # durée amoritssement: 180 mois
      # assurance 0.3%

    context 'should have an amortization_table with' do
      # # 1 :: cost_interest: -261,33; cost_insurance: -32; recovery_capital: 0 ; due_capital: 128000.0

      it 'after 1 month a result of  an interest cost of 261,33, cost insurance: 32, a recovery capital of 0.00, a due capital of 0.00' do
        expect(@standard.amortization_table[1].cost_interest.round(2)).to eql(-261.33)
        expect(@standard.amortization_table[1].recovery_capital).to eql(0)
        expect(@standard.amortization_table[1].due_capital).to eql(128261.33)
      end
      # 6 :: cost_interest: -97.91666666666666; cost_insurance: -12.5; recovery_capital: 0 ; due_capital: 50000.0
      it 'after 6 months a result of  an interest cost of 98, a recovery capital of 0.00, a due capital of 0.00' do
        expect(@standard.amortization_table[1].cost_interest.round(2)).to eql(-97.92)
        expect(@standard.amortization_table[1].recovery_capital).to eql(0)
        expect(@standard.amortization_table[1].due_capital).to eql(50000.0)
      end
      # 90 :: cost_interest: -55.34624624517698; cost_insurance: -12.5; recovery_capital: -284.02204322602034 ; due_capital: 27977.890933033977
      it 'after 90 months a result of an interest cost of -55.35, a recovery capital of -284.02, a due capital of 27977.89' do
        expect(@standard.amortization_table[90].cost_interest.round(2)).to eql(-55.35)
        expect(@standard.amortization_table[90].recovery_capital.round(2)).to eql(-284.02)
        expect(@standard.amortization_table[90].due_capital.round(2)).to eql(27977.89)
      end
      # 180 :: cost_interest: -0.6632972763815133; cost_insurance: -12.5; recovery_capital: -338.7049921948158 ; due_capital: 0
      it 'at the last month a result of x'  do
        expect(@standard.amortization_table.last.cost_interest.round(2)).to eql(-0.66)
        expect(@standard.amortization_table.last.recovery_capital.round(2)).to eql(-338.70)
        expect(@standard.amortization_table.last.due_capital.round(2)).to eql(0.0)
      end
    end
  end
end
