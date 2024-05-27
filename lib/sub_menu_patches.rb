# Replaces def page_header_title in application_helper.rb 
require_dependency 'application_helper'

module SubMenuPatches
  module ApplicationHelperPatch
    def self.included(base)
      base.class_eval do
        def page_header_title
          if @project.nil? || @project.new_record?
            h(Setting.app_title)
          else
            b = []
            ancestors = (@project.root? ? [] : @project.ancestors.visible.to_a)
            if ancestors.any?
              root = ancestors.shift
              b << link_to_project(root, {:jump => current_menu_item}, :class => 'root')
              if ancestors.size > 2
                b << "\xe2\x80\xa6"
                ancestors = ancestors[-2, 2]
              end
              b +=
                ancestors.collect do |p|
                  link_to_project(p, {:jump => current_menu_item}, :class => 'ancestor')
                end
            end

            # subprojects_menu (smi)
            @uprojects = @project.children.visible
            if Setting.plugin_redmine_submenus['show_subprojects_menu'] && @uprojects.present?
              sub1 = content_tag(:span, h(@project)+' '+Setting.plugin_redmine_submenus['dropdown_menu_symbol'], class: 'current-project drdn-trigger')
              sub2 = content_tag(:div, class: 'drdn-content', style: 'right: auto; top: auto;') do
                content_tag(:div, class: 'drdn-items') do
                  @uprojects.map do |uproject|
                    link_to_project(uproject, {:jump => current_menu_item}, :style => 'font-size: small; color: initial; font-weight: initial; padding-inline: 0.9em;')
                  end.join.html_safe
                end
              end
              b << content_tag(:span, sub1+sub2, class: 'drdn', style: 'position: absolute; line-height: 1em;')  # position:absolute -> to override overflow:hidden of header element
            else
              b << content_tag(:span, h(@project), class: 'current-project')
            end

            if b.size > 1
              separator = content_tag(:span, ' &raquo; '.html_safe, class: 'separator')
              path = safe_join(b[0..-2], separator) + separator
              b = [content_tag(:span, path.html_safe, class: 'breadcrumbs'), b[-1]]
            end

            safe_join b
          end
        end
      end
    end
  end
end

# Monkey Patching anwenden
ApplicationHelper.send(:include, SubMenuPatches::ApplicationHelperPatch)
