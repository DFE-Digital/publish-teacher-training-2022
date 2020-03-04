module AdminHelper
  def admin_block(&block)
    return unless current_user["admin"]

    concat "<div style='position:relative; " \
                        "display:inline-block; padding-right: 1.25em; margin-right: 0.5em;'>".html_safe
    concat "<div style='position:absolute; top:2px; right:2px; size:small; color:#666; cursor:default;'"\
           "title='Only visible to admins.'>🔒</div>".html_safe
    concat capture(&block)
    concat "</div>".html_safe
  end
end
