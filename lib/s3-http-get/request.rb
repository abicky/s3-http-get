require "aws-sdk-core"

module S3HttpGet
  class Request
    # @param uri [String, URI::HTTP] URI for the S3 object
    # @param profile_name [String] profile name of your credential file
    def initialize(uri, profile_name: nil)
      @uri = uri.is_a?(URI::HTTP) ? uri : URI(uri)

      # cf. Aws::CredentialProviderChain
      @credentials = Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
      unless @credentials.set?
        @credentials = Aws::SharedCredentials.new(profile_name: profile_name)
      end
    end

    # @return [Net::HTTPResponse]
    def execute
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(@uri)
        # cf. http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html
        request.initialize_http_header(build_signature(@uri, @credentials).headers)
        http.request(request)
      end
    end

    private

    def build_signature(uri, credentials)
      signer = Aws::Sigv4::Signer.new(service: "s3", region: resolve_region(uri.host), credentials_provider: credentials)
      signer.sign_request(http_method: "GET", url: uri.to_s)
    end

    def resolve_region(host)
      # cf. http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#access-bucket-intro
      # cf. http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
      if host =~ /(?:\A|\.)s3(?:-external-1)?.amazonaws.com\z/
        return "us-east-1"
      end

      # e.g. "bucketname.s3-aws-region.amazonaws.com" => ["bucketname", "s3-aws-region"]
      labels = host.split(".")[0..-3]
      if labels[-1].start_with?("s3-")
        # e.g. "bucketname.s3-aws-region.amazonaws.com", "s3-aws-region.amazonaws.com"
        labels[-1].sub(/\As3-/, "")
      else  # Dual-Stack Endpoints:
        # e.g. "bucketname.s3.dualstack.aws-region.amazonaws.com", "s3.dualstack.aws-region.amazonaws.com"
        labels[-1]
      end
    end
  end
end
