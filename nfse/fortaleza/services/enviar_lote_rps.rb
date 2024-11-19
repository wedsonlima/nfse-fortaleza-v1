module Nfse
  module Fortaleza
    class Services::EnviarLoteRps
      module Result
        class Success
          include ::ActiveModel::Model

          attr_accessor :body
          attr_reader :numero_lote, :data_recebimento, :protocolo

          def initialize(body:)
            @body = body

            @numero_lote = body.dig("EnviarLoteRpsResposta", "NumeroLote")
            @data_recebimento = body.dig("EnviarLoteRpsResposta", "DataRecebimento")
            @protocolo = body.dig("EnviarLoteRpsResposta", "Protocolo")
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

            @error = body.dig("EnviarLoteRpsResposta", "ns2:ListaMensagemRetorno", "ns2:MensagemRetorno", "ns2:Codigo")
            @message = body.dig("EnviarLoteRpsResposta", "ns2:ListaMensagemRetorno", "ns2:MensagemRetorno", "ns2:Mensagem")
            @fix = body.dig("EnviarLoteRpsResposta", "ns2:ListaMensagemRetorno", "ns2:MensagemRetorno", "ns2:Correcao")
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
          if body.dig("EnviarLoteRpsResposta", "NumeroLote").present?
            Success.new(body: body)
          else
            Failure.new(body: body)
          end
        end
      end
      private_constant :Result

      def initialize(lote_rps:, certificate:, private_key:)
        @lote_rps = lote_rps

        @certificate = certificate
        @private_key = private_key
      end

      def self.call(lote_rps:, certificate:, private_key:)
        new(lote_rps:, certificate:, private_key:).call
      end

      def call
        client = Wsdl.client(certificate: certificate, private_key: private_key)

        response = client.call(:recepcionar_lote_rps_v3, message: {
          "Cabecalho!" => cabecalho_xml,
          "EnviarLoteRpsEnvio!" => data_xml # NOTE: the "!" character tells Gyoku to not escape the content.
        })

        return Result::Error.new(body: response.body) unless response.success?

        Result.load(
          body: ::Nori.new.parse(
            response.body.dig(:recepcionar_lote_rps_v3_response, :enviar_lote_rps_resposta)
          )
        )
      end

      private

      attr_reader :lote_rps, :certificate, :private_key

      def cabecalho_xml
        <<~XML
          <![CDATA[<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:cabecalho versao="03" xmlns:ns2="http://www.ginfes.com.br/cabecalho_v03.xsd"><versaoDados>03</versaoDados></ns2:cabecalho>]]>
        XML
      end

      # NOTE: Ex. <ns3:Rps>...</ns3:Rps>
      WSDL_NAMESPACE = "ns3".freeze
      private_constant :WSDL_NAMESPACE

      def data_xml
        data = {
          numero_lote: lote_rps.id,
          cnpj: lote_rps.prestador.cnpj,
          inscricao_municipal: lote_rps.prestador.inscricao_municipal,
          quantidade_rps: lote_rps.lote.size,
          lista_rps: lote_rps.lote.map do |rps|
            {
              rps: {
                inf_rps: {
                  '@Id': rps.numero,
                  identificacao_rps: {
                    numero: rps.numero,
                    serie: rps.serie,
                    tipo: rps.tipo
                  },
                  data_emissao: rps.data_emissao.to_time.iso8601,
                  natureza_operacao: rps.natureza_operacao,
                  optante_simples_nacional: rps.optante_simples_nacional,
                  incentivador_cultural: rps.incentivador_cultural,
                  status: rps.status,
                  servico: {
                    valores: {
                      valor_servicos: rps.servico.valor_servicos,
                      valor_deducoes: rps.servico.valor_deducoes,
                      valor_pis: rps.servico.valor_pis,
                      valor_cofins: rps.servico.valor_cofins,
                      valor_inss: rps.servico.valor_inss,
                      valor_ir: rps.servico.valor_ir,
                      valor_csll: rps.servico.valor_csll,
                      iss_retido: rps.servico.iss_retido,
                      valor_iss: rps.servico.valor_iss,
                      valor_iss_retido: rps.servico.valor_iss_retido,
                      outras_retencoes: rps.servico.outras_retencoes,
                      base_calculo: rps.servico.base_calculo,
                      aliquota: rps.servico.aliquota,
                      valor_liquido_nfse: rps.servico.valor_liquido_nfse,
                      desconto_incondicionado: rps.servico.desconto_incondicionado,
                      desconto_condicionado: rps.servico.desconto_condicionado
                    },
                    item_lista_servico: rps.servico.item_lista_servico,
                    codigo_tributacao_municipio: rps.servico.codigo_tributacao_municipio,
                    discriminacao: rps.servico.discriminacao,
                    codigo_municipio: rps.servico.codigo_municipio
                  }.compact,
                  prestador: {
                    cnpj: rps.prestador.cnpj,
                    inscricao_municipal: rps.prestador.inscricao_municipal
                  },
                  tomador: {
                    identificacao_tomador: {
                      cpf_cnpj: rps.tomador.cpf_cnpj.size == 11 ? { cpf: rps.tomador.cpf_cnpj } : { cnpj: rps.tomador.cpf_cnpj },
                      inscricao_municipal: rps.tomador.inscricao_municipal
                    }.compact,
                    razao_social: rps.tomador.razao_social,
                    endereco: {
                      endereco: rps.tomador.endereco,
                      numero: rps.tomador.numero,
                      complemento: rps.tomador.complemento,
                      bairro: rps.tomador.bairro,
                      codigo_municipio: rps.tomador.codigo_municipio,
                      uf: rps.tomador.uf,
                      cep: rps.tomador.cep
                    }.compact,
                    contato: {
                      telefone: rps.tomador.telefone,
                      email: rps.tomador.email
                    }.compact
                  }.compact
                }.compact
              }
            }
          end
        }

        # NOTE: The @ indicates an attribute. Ex. <Rps Id="1">...</Rps>
        parsed_data = ::Gyoku.xml(
          data.deep_transform_keys do |key|
            key.to_s.include?("@") ? key : [ WSDL_NAMESPACE, key.to_s.camelize ].compact.join(":")
          end
        )

        <<~XML
          <![CDATA[
            <EnviarLoteRpsEnvio xmlns="http://www.ginfes.com.br/servico_enviar_lote_rps_envio_v03.xsd" xmlns:ns3="http://www.ginfes.com.br/tipos_v03.xsd">
              <LoteRps Id="#{lote_rps.id}">
                #{parsed_data}
              </LoteRps>
              #{sign_data(parsed_data)}
            </EnviarLoteRpsEnvio>
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
