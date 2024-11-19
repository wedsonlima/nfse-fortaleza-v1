module Nfse
  module Fortaleza
    class Services::ConsultarNfse
      module Result
        class Success
          include ::ActiveModel::Model

          attr_accessor :body
          attr_reader :notas_fiscais

          def initialize(body:)
            @body = body

            @notas_fiscais = body.dig("ns3:ConsultarNfseResposta", "ListaNfse", "CompNfse").map do |nfse|
              NotaFiscal.new(nfse)
            end
          end

          def success?
            true
          end
        end

        class Failure
          include ::ActiveModel::Model

          attr_accessor :body
          attr_reader :error, :message, :fix

          def initialize(body:)
            @body = body

            result = body.dig("ns3:ConsultarNfseResposta", "ListaMensagemRetorno", "MensagemRetorno")

            @error = result["Codigo"]
            @message = result["Mensagem"]
            @fix = result["Correcao"]
          end

          def success?
            false
          end
        end

        class Error
          include ::ActiveModel::Model

          attr_accessor :body
          attr_reader :code, :message

          def initialize(body:)
            @body = body

            @code = body.dig(:fault, :faultcode)
            @message = body.dig(:fault, :faultstring)
          end

          def success?
            false
          end
        end

        def self.load(body:)
          if body.dig("ListaNfse", "CompNfse").present?
            Success.new(body: body)
          else
            Failure.new(body: body)
          end
        end
      end
      private_constant :Result

      def initialize(nfse:, certificate:, private_key:)
        @nfse = nfse

        @certificate = certificate
        @private_key = private_key
      end

      def self.call(nfse:, certificate:, private_key:)
        new(nfse:, certificate:, private_key:).call
      end

      def call
        client = Wsdl.client(certificate: certificate, private_key: private_key)

        response = client.call(:consultar_nfse_v3, message: {
          "Cabecalho!" => cabecalho_xml,
          "ConsultarNfseEnvio!" => data_xml # NOTE: the "!" character tells Gyoku to not escape the content.
        })

        return Result::Error.new(body: response.body) unless response.success?

        Result.load(
          body: ::Nori.new.parse(
            response.body.dig(:consultar_nfse_v3_response, :consultar_nfse_resposta)
          )
        )
      end

      private

      attr_reader :nfse, :certificate, :private_key

      def cabecalho_xml
        <<~XML
          <![CDATA[<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:cabecalho versao="03" xmlns:ns2="http://www.ginfes.com.br/cabecalho_v03.xsd"><versaoDados>03</versaoDados></ns2:cabecalho>]]>
        XML
      end

      def data_xml
        parsed_data = ::Gyoku.xml(
          {
            "ns2:Prestador" => {
              "Cnpj" => nfse.prestador_servico.cnpj,
              "InscricaoMunicipal" => nfse.prestador_servico.inscricao_municipal
            },
            "ns2:NumeroNfse" => nfse.numero

            # 'PeriodoEmissao' => {
            #   'DataInicial' => '2024-11-01',
            #   'DataFinal' => '2024-11-30'
            # }

            # 'Tomador' => {
            #   'CpfCnpj' => {
            #     'Cnpj' => nfse.prestador_servico.cnpj
            #   },
            #   'InscricaoMunicipal' => nfse.prestador_servico.inscricao_municipal
            # }
          }
        )

        <<~XML
          <![CDATA[
            <ns2:ConsultarNfseEnvio xmlns:ns2="http://www.ginfes.com.br/servico_consultar_nfse_envio_v03.xsd" xmlns:ns3="http://www.ginfes.com.br/tipos_v03.xsd">
              #{parsed_data}
              #{sign_data(parsed_data)}
            </ns2:ConsultarNfseEnvio>
          ]]>
        XML
      end

      def sign_data(data)
        digest_value = ::Digest::SHA1.base64digest(data)
        signature_value = ::Base64.encode64(private_key.sign(::OpenSSL::Digest::SHA1.new, data)).gsub('\n', "")
        x509_certificate = ::Base64.encode64(certificate.to_der).gsub('\n', "")

        <<~XML
          <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
            <SignedInfo>
              <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
              <SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
              <Reference URI="">
                <Transforms>
                  <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                  <Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
                </Transforms>
                <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                <DigestValue>#{digest_value}</DigestValue>
              </Reference>
            </SignedInfo>
            <SignatureValue>#{signature_value}</SignatureValue>
            <KeyInfo>
              <X509Data>
                <X509Certificate>#{x509_certificate}</X509Certificate>
              </X509Data>
            </KeyInfo>
          </Signature>
        XML
      end
    end
  end
end
