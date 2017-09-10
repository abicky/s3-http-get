require "spec_helper"

RSpec.describe S3HttpGet do
  it "has a version number" do
    expect(S3HttpGet::VERSION).not_to be nil
  end
end
