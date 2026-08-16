{ ... }:

{
  imports = [
    ../../modules/base
    ../../modules/document-extractor
  ];

  restack.documentExtractor.enable = true;
}
