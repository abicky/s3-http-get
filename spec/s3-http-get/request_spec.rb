require "spec_helper"

RSpec.describe S3HttpGet::Request do
  around do |example|
    access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    ENV["AWS_ACCESS_KEY_ID"] = "AWS_ACCESS_KEY_ID"
    ENV["AWS_SECRET_ACCESS_KEY"] = "AWS_SECRET_ACCESS_KEY"

    example.run

    ENV["AWS_ACCESS_KEY_ID"] = access_key_id
    ENV["AWS_SECRET_ACCESS_KEY"] = secret_access_key
  end

  let(:http) { double }

  shared_examples "request" do
    it do
      expect(Net::HTTP).to receive(:start).and_yield(http)
      expect(http).to receive(:request) do |request|
        expect(request["authorization"]).to include("/#{region}/s3/aws4_request,")
      end
      described_class.new(URI(url)).execute
    end
  end

  context "with us-east-1" do
    let(:region) { "us-east-1" }

    context "with virtual hosted-style endpoint" do
      context "with 's3' label" do
        let(:url) { "https://dualstack.s3.amazonaws.com/object-key" }
        it_behaves_like "request"
      end

      context "with 's3-external-1' label" do
        let(:url) { "https://dualstack.s3-external-1.amazonaws.com/bucketname/object-key" }
        it_behaves_like "request"
      end
    end

    context "with path-style endpoint" do
      context "with 's3' label" do
        let(:url) { "https://s3.amazonaws.com/bucketname/object-key" }
        it_behaves_like "request"
      end

      context "with 's3-external-1' label" do
      let(:url) { "https://s3-external-1.amazonaws.com/bucketname/object-key" }
        it_behaves_like "request"
      end
    end
  end

  context "with other regions" do
    let(:region) { "aws-region" }

    context "with virtual hosted-style endpoint" do
      let(:url) { "https://dualstack.s3-#{region}.amazonaws.com/object-key" }
      it_behaves_like "request"
    end

    context "with path-style endpoint" do
      let(:url) { "https://s3-#{region}.amazonaws.com/bucketname/object-key" }
      it_behaves_like "request"
    end
  end

  context "with dual-stack" do
    let(:region) { "aws-region" }

    context "with virtual hosted-style endpoint" do
      let(:url) { "https://bucketname.s3.dualstack.#{region}.amazonaws.com/object-key" }
      it_behaves_like "request"
    end

    context "with path-style endpoint" do
      let(:url) { "https://s3.dualstack.#{region}.amazonaws.com/bucketname/object-key" }
      it_behaves_like "request"
    end
  end
end
