# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

cnpj = '12.345.678/0001-90'.gsub(/[^\d]/, '')
inscricao_municipal = '123456'.gsub(/[^\d]/, '') # NOTE: 0123456-0: without verifier

prestador =
  ::Nfse::Fortaleza::Prestador.new(
    cnpj: cnpj,
    inscricao_municipal: inscricao_municipal,
    razao_social: 'Tech Solutions Servicos de Informatica Ltda'
  )

tomador =
  Nfse::Fortaleza::Tomador.new(
    cpf_cnpj: '10476807000',
    inscricao_municipal: nil,
    razao_social: 'Joao da Silva',
    endereco: 'Rua das Flores',
    numero: '123',
    complemento: nil,
    bairro: 'Centro',
    codigo_municipio: '2304400',
    uf: 'CE',
    cep: '60000000',
    telefone: '85999999999',
    email: 'tomador@mail.com'
  )

servico =
  Nfse::Fortaleza::Servico.new(
    item_lista_servico: '9.99',
    codigo_tributacao_municipio: '999999999',
    discriminacao: 'TREINAMENTO DE PROGRAMAÇÃO',
    codigo_municipio: '2304400',
    valor_servicos: 1.0,
    valor_deducoes: 0.0,
    valor_pis: 0.0,
    valor_cofins: 0.0,
    valor_inss: 0.0,
    valor_ir: 0.0,
    valor_csll: 0.0,
    iss_retido: 2,
    valor_iss: 5.0,
    valor_iss_retido: 0.0,
    outras_retencoes: 0.0,
    base_calculo: 100.0,
    aliquota: 5.0,
    valor_liquido_nfse: 95.0,
    desconto_incondicionado: 0.0,
    desconto_condicionado: 0.0
  )

rps =
  Nfse::Fortaleza::Rps.new(
    numero: 1,
    serie: 1,
    tipo: 1,
    data_emissao: Time.zone.now.iso8601,
    natureza_operacao: 1,
    optante_simples_nacional: 1,
    incentivador_cultural: 1,
    status: 1,
    servico: servico,
    prestador: prestador,
    tomador: tomador
  )

lote_rps = ::Nfse::Fortaleza::LoteRps.new(id: 1, prestador: prestador, lote: [rps])

# Disable SSL verification since we're getting certificate verify errors
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

CertficateExtractor = Struct.new(:pfx_path, :pfx_password) do
  def call
    # https://github.com/ruby/openssl/issues/611#issuecomment-1615842169
    OpenSSL::Provider.load('default')
    OpenSSL::Provider.load('legacy')

    pkcs = OpenSSL::PKCS12.new(File.read(pfx_path), pfx_password)
  end
end

pfx_path =
  ::Rails.root.join(
    'tmp/certs/TECH_SOLUTIONS_SERVICOS_DE_INFORMATICA_LTDA_12345678000190.pfx'
  )

pfx_password = '123456'

pkcs = CertficateExtractor.new(pfx_path, pfx_password).call

result = Nfse::Fortaleza::Services::EnviarLoteRps.call(
  lote_rps: lote_rps,
  certificate: pkcs.certificate,
  private_key: pkcs.key
)

lote_consulta = Nfse::Fortaleza::LoteRps.new(id: 1, prestador: prestador, protocolo: result.protocolo)

result = Nfse::Fortaleza::Services::ConsultarLoteRps.call(
  lote_rps: lote_consulta,
  certificate: pkcs.certificate,
  private_key: pkcs.key
)

# @body={:fault=>{:faultcode=>"soap:Server", :faultstring=>"java.lang.NullPointerException"}}, @code="soap:Server", @message="java.lang.NullPointerException"
result = Nfse::Fortaleza::Services::ConsultarSituacaoLoteRps.call(
  lote_rps: lote_consulta,
  certificate: pkcs.certificate,
  private_key: pkcs.key
)

# rps = Nfse::Fortaleza::Rps.new(numero: 1, serie: 1, tipo: 1, prestador: prestador)

# result = Nfse::Fortaleza::Services::ConsultarNfseRps.call(
#   rps: rps,
#   certificate: pkcs.certificate,
#   private_key: pkcs.key
# )

nfse = Nfse::Fortaleza::NotaFiscal.new(numero: 201, prestador_servico: prestador)

#  @error="E1",
#  @fix="Reenvie asssinatura do Hash conforme algoritmo estabelecido no Manual de Instrução da NFS-e.",
#  @message="Assinatura do Hash não confere.">
result = Nfse::Fortaleza::Services::ConsultarNfse.call(
  nfse: nfse,
  certificate: pkcs.certificate,
  private_key: pkcs.key
)
