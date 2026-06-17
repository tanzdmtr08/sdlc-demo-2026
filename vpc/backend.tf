terraform {
  backend "s3" {
    bucket = "tfm-april-2026-tnzdmtr"
    key    = "path/to/my/sdlc-vpc"
    region = "us-east-2"
  }
}