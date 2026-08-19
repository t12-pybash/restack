{ ... }:

{
  imports = [
    ../../modules/base
    ../../modules/ha
    ../../modules/dr
    ../../modules/docker
    ../../modules/ferretdb
    ../../modules/document-extractor
  ];

  restack.ha.enable = true;
  restack.dr.enable = true;
  restack.docker.enable = true;
  restack.ferretdb.enable = true;
  restack.documentExtractor.enable = true;

  restack.dr.backupRepo = "/var/backup/restack";
}
