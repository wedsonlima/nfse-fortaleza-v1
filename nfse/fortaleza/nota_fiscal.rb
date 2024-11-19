module Nfse
  module Fortaleza
    class NotaFiscal
      attr_accessor :numero,
                    :codigo_verificacao,
                    :data_emissao,
                    :identificacao_rps,
                    :data_emissao_rps,
                    :natureza_operacao,
                    :regime_especial_tributacao,
                    :optante_simples_nacional,
                    :incentivador_cultural,
                    :competencia,
                    :nfse_substituida,
                    :outras_informacoes,
                    :servico,
                    :valor_credito,
                    :prestador_servico,
                    :tomador_servico,
                    :intermediario_servico,
                    :orgao_gerador,
                    :construcao_civil

      def initialize(**params)
        params = params.with_indifferent_access

        @numero = params[:numero]
        @codigo_verificacao = params[:codigo_verificacao]
        @data_emissao = params[:data_emissao]
        @identificacao_rps = params[:identificacao_rps]
        @data_emissao_rps = params[:data_emissao_rps]
        @natureza_operacao = params[:natureza_operacao]
        @regime_especial_tributacao = params[:regime_especial_tributacao]
        @optante_simples_nacional = params[:optante_simples_nacional]
        @incentivador_cultural = params[:incentivador_cultural]
        @competencia = params[:competencia]
        @nfse_substituida = params[:nfse_substituida]
        @outras_informacoes = params[:outras_informacoes]
        @servico = params[:servico]
        @valor_credito = params[:valor_credito]
        @prestador_servico = params[:prestador_servico]
        @tomador_servico = params[:tomador_servico]
        @intermediario_servico = params[:intermediario_servico]
        @orgao_gerador = params[:orgao_gerador]
        @construcao_civil = params[:construcao_civil]
      end
    end
  end
end
