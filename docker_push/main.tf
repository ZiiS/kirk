data "external" "folder" {
  program = ["sh", "-c", "md5sum ${var.folder}/** | grep -v tfstate | md5sum | cut -c-32 | jq -R {\"md5\":.}"]
}

resource "null_resource" "build" {
  triggers = {
    build_folder_md5 = data.external.folder.result.md5
  }
  provisioner "local-exec" {
    command = "docker buildx build ${var.folder} -t ${var.registry}/${var.image}:${data.external.folder.result.md5}"
  }
}

resource "null_resource" "push" {
  triggers = {
    push_folder_md5 = data.external.folder.result.md5
  }
  depends_on = [null_resource.build]
  provisioner "local-exec" {
    command = "docker push ${var.registry}/${var.image}:${data.external.folder.result.md5}"
  }
}
