module AdminHelper
  def admin_block(&block)
    return unless current_user["admin"]

    concat render "shared/admin", &block
  end
end
