module Nfse
  module Fortaleza
    class LoteRps
      attr_accessor :id, :protocolo, :prestador, :lote

      def initialize(**params)
        params = params.with_indifferent_access

        @id = params[:id]

        @protocolo = params[:protocolo]
        @prestador = params[:prestador]
        @lote = params[:lote]
      end
    end
  end
end
