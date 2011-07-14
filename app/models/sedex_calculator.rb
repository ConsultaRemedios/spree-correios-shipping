class Correios::SedexCalculator < Correios::Base
  def self.description
    'Sedex'
  end

  def self.register
    super
    ShippingMethod.register_calculator(self)
  end

  def servico
    :sedex
  end
end
