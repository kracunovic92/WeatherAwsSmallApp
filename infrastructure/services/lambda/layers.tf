
resource "aws_lambda_layer_version" "external_API" {
  layer_name = "externalAPI"
  filename = "${path.root}/../src/externalAPI/externalAPI.zip"
  source_code_hash = filebase64sha256(data.archive_file.api_layer_zip.output_path)
  compatible_runtimes = ["python3.13"]
  depends_on = [ data.archive_file.api_layer_zip ]
}