module Nfse
  module Fortaleza
    class Servico
      attr_accessor :item_lista_servico,
                    :codigo_tributacao_municipio,
                    :discriminacao,
                    :codigo_municipio,
                    :valor_servicos,
                    :valor_deducoes,
                    :valor_pis,
                    :valor_cofins,
                    :valor_inss,
                    :valor_ir,
                    :valor_csll,
                    :iss_retido,
                    :valor_iss,
                    :valor_iss_retido,
                    :outras_retencoes,
                    :base_calculo,
                    :aliquota,
                    :valor_liquido_nfse,
                    :desconto_incondicionado,
                    :desconto_condicionado

      def initialize(**params)
        params = params.with_indifferent_access

        @item_lista_servico = params[:item_lista_servico]
        @codigo_tributacao_municipio = params[:codigo_tributacao_municipio]
        @discriminacao = params[:discriminacao]
        @codigo_municipio = params[:codigo_municipio]
        @valor_servicos = params[:valor_servicos]
        @valor_deducoes = params[:valor_deducoes]
        @valor_pis = params[:valor_pis]
        @valor_cofins = params[:valor_cofins]
        @valor_inss = params[:valor_inss]
        @valor_ir = params[:valor_ir]
        @valor_csll = params[:valor_csll]
        @iss_retido = params[:iss_retido]
        @valor_iss = params[:valor_iss]
        @valor_iss_retido = params[:valor_iss_retido]
        @outras_retencoes = params[:outras_retencoes]
        @base_calculo = params[:base_calculo]
        @aliquota = params[:aliquota]
        @valor_liquido_nfse = params[:valor_liquido_nfse]
        @desconto_incondicionado = params[:desconto_incondicionado]
        @desconto_condicionado = params[:desconto_condicionado]
      end
    end
  end
end
