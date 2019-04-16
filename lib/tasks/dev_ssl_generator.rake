namespace :dev do
  namespace :ssl do
    desc "Generate SSL certificates for local development"
    task :generate do
      `openssl req -new -newkey rsa:2049 -sha256 -nodes -x509 -keyout config/localhost/https/localhost.key -out config/localhost/https/localhost.crt -subj "/C=GB/L=London/O=DfE/CN=localhost:3000"`
    end
  end
end
