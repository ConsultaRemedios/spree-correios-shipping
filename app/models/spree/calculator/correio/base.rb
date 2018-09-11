module Spree
  class Calculator::Correio::Base < Spree::ShippingCalculator
    preference :default_weight, :decimal, :default => 0.1
    preference :default_box_weight, :decimal, :default => 0.25
    preference :default_box_price, :decimal, :default => 0.0
    preference :box_x, :integer, :default => 36
    preference :box_y, :integer, :default => 27
    preference :box_z, :integer, :default => 27
    preference :company_code, :string
    preference :password, :string

    def compute_package(package)
      data = cached_info(package).
        select { |d| services.include?(d.tipo) }.
        reject { |d| d.error? }.
        min_by(&:valor)

      data.valor + preferred_default_box_price
    end

    private

    def cached_info(package)
      Rails.cache.fetch(cache_key(package), compress: true, expires_in: 12.hours) do
        correio_info(package)
      end
    end

    def cache_key(package)
      order = package.order
      zipcode = order.ship_address.zipcode
      stock_zipcode = package.stock_location.zipcode
      line_items_hash = Digest::MD5.hexdigest(package.contents.map { |i| "#{i.variant.id}_#{i.quantity}" }.join("|"))
      @cache_key = "correio-#{order.number}-#{zipcode}-#{line_items_hash}-#{stock_zipcode}".gsub(" ","")
    end

    def correio_info(package)
      weight = package.weight

      request_attributes = {
        :cep_origem => package.stock_location.zipcode,
        :cep_destino => package.order.ship_address.zipcode.to_s,
        :peso => weight.zero? ?  preferred_default_weight : weight,
        :comprimento => preferred_box_x,
        :largura => preferred_box_y,
        :altura => preferred_box_z,
      }

      if has_preference? :company_code and has_preference? :password
        request_attributes[:codigo_empresa] = preferred_company_code unless preferred_company_code.blank?
        request_attributes[:senha] = preferred_password unless preferred_password.blank?
      end

      request = Correios::Frete::Calculador.new request_attributes

      begin
        response = request.calcular(*available_services).values
      rescue
        fake_service = OpenStruct.new(valor: preferred_fallback_amount, prazo_entrega: -1)
        response = [fake_service]
      end

      response
    end

    def available_services
      Spree::Calculator.where(type: available_calculators_class_name).map(&:services).flatten
    end

    def available_calculators_class_name
      Spree::Calculator::Correio::Scaffold.descendants.map(&:name)
    end
  end
end
