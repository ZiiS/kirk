provider "helm" {
  alias              = "ziis"
  namespace          = "tiller"
  service_account    = "tiller"
  enable_tls         = true
  client_key         = module.ziis.helm_key
  client_certificate = module.ziis.helm_cert
  ca_certificate     = module.ziis.helm_cert_ca
}

