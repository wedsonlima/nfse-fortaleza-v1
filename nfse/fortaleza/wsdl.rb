module Nfse
  module Fortaleza
    class Wsdl
      # WSDL_URL = "https://iss.fortaleza.ce.gov.br/grpfor-iss/ServiceGinfesImplService?wsdl"
      WSDL_URL = "https://isshomo.sefin.fortaleza.ce.gov.br/grpfor-iss/ServiceGinfesImplService?wsdl"
      private_constant :WSDL_URL

      class << self
        # Operations:
        # :cancelar_nfse,
        # :recepcionar_lote_rps_v3,
        # :consultar_lote_rps_v3,
        # :consultar_nfse_por_rps_v3,
        # :consultar_nfse_v3,
        # :consultar_situacao_lote_rps_v3
        def client(certificate:, private_key:)
          ::Savon.client(
            wsdl: WSDL_URL,
            soap_version: 1,

            raise_errors: false,

            # NOTE: Fixes issue with headers: https://github.com/cjmamo/jruby-cxf/issues/2#issuecomment-63300133
            headers: { "SOAPAction" => "" },

            env_namespace: "soapenv",
            namespace_identifier: "prod",

            ssl_cert: certificate,
            ssl_cert_key: private_key,

            pretty_print_xml: true,
            log: true,
            log_level: :debug,
            logger: Rails.logger
          )
        end
      end
    end
  end
end
