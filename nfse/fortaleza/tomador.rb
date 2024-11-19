module Nfse
  module Fortaleza
    class Tomador
      attr_accessor :cpf_cnpj,
                    :inscricao_municipal,
                    :razao_social,
                    :endereco,
                    :numero,
                    :complemento,
                    :bairro,
                    :codigo_municipio,
                    :uf,
                    :cep,
                    :telefone,
                    :email

      def initialize(**params)
        params = params.with_indifferent_access

        @cpf_cnpj = params[:cpf_cnpj]
        @inscricao_municipal = params[:inscricao_municipal]
        @razao_social = params[:razao_social]

        @endereco = params[:endereco]
        @numero = params[:numero]
        @complemento = params[:complemento]
        @bairro = params[:bairro]
        @codigo_municipio = params[:codigo_municipio]
        @uf = params[:uf]
        @cep = params[:cep]

        @telefone = params[:telefone]
        @email = params[:email]
      end
    end
  end
end
