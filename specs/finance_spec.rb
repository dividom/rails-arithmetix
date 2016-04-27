require_relative '../lib/rails_arithmetix/finance.rb'
require 'rspec'

# | english_name |    nom_francais
# |--------------|------------------
# | PV           |    VA
# | NPV          |    VAN
# | XNPV         |    VAN.PAIEMENTS
# | NPER         |    NPM
# | FV           |    VC
# | PMT          |    VPM
# | IPMT         |    INTPER
# | PPMT         |    PRINCPER
# | XIRR         |    TRI
#  --

class DummyClass
end

describe RailsArithmetix::Finance do

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend RailsArithmetix::Finance
  end

   it '\'s days_between(01/11/2015, 11/11/2015) method should return 10.0' do
     date_start = Time.new(2015,11,01)
     date_end = Time.new(2015, 11, 11)
     expect(@dummy.days_between(date_start,date_end)).to eql(10.0)
   end

   it '\'s days_between(01/11/2015, 11/11/2015) method should return 21.0' do
     date_start = Time.new(2015,10,02)
     date_end = Time.new(2015, 10, 23)
     expect(@dummy.days_between(date_start,date_end)).to eql(21.0)
   end

   it '\'s PV/VA should return 22886.86 --> =va(7%;4;0;30000.0; 0.0)' do
     expect(@dummy.pv(0.07,4,0.0,30000.0, 0.0).round(2)).to eql(-22886.86)
   end

   context '\'s  NPV/VAN ' do
     it ' should return 222.32 --> =van(10%;[-500,600,-850,1200]) ; NB: npv method' do
       # Calul de VAN avec flux monétaire en FIN d'année, au mêmem moment chaque année
       expect(@dummy.npv([-500.0,600.0,-850.0,1200.0], 0.1).round(2)).to eql(222.32)
     end
     it ' should return 244.55 --> =van(10%;[-500,600,-850,1200]) ; NB: _npv method' do
       # Calul de VAN avec flux monétaire en DEBUT d'année, au mêmem moment chaque année
       expect(@dummy._npv([-500.0,600.0,-850.0,1200.0], 0.1).round(2)).to eql(244.55)
     end
   end


   context '\'s XNPV/VAN.PAIEMENTS ' do
     it '\'s days_between method should return 31.0' do
       date_start = Time.new(Time.now.year, Time.now.month, 1)
       date_end = date_start + 31 * 24 * 60 * 60
       expect(@dummy.days_between(date_start,date_end)).to eql(31.0)
     end

     it '\'s days_between method should return 31.0' do
       date_start = Time.new(Time.now.year, Time.now.month, 1)
       date_end = date_start + 31 * 24 * 60 * 60

     end

     it 'should return 1105.0 --> =van(10%;[-500,600,-850,1200])' do
       flux = [  0.0,
                 -555.0,
                 350.0,
                 760.0,
                 1070.0 ]
       dates = [ Time.new(2013,11,1),
                 Time.new(2014,3,28),
                 Time.new(2015,2,19),
                 Time.new(2016,6,28),
                 Time.new(2017,9,12) ]

       expect(@dummy.xnpv(0.1, flux, dates ).round(2)).to eql(1105.27)
     end
     it 'should return something' do
       values = [ -50000.0,
                     2271.49,
                     2335.29,
                     2399.73,
                     2464,81,
                     2530.55,
                     2596.94,
                     2663.99,
                     2731.72,
                     2800.12,
                     2869.21,
                     2938.98,
                     3009.46,
                     3080.64,
                     3152.53,
                     3225.14,
                     7256.98,
                     7331.05,
                     7405.86,
                     7481.42,
                     110053.7 ]

       expect(@dummy.xnpv(0.01, values ).round(2)).to eql(128017.44)
     end
   end

   context '\'s NPER/NPM' do
     it '--> =npm(12%;-100;-1000;10000;1) should return 15.29' do
       expect(@dummy.nper(0.12, -100.0, -1000.0,10000.0, 1).round(2)).to eql(15.29)
     end
   end


   context '\'s FV/VC(taux, npm, vpm, va, type)' do
     it '--> =vc(2,5%; 4;  0; -10000, 0) should return 11038.13' do
       expect(@dummy.fv(0.025, 4,  0, -10000, 0).round(2)).to eql(11038.13)
     end
   end


   context '\'s PMT/VPM(taux;npm;va;vc;type)' do
     it '--> =vpm(6.75%/12; 12;  10000) should return -864.12' do
       expect(@dummy.pmt(0.0675/12, 12,  10000).round(2)).to eql(-864.12)
     end
   end

   context '\'s IPMT/INTPER(taux;période;npm;va;vc;type)' do
     it '--> intper(0.009/12;1;12;10000) should return 75.00' do
       expect(@dummy.ipmt(0.09/12.0,1,12,10000.0).round(2)).to eql(-75.00)
     end
   end

   context '\'s PPMT/PRINCPER(taux;période;npm;va;vc)'  do
     it '--> principer(9%/12;1;12;10000) should return -799.51' do
       expect(@dummy.ppmt(0.09/12.0,1,12,10000.0).round(2)).to eql(-799.51)
     end
   end



  context 'IRR/TRI' do
     it 'should return 93.6% (test tri 01)' do
         flow = [-10000.0, 16000.0,3200.0,6400.0]
         expect((@dummy.irr(flow).to_f).round(3)).to eql((93.60 / 100).round(3) )
     end
     it 'should return 93.6% (test tri 01b)' do
         flowb = [-10000.23, 16000.45,3200.24,6400.42]
         expect((@dummy.irr(flowb).to_f).round(3)).to eql((93.60 / 100).round(3) )
     end

     it 'should return 5.96% (test tri 02)' do
         flow = [-123400.0, 36200.0,54800.0,48100.0]
         expect(@dummy.irr(flow).round(4)).to eql(5.96 / 100)
     end


     it 'should return 2.36% (test tri 03)' do
       cash_flow = [-100,30,35,40]
       expect(@dummy.irr(cash_flow).round(4)).to eql(2.36 / 100)
     end

     it 'should return 0.0 with -1 & 1 (test tri 04)' do
       cash_flow = [-1,1]
       expect(@dummy.irr(cash_flow).round(4)).to eql(0.0)
     end

     it 'should return 0.0 with -1000 & 999.99 (test tri 05)' do
       cash_flow = [-1000.0,999.99]
       expect(@dummy.irr(cash_flow).round(4)).to eql(0.0)
     end
     it 'should return -10.28% (test tri 06)' do
       cash_flow = [ -50000.0,2271.49,2335.29,2399.73,2464.81,2530.55,2596.94,2663.99,2731.72,2800.12,2869.21]
       expect((@dummy.irr(cash_flow) * 100 ).round(2) ).to eql(-10.28 )
     end
    it 'should return 8.58% like mascote s example (test tri 07)' do
      cash_flow = [ -50000.0,2271.49,2335.29,2399.73,2464.81,2530.55,2596.94,2663.99,2731.72,2800.12,2869.21,2938.98,3009.46,3080.64,3152.53,3225.14,7256.98,7331.05,7405.86,7481.42,110053.7 ]
      expect(@dummy.irr(cash_flow).round(4) * 100).to eql(8.58 )
    end

    # it 'test sur 241 mois (test tri 08)' do
    #   big_cash = [ -50000.0]
    #   cash_flow_n = [2271.49,2335.29,2399.73,2464.81,2530.55,2596.94,2663.99,2731.72,2800.12,2869.21,2938.98,3009.46,3080.64,3152.53,3225.14,7256.98,7331.05,7405.86,7481.42,110053.7 ]
    #   cash_flow_n = cash_flow_n * 12
    #   big_cash << cash_flow_n
    #   big_cash = big_cash.flatten
    #   # big_cash = []
    #   # 12.times { |i| big_cash << cash_flow}
    #   # big_cash.flatten
    #   @dummy.irr(big_cash)
    #   expect(big_cash.size).to eql(241)
    # end
  end
end
