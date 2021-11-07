data "sops_file" "sentry" {
  source_file = "ziis_sentry_secret.json"
}

resource "kubernetes_namespace" "sentry" {
  metadata {
    name = replace(var.host, ".", "-")
  }
}

resource "helm_release" "sentry" {
  count      = 0
  name       = replace(var.host, ".", "-")
  namespace  = kubernetes_namespace.sentry.metadata.0.name
  chart      = "sentry"
  repository = "https://sentry-kubernetes.github.io/charts"
  version    = "9.0.0"
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
sentry:
  web:
    env:
    - name:  UWSGI_DISABLE_LOGGING
      value: 'true'
snuba:
  api:
    env:
    - name:  UWSGI_DISABLE_LOGGING
      value: 'true'
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
