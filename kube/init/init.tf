variable "name" {
  default = "kube"
}

resource "tls_private_key" "tillerCA" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "tiller" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "tillerCA" {
  key_algorithm   = "${tls_private_key.tillerCA.algorithm}"
  private_key_pem = "${tls_private_key.tillerCA.private_key_pem}"

  subject {
    common_name = "tiller-ca"
  }

  allowed_uses = [
    "cert_signing",
  ]

  validity_period_hours = 87600
  is_ca_certificate     = true
}

resource "tls_cert_request" "tiller" {
  key_algorithm   = "${tls_private_key.tiller.algorithm}"
  private_key_pem = "${tls_private_key.tiller.private_key_pem}"

  subject {
    common_name = "tiller-client"
  }

  dns_names = [
    "tiller-deploy",
    "tiller-server",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1",
  ]
}

resource "tls_locally_signed_cert" "tiller" {
  cert_request_pem      = "${tls_cert_request.tiller.cert_request_pem}"
  ca_key_algorithm      = "${tls_private_key.tillerCA.algorithm}"
  ca_private_key_pem    = "${tls_private_key.tillerCA.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.tillerCA.cert_pem}"
  validity_period_hours = 87600

  allowed_uses = [
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "helm_cert_ca" {
  content  = "${tls_self_signed_cert.tillerCA.cert_pem}"
  filename = "helm_cert_ca.${var.name}.pem"
}

resource "local_file" "helm_cert" {
  content  = "${tls_locally_signed_cert.tiller.cert_pem}"
  filename = "helm_cert.${var.name}.pem"
}

resource "local_file" "helm_key" {
  content  = "${tls_private_key.tiller.private_key_pem}"
  filename = "helm_key.${var.name}.pem"
}

output "helm_cert_ca" {
  value = "${local_file.helm_cert_ca.filename}"
}

output "helm_cert" {
  value = "${local_file.helm_cert.filename}"
}

output "helm_key" {
  value = "${local_file.helm_key.filename}"
}
