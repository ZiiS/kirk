data "sops_file" "rfc2136" {
  source_file = "${var.name}_rfc2136_secret.json"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager-crd" {
  name      = "cert-manager-crd"
  namespace = kubernetes_namespace.cert-manager.metadata.0.name
  chart     = "./kube/cert-manager-crd"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  namespace  = kubernetes_namespace.nginx-ingress.metadata.0.name
  repository = data.helm_repository.stable.metadata.0.name

  chart = "nginx-ingress"

  values = [<<EOF
controller:   
  service:
    externalIPs:
    - 178.32.25.16
  stats: 
    enabled: true 
  metrics:
    enabled: true
    service:   
      annotations:
        prometheus.io/port: 10254
        prometheus.io/scrape: true
  config:
    ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
    hsts: "false"
EOF
  ]
}

resource "helm_release" "cert-manager" {
  depends_on = [helm_release.cert-manager-crd]
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  repository = data.helm_repository.jetstack.metadata.0.name
  chart      = "cert-manager"
}

resource "helm_release" "issuer" {
  depends_on = [helm_release.cert-manager-crd]
  name       = "issuer"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  chart      = "./kube/issuer"

  values = [<<EOF
email: ${var.email}
providers:
  rfc2136:
    nameserver: "${var.nameserver}:53"
    tsigKeyName: ${data.sops_file.rfc2136.data.tsigkeyname}
    tsigAlgorithm: HMACSHA512
    tsigSecretSecretRef:
      name: issuer-tsigkey
      key: tsigkey
EOF
  ]

  set_sensitive {
    name  = "tsigkey"
    value = base64encode(data.sops_file.rfc2136.data.tsigkey)
  }
}
