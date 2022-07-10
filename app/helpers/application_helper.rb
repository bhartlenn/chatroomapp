module ApplicationHelper

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flashes", partial: "layouts/flash"
  end
    
end