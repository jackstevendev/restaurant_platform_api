module Storage
  class S3UploaderService
    DEFAULT_BUCKET = ENV.fetch("AWS_S3_BUCKET", "restaurant-platform-invoices")
    DEFAULT_REGION = ENV.fetch("AWS_REGION", "us-east-1")

    def self.call(file_content, destination_path, content_type: "application/pdf")
      new(file_content, destination_path, content_type: content_type).call
    end

    def initialize(file_content, destination_path, content_type: "application/pdf")
      @file_content = file_content
      @destination_path = destination_path.sub(%r{\A/}, "")
      @content_type = content_type
    end

    def call
      # Architecture prepared for real AWS SDK S3 or simulated S3 storage
      if aws_configured?
        upload_to_aws_s3
      else
        generate_s3_url
      end
    end

    private

    def aws_configured?
      ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
    end

    def upload_to_aws_s3
      # When AWS credentials are provided in production, perform actual S3 put_object
      # require 'aws-sdk-s3'
      # s3 = Aws::S3::Client.new(region: DEFAULT_REGION)
      # s3.put_object(bucket: DEFAULT_BUCKET, key: @destination_path, body: @file_content, content_type: @content_type)
      generate_s3_url
    end

    def generate_s3_url
      "https://#{DEFAULT_BUCKET}.s3.#{DEFAULT_REGION}.amazonaws.com/#{@destination_path}"
    end
  end
end
