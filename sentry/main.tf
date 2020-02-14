data "sops_file" "sentry" {
  source_file = "ziis_sentry_secret.json"
}

resource "helm_release" "sentry" {
  count     = 0
  name      = replace(var.host, ".", "-")
  namespace = replace(var.host, ".", "-")
  chart     = "stable/sentry"
  values = [<<EOF
user:
  email: b@zi.is
email:
  host: m.zi.is
  user: sentry@zi.is
  use_tls: true
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/issuer: issuer
    cert-manager.io/issuer-kind: ClusterIssuer
  hostname: ${var.host}
  tls:
    - hosts:
      - ${var.host}
      secretName: ${replace(var.host, ".", "-")}
EOF
  ]
  set_sensitive {
    name  = "email.password"
    value = data.sops_file.sentry.data.emailPassword
  }
  set_sensitive {
    name  = "sentrySecret"
    value = data.sops_file.sentry.data.secret
  }
  set_sensitive {
    name  = "user.password"
    value = data.sops_file.sentry.data.userPassword
  }
}
