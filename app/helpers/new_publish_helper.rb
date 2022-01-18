module NewPublishHelper
  def new_publish_url(path)
    "#{Settings.new_publish.base_url}/publish#{path}"
  end

  def redirect_to_new_publish_equivalent
    redirect_to new_publish_url(request.path)
  end
end
