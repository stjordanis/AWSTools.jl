__precompile__()
module S3

using AWSCore
using AWSS3
using Dates
using FilePathsBase
using Memento

import FilePathsBase: sync

export S3Path, sync, upload

const logger = getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via
# `getlogger(MyModule)`. If this line is not included then the precompiled
# `MyModule.logger` won't be registered at runtime.
function __init__()
    Memento.register(logger)
end

# Couple extra methods that should probably be included in AWSS3 at some point.
"""
    upload(src::AbstractPath, dest::S3Path)

Uploads a local file to the s3 path specified by `dest`.
"""
upload

const upload = Base.cp

# Note: naming copied from Go SDK:
# https://docs.aws.amazon.com/sdk-for-go/v1/developer-guide/s3-example-presigned-urls.html
function presign(
    path::S3Path,
    duration::Period=Hour(1);
    config::AWSConfig=aws_config(),
)
    AWSS3.s3_sign_url(config, path.bucket, path.key, Dates.value(Second(duration)))
end

# TODO: Remove the sync methods below as they are now pirating.
@deprecate sync(src::AbstractString, dest::AbstractString; delete::Bool=false, config::AWSConfig=aws_config()) sync(Path(src), Path(dest); delete=delete)

end  # S3
