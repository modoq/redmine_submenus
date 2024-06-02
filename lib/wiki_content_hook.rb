require 'nokogiri'

module WikiContentHook
  class ViewWikiContentHook < Redmine::Hook::ViewListener
    def view_wiki_show_content(context={})
      content_html = context[:controller].send(:render_to_string, {
        partial: 'wiki/content',
        locals: context
      })

      modified_content = modify_wiki_content(content_html)
      modified_content.html_safe
    end

    private

    def modify_wiki_content(content_html)
      doc = Nokogiri::HTML.fragment(content_html)
      h1 = doc.at('h1')

      if h1
        # Abrufen der Settings-Variable
        dropdown_menu_symbol = Setting.plugin_redmine_submenus['dropdown_menu_symbol']

        dropdown_menu = <<-HTML
          <span class="custom-content">#{dropdown_menu_symbol}</span>
        HTML

        # Das a-Element finden und den Dropdown-Menü-HTML-Code davor einfügen
        a_element = h1.at('a')
        if a_element
          a_element.add_previous_sibling(Nokogiri::HTML.fragment(dropdown_menu))
        end
      end

      doc.to_html
    end
  end
end
