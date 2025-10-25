# app/helpers/flash_helper.rb
module FlashHelper
  def flash_klass(type)
    case type.to_s
    when "notice", "success" then "alert-success"
    when "alert", "warning"  then "alert-warning"
    when "error", "danger"   then "alert-error"
    else                         "alert-info"
    end
  end

  def flash_role(type)
    %w[alert error].include?(type.to_s) ? "alert" : "status"
  end
end
