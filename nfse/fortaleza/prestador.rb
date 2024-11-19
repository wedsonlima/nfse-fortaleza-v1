module Nfse
  module Fortaleza
    class Prestador
      attr_accessor :cnpj, :inscricao_municipal, :razao_social

      def initialize(**params)
        params = params.with_indifferent_access

        @cnpj = params[:cnpj]
        @inscricao_municipal = params[:inscricao_municipal]
        @razao_social = params[:razao_social]
      end
    end
  end
end
