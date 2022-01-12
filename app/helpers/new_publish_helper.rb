module NewPublishHelper
  def new_publish_url(path)
    "#{Settings.new_publish.base_url}/publish#{path}"
  end
end
