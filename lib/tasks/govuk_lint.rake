namespace :lint do
  desc "Lint ruby code"
  task ruby: :environment do
    puts "Linting Ruby..."
    system "bundle exec rubocop app config lib spec Gemfile --format clang -a"
  end

  desc "Lint SCSS code"
  task scss: :environment do
    puts "Linting SCSS..."
    system "bundle exec scss-lint app/webpacker/stylesheets"
  end

  desc "Lint ERB code"
  task erb: :environment do
    puts "Linting ERB..."
    system "bundle exec erblint --lint-all"
  end
end
