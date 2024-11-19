module Nfse
  module Fortaleza
    class Rps
      attr_accessor :numero,
                    :serie,
                    :tipo,
                    :data_emissao,
                    :natureza_operacao,
                    :optante_simples_nacional,
                    :incentivador_cultural,
                    :status,
                    :servico,
                    :prestador,
                    :tomador

      def initialize(**params)
        params = params.with_indifferent_access

        @numero = params[:numero]
        @serie = params[:serie]
        @tipo = params[:tipo]
        @data_emissao = params[:data_emissao]
        @natureza_operacao = params[:natureza_operacao]

        @optante_simples_nacional = params[:optante_simples_nacional]
        @incentivador_cultural = params[:incentivador_cultural]

        @status = params[:status]

        @servico = params[:servico]
        @prestador = params[:prestador]
        @tomador = params[:tomador]
      end
    end
  end
end
