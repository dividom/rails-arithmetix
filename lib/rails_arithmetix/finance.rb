require 'bigdecimal'
module RailsArithmetix
  module Finance
    # === SOURCE
    # * http://www.experts-exchange.com/articles/1948/A-Guide-to-the-PMT-FV-IPMT-and-PPMT-Functions.html
    # * FV:PV:NPV:PMT Java Implementation => http://www.docjar.com/html/api/org/apache/poi/hssf/record/formula/functions/RailsArithmetixLib.java.html
    # ---

    #  -- Methods
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

    # === PV /VA
    # @desc: Valeur actuelle (montant du placement ou montant d'un prêt)
    # Dans le cas où les flux monétaires sont toujours encaissés à la même
    # date chaque année, en fin de période, vous pouvez simplement utiliser la
    # fonction Excel de base VAN (ou NPV en anglais). Cette fonction, tel
    # qu’illustré ci-bas, nécessite deux paramètres: le premier est le taux
    #  d’actualisation et le deuxième est la plage de flux monétaires à
    # actualiser).
    def pv(r, n, y, f, t)
      retval = 0

      if r == 0
        retval = -1*((n*y)+f)
      else
        r1 = r + 1
        retval = (( ( 1 - (r1 ** n) ) / r ) * (t ? r1 : 1)  * y - f) / (r1 ** n)
      end
      return retval
    end
    # ---

    # === NPV / VAN
    # calculates the Net Present Value of a principal amount
    # given the discount rate and a sequence of cash flows
    # (supplied as an array). If the amounts are income the value should
    # be positive, else if they are payments and not income, the
    # value should be negative.
    # @param r
    # @param cfs cashflow amounts
    #

    # END OF PERIOD
    def npv(cfs, r)
      npv = 0.0
      r1 = r + 1.0
      trate = r1

      cfs.each do |f|
        npv += f / trate
        trate *= r1
      end

      return npv
    end

    # === XNPV / VAN.PAIEMENTS
    # @NB VAN à Flux à différents moments dans le temps
    #
    # def xnpv (rate, values, times)
    #   xnpv = 0.0
    #   first_date = times[0]
    #
    #   values.each do |value|
    #     tmp = value.recovery_capital
    #     date = tmp.date
    #     xnpv += value / pow1p( 1 + rate , days_between(first_date, date) / 365)
    #   end
    #   return xnpv
    # end
    # # ---

    def xnpv (rate, values, times=nil)
      xnpv = 0.0

      # -- check if there is array of dates
      time_nil = false
      times == nil ? time_nil = true : first_date = times[0]
      time = 0.0
      # --

      for i in 0..(values.size - 1)
        if time_nil
          xnpv += values[i].to_f / ( 1.0 + rate.to_f) ** ( time / 365.0 )
          #NB average day == 365 / 12
          time += 30.42
        else
          xnpv += values[i].to_f / ( 1.0 + rate.to_f) ** ( days_between(first_date, times[i]) / 365.0 )
        end
      end
      return xnpv
    end
    # ---

    # === NPER / NPM
    # @desc Nombre total des versements
    # La syntaxe de la fonction NPM contient les arguments suivants :
    #
    #   *taux    Obligatoire. Représente le taux d’intérêt par période.
    #
    #   *vpm    Obligatoire. Représente le montant d’un versement périodique ; celui-ci reste constant pendant toute la durée de l’opération. En règle générale, vpm comprend le principal et les intérêts, mais aucune autre charge, ni impôt.
    #
    #   *va    Obligatoire. Représente la valeur actuelle, c’est-à-dire la valeur, à la date d’aujourd’hui, d’une série de versements futurs.
    #
    #   *vc    Facultatif. Représente la valeur capitalisée, c’est-à-dire le montant que vous souhaitez obtenir après le dernier paiement. Si vc est omis, la valeur par défaut est 0 (par exemple, la valeur capitalisée d’un emprunt est égale à 0).
    #
    #   *type    Facultatif. Représente le nombre 0 ou 1, et indique quand les paiements doivent être effectués.
    # @param r rate
    # @param y
    # @param p
    # @param f
    # @param t
    def nper(r , y, p, f, t)
      retval = 0

      if r == 0
        retval = -1 * (f + p) / y
      else
        r1 = r + 1
        ryr = (t ? r1 : 1) * y / r
        a1 = ((ryr - f) < 0) ? Math.log(f - ryr) : Math.log(ryr - f)
        a2 = ((ryr - f) < 0) ? Math.log(-p - ryr) : Math.log(p + ryr)
        a3 = Math.log(r1)
      end
      retval = (a1 - a2) / a3

      return retval
    end
    # ---

    # === FV / VC
    # @desc Valeur capitalisée, c'est à dire la valeur future (si omise la valeur est = 0)
    # Future value of an amount given the number of payments, rate, amount
    # of individual payment, present value and boolean value indicating whether
    # payments are due at the beginning of period
    # (false => payments are due at end of period)
    # @param r rate
    # @param n num of periods
    # @param y pmt per period
    # @param p future value
    # @param t type (true=pmt at end of period, false=pmt at begining of period)
    #
    def fv(r, n, y, p, t)
      retval = 0

      if r == 0
        retval = -1*(p+(n*y))
      else
        r1 = r + 1
        retval =((1-(r1 ** n)) * (t ? r1 : 1) * y ) / r - p*(r1 ** n)
      end

      return retval
    end

    # === PMT / VPM
    # @desc: Montant du remboursement de chaque période (ex. mensualités)
    def pmt(rate, nper, pv, fv=0, type=0)
      ((-pv * pvif(rate, nper) - fv ) / ((1.0 + rate * type) * fvifa(rate, nper)))
    end
    # ---

    # === IPMT / INTPER
    # @desc: cost_interest
    #
    def ipmt(rate, per, nper, pv, fv=0, type=0)
      p = pmt(rate, nper, pv, fv, 0);
      ip = -(pv * pow1p(rate, per - 1) * rate + p * pow1pm1(rate, per - 1))
      (type == 0) ? ip : ip / (1 + rate)
    end
    # ---

    # ===   PPMT / PRINCPER
    # @desc: La fonction PRINCPER calcule le capital remboursé à chaque période pour un prêt à remboursement et à taux constants.
    # @exemple: Quel est le montant du capital remboursé (amortissement) par période pour un prêt de 10'000 CHF remboursable en 12 mois avec un taux d'intérêts annuel de 6.75% ?
    # taux
    #  @param  rate => taux    : d'intérêt (annuel)
    #  @param  per  => période : Période pour laquelle on veux calculer les intérêts.
    #  @param  nper => npm     : Montant du remboursement de chaque période (ex. mensualités)
    #  @param  pv   => va      : Valeur actuelle (montant du placement ou montant d'un prêt)
    #  @param  fv   => vc      : Valeur capitalisée facultative, c'est à dire la valeur future (si omise la valeur est = 0)
    #  @use: recovery_capital
    #
    def ppmt(rate, per, nper, pv, fv=0, type=0)
     p = pmt(rate, nper, pv, fv, type)
     ip = ipmt(rate, per, nper, pv, fv, type)
     p - ip
    end
    # ---




    # === XIRR / TRI
    #
    # def xirr(values, dates=nil)
    #   # if dates.nil?
    #   #   dates = generate_months(values)
    #   #   puts dates
    #   # end
    #
    #   tri = -1.0
    #   # x en tant qu'inconnu dans TRI rationnelement compris entre 0% et 20%
    #   for x in (0)..(1000)
    #   #   # convert to '0.01'
    #     x = x.to_f
    #     x /= 100.0
    #     # dates == nil ? xnpv_tmp = xnpv(x,values) : xnpv_tmp = xnpv(x,values, dates)
    #     # dates == nil ? xnpv_tmp = xnpv(x,values) : xnpv_tmp = xnpv(x,values,dates)
    #     xnpv_tmp = xnpv(x,values,dates)
    #
    #     if xnpv_tmp.round(6) <= 0.0
    #       tri = x.abs
    #       break
    #     end
    #   end
    #   return tri
    # end



    # def _npv(ct, i)
    #  sum = 0
    #  ct.each_with_index{ |c,t| sum += c/(1 + i.to_f)**t }
    #  sum
    # end

    # big decimal version
    # def _npv(ct, i)
    #  sum = BigDecimal.new('0')
    # #  sum.to_f
    #  ct.each_with_index{ |c,t| sum += BigDecimal.new(c.to_s)/(BigDecimal.new('1.0') + BigDecimal.new(i.to_s))**BigDecimal.new(t.to_s) }
    # #  puts sum.to_f
    #  sum.to_f
    # end


    #nb inject semble meilleur en temps de calcul
    def _npv (cf, irr)
     (0...cf.length).inject(0.0) { |npv, t| npv + (cf[t]/(1+irr)**t) }
    end
    #
    #
    # derivation (utilisé lorsque les calculs sont proches du zero...)
    def _dnpv (cf, irr)
      (1...cf.length).inject(0.0) { |npv, t| npv - (t*cf[t]/
    (1+irr)**(t-1)) }
    end

    #big decimal version
    # def _dnpv (ct, irr)
    #   sum = BigDecimal.new('0')
    #   (1...ct.length).each { |npv, t| sum += BigDecimal.new(npv.to_s) - (BigDecimal.new(t.to_s) * BigDecimal.new(ct[t].to_s) / (BigDecimal.new('1') + BigDecimal.new(irr.to_s))** BigDecimal.new((t-1).to_s)  ) }
    #   sum.to_f
    # end


    # Actuellement obtient meilleurs résultats
    def irr(cf)
     l = -0.9999
     sign = _npv(cf, l)
     r = 1.0
     while _npv(cf, r)*sign > 0 do
       r *= 2.0
       break if r > 1000
     end
     if r > 1000
       l = -1.0001
       sign = _npv(cf, l)
       r = -2.0
       while _npv(cf, r)*sign > 0 do
         r *= 2
         return 0.0 if r.abs > 1000
       end
     end

     m = 0.0
     loop do
       m = (l + r)/2.0
       v = _npv(cf, m)
    #    p v
       break if v.abs < 1e-8
       if v*sign < 0
         r = m
       else
         l = m
       end
     end
     m
    end

    #BigDecimal version
    # def irr(ct)
    #  l = BigDecimal.new('-0.9999')
    #  sign = _npv(ct, l)
    #   # puts sign
    #  r = BigDecimal.new('1.0')
    #  while _npv(ct, r)*sign > 0 do
    #   #  puts _npv(ct, r)
    #    r *= BigDecimal.new('2.0')
    #    break if r > 1000
    #  end
    #  if r > 1000
    #    l = BigDecimal.new('-1.0001')
    #    sign = _npv(ct, l)
    #    r = BigDecimal.new('-2.0')
    #    while _npv(ct, r)*sign > 0 do
    #      r *= BigDecimal.new('2')
    #      return 0.0 if r.abs > 1000
    #    end
    #  end
    #
    #  m = BigDecimal.new('0')
    #  loop do
    #    m = (l + r)/BigDecimal.new('2')
    #    v = _npv(ct, m)
    # #    p v
    #   #quand tend vers 0 ou - linfini...
    #    break if v.abs < 1e-8
    #    if v*sign < BigDecimal.new('0')
    #      r = m
    #    else
    #      l = m
    #    end
    #  end
    #  m
    # end





    #
    # def irr (cf)
    #   irr = 0.5
    #   it = 0
    #   begin
    #     begin
    #       oirr = irr
    #       irr -= _npv(cf, irr) / _dnpv(cf, irr)
    #       it += 1
    #       return -1 if it > 50
    #     end until (irr - oirr).abs < 0.0001
    #   rescue ZeroDivisionError
    #     return -1
    #   end
    #   irr
    # end



    def days_between(begin_date, end_date)
      day_in_seconds = 24*60*60
      days_between_in_seconds =  end_date - begin_date
      return  (days_between_in_seconds/day_in_seconds).abs.to_f
    end

    def generate_months(values)
      nb_values = values.size
      first_day_of_month = Time.new(Time.now.year, Time.now.month, 1)
      dates = [first_day_of_month]
      for i in 2..(nb_values - 1) do
        dates << dates.last + 31 * 24 * 60 * 60
      end
      return dates
    end
    # ---

    private
      # === calcul methods, helpfull for ipmt & ppmt
      #
      def pow1pm1(x, y)
        (x <= -1) ? ((1 + x) ** y) - 1 : Math.exp(y * Math.log(1.0 + x)) - 1
      end

      # puissance --> like Math.pow in JS
      def pow1p(x, y)
        (x.abs > 0.5) ? ((1 + x) ** y) : Math.exp(y * Math.log(1.0 + x))
      end

      def pvif(rate, nper)
        pow1p(rate, nper)
      end

      def fvifa(rate, nper)
        (rate == 0) ? nper : pow1pm1(rate, nper) / rate
      end
      # ---
  end
end
