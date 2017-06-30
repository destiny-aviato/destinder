module ApplicationHelper

    def bulma_class_for flash_type
        { success: "notification is-success", error: "notification is-error", alert: "notification is-alert", notice: "notification is-info" }[flash_type.to_sym] || flash_type.to_s
    end

    def flash_messages(opts = {})
        flash.each do |msg_type, message|
            concat(content_tag(:div, message, class: "#{bulma_class_for(msg_type)}") do
            concat content_tag(:button, 'x', class: "delete", data: { dismiss: 'alert' })
            concat "     #{message}"
            end)
        end
        nil
    end
end
