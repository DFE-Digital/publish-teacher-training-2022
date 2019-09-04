if Rails.env.in? %w[development test]
  localhost_path = File.join(Rails.root, 'config', 'localhost', 'https')
  cert = File.join(localhost_path, 'localhost.crt')
  key = File.join(localhost_path, 'localhost.key')

  unless File.exist?(cert) && File.exist?(key)
    FileUtils.mkdir_p localhost_path

    root_key = OpenSSL::PKey::RSA.new(2048)
    File.write(key, root_key, mode: 'wb')

    root_ca = OpenSSL::X509::Certificate.new
    root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    root_ca.serial = 0x0
    root_ca.subject = OpenSSL::X509::Name.parse "/C=GB/L=London/O=DfE/CN=localhost"
    root_ca.issuer = root_ca.subject # root CA's are "self-signed"
    root_ca.public_key = root_key.public_key
    root_ca.not_before = Time.now
    root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
    root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
    File.write(cert, root_ca, mode: 'wb')
  end
end
