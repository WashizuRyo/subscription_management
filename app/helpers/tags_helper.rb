module TagsHelper
  def hex_to_rgba(hex_color, alpha)
    rgb = hex_color&.gsub('#', '').scan(/../).map { |color| color.to_i(16) }
    "rgba(#{rgb.join(', ')}, #{alpha})"
  end
end
