#######################################################
#
# main.rb (by Scott Moyer)
# 
# Main activity of the Ruboto Demos. Builds a hierarchy 
# of scripts and alows you to run or view them.
#
#######################################################

require 'ruboto.rb'
confirm_ruboto_version(6, false)

java_import "android.text.method.ScrollingMovementMethod"
ruboto_import_widgets :ListView, :TextView

$lists = {}

#
# Demos are stored scripts directory. The file names are used to build a 
# hierarchy similar to the Android APIs Demo. 
#   "_" = hierarchy level change
#   "-" = space
#
def load_demos
  files = Dir.glob($activity.getFilesDir.getAbsolutePath + "/scripts/*.rb")
  files = files.map{|i| i.split("/")[-1]}
  files.each do |file|
    unless %w(main.rb ruboto.rb).include?(file)
      path = file.split("_")
      path[0..-2].each_with_index do |e, i|
        key = i == 0 ? :main : path[i-1].gsub("-", " ")
        value = e.gsub("-", " ")
        $lists[key] = ($lists[key] << value) if $lists[key] and not $lists[key].include?(value)
        $lists[key] = [value] unless $lists[key]
      end
      $lists[path[-2].gsub("-", " ")] = file
    end
  end
end

#
# Open up a new activity with a list view. Used for levels of the hierarchy.
#
def launch_list(var, title, list_id)
  $activity.start_ruboto_activity var do
    setTitle title

    setup_content do
      @l = $lists[list_id]
      @lv = list_view(:list => @l)
      registerForContextMenu(@lv)
      @lv
    end

    handle_item_click do |adapter_view, view, pos, item_id|
      if $lists[view.getText].is_a?(Array)
        launch_list("$sl_#{view.getText.downcase.gsub(' ', '_')}", getTitle + " / " + view.getText, view.getText)
      else
        load $lists[view.getText]
      end
    end

    handle_create_context_menu do |menu, view, menu_info|
      if $lists[@l[menu_info.position]].is_a?(Array)
        false
      else
        add_context_menu("Run") {|pos| load $lists[@l[pos]]}

        add_context_menu("View Source") do |pos| 
          launch_view_source("$sl_#{@l[pos].downcase.gsub(' ', '_')}", getTitle + " / " + @l[pos], @l[pos])
        end

        true
      end
    end
  end
end

#
# Display the text of the script in a TextView.
#
def launch_view_source(var, title, list_id)
  $activity.start_ruboto_activity var do
    setTitle title

    setup_content do
      text_view :text => IO.read($lists[list_id]), 
                :movement_method => ScrollingMovementMethod.new,
                :horizontally_scrolling=> true
    end
  end
end

#
# Initial startup and view.
#
load_demos
launch_list "$main_list", "Api Demos", :main
