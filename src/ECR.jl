module ECR

using AWSCore
using AWSCore.Services: ecr
using Base64
using Mocking

get_authorization_token(config; kwargs...) = ecr(config, "GetAuthorizationToken"; kwargs...)

export get_login

"""
    get_login(registry_ids::Union{AbstractString, Integer}="") -> Cmd

Gets the AWS ECR authorization token and returns the corresponding docker login command.
The AWS `config` keyword parameter is optional (will use the default if it's not passed in).
"""
get_login

function get_login(registry_id::AbstractString=""; config::AWSConfig=aws_config())
    # Note: Although `get_authorization_token` can take multiple registry IDs at once it
    # will only return a "proxyEndpoint" for the first registry. Additionally, the
    # `aws ecr get-login` command returns a `docker login` command for each registry ID
    # passed in. Because of these factors we'll do our processing on a single registry.

    response = if !isempty(registry_id)
        @mock get_authorization_token(config; registryIds=[registry_id])
    else
        @mock get_authorization_token(config)
    end

    authorization_data = first(response["authorizationData"])
    token = String(base64decode(authorization_data["authorizationToken"]))
    username, password = split(token, ':')
    endpoint = authorization_data["proxyEndpoint"]

    return `docker login -u $username -p $password $endpoint`
end

function get_login(registry_id::Integer; config::AWSConfig=aws_config())
    get_login(lpad(registry_id, 12, '0'); config=config)
end

end  # ECR
