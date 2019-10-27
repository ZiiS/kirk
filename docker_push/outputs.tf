output "image" {
  value = "${var.registry}/${var.image}:${data.external.folder.result.md5}"
}
