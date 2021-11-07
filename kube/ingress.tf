data "sops_file" "rfc2136" {
  source_file = "${var.name}_rfc2136_secret.json"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

data "http" "cert-manager-crd" {
    url = "https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.crds.yaml"
}

#resource "kubernetes_manifest" "test-configmap" {
#  manifest = yamldecode(data.http.cert-manager-crd.body)
#}

resource "kubectl_manifest" "cert-manager-crd" {
    yaml_body = data.http.cert-manager-crd.body
}

resource "helm_release" "cert-manager-crd" {
  name      = "cert-manager-crd"
  namespace = kubernetes_namespace.cert-manager.metadata.0.name
  chart     = "./kube/cert-manager-crd"
}

resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx-ingress" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.nginx-ingress.metadata.0.name

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.0.6"
  values = [<<EOF
controller:   
  service:
    externalIPs:
    - 178.32.25.16
  metrics:
    enabled: true
    service:   
      annotations:
        prometheus.io/port: "10254"
        prometheus.io/scrape: "true"
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
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.6.0"
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
