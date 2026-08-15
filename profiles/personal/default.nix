{ ... }:

{
  imports = [
    ../../modules/base
    ../../modules/document-extractor
  ];

  restack.documentExtractor.enable = true;

  networking.hostName = "restack-personal";
}
