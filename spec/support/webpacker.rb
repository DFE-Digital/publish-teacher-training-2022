module WebpackerTest
  TIMESTAMP_FILE = Rails.root.join("tmp", "webpacker-#{Rails.env}-timestamp")

  def self.compile_once
    digest_file = Rails.root.join("tmp/webpacker_#{Rails.env}_digest")

    app_code = Dir[Webpacker.config.source_path.join("**/*")]
    npm_code = Dir[Rails.root.join("yarn.lock")]

    packable_contents = (app_code + npm_code)
      .sort
      .map { |filename| File.read(filename) if File.file?(filename) }
      .join
    digest = Digest::SHA256.hexdigest(packable_contents)

    return if digest_file.exist? && digest_file.read == digest

    if ENV["TEST_ENV_NUMBER"].to_i < 1
      public_output_path = Webpacker.config.public_output_path
      FileUtils.rm_r(public_output_path) if File.exist?(public_output_path)
      puts "Removed Webpack output directory #{public_output_path}"

      Webpacker.compile

      digest_file.write(digest)
    else
      loop do
        break if digest_file.exist? && digest_file.read == digest

        sleep 0.1
      end
    end
  end
end

WebpackerTest.compile_once
