{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  botocore,
  jmespath,
  s3transfer,

  # tests
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "boto3";
  inherit (botocore) version; # N.B: botocore, boto3, awscli needs to be updated in lockstep, bump botocore version for updating these.
  pyproject = true;

  src = fetchFromGitHub {
    owner = "boto";
    repo = "boto3";
    tag = version;
    hash = "sha256-3NK9xp58w+Wrhs/i7eXLF/P9Dwadptrr4LlpV6MRbGM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    botocore
    jmespath
    s3transfer
  ];

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [ "boto3" ];

  disabledTestPaths = [
    # Integration tests require networking
    "tests/integration"
  ];

  optional-dependencies = {
    crt = botocore.optional-dependencies.crt;
  };

  meta = {
    description = "AWS SDK for Python";
    homepage = "https://github.com/boto/boto3";
    changelog = "https://github.com/boto/boto3/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    longDescription = ''
      Boto3 is the Amazon Web Services (AWS) Software Development Kit (SDK) for
      Python, which allows Python developers to write software that makes use of
      services like Amazon S3 and Amazon EC2.
    '';
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
}
