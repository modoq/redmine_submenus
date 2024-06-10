require 'nokogiri'

module NewSubprojectPatch
  module MenuManagerPatch
    def self.included(base)
      base.send(:prepend, InstanceMethods)
    end

    module InstanceMethods
      def render_main_menu(project)
        # Call the original render_main_menu method
        menu = super

        if project && User.current.allowed_to?(:add_subprojects, project)
          # Create a new subproject link with localization and correct parent_id
          new_subproject_link = content_tag(:li, link_to(l(:label_subproject_new), new_project_path(parent_id: project), class: 'new-subproject'))
          
          # Parse the menu HTML using Nokogiri
          menu_doc = Nokogiri::HTML::DocumentFragment.parse(menu)
          
          # Find the menu-children ul element
          ul = menu_doc.at('ul.menu-children')
          
          if ul
            # Add the new subproject link to the menu-children ul
            ul.add_child(new_subproject_link)
          end
          
          # Convert the modified Nokogiri document back to HTML, while unescaping special characters
          menu = menu_doc.to_html.gsub(/>\s+</, '><')
        end
        
        menu.html_safe
      end
    end
  end
end

# Apply the patch
Redmine::MenuManager::MenuHelper.send(:include, NewSubprojectPatch::MenuManagerPatch)
