{ ... }:

{
  imports = [
    ../../modules/base
    ../../modules/ha
    ../../modules/dr
    ../../modules/document-extractor
  ];

  restack.ha.enable = true;
  restack.dr.enable = true;
  restack.documentExtractor.enable = true;

  restack.dr.backupRepo = "/var/backup/restack";
}
