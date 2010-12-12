#######################################################
#
# date-dialog.rb (by Scott Moyer)
# 
# Port from Android API Demos
#
#######################################################

require "ruboto.rb"
confirm_ruboto_version(6, false)

ruboto_import_widgets :LinearLayout, :TextView, :Button

java_import "android.app.TimePickerDialog"
java_import "android.app.DatePickerDialog"

ruboto_import "#{$package_name}.RubotoOnDateSetListener"
ruboto_import "#{$package_name}.RubotoOnTimeSetListener"

$activity.start_ruboto_activity "$date_dialog" do
  setTitle "Views/Date Widgets/1. Dialog"

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      @time  = Time.now
      @tv = text_view :text => @time.strftime("%m-%d-%Y %R")
      button :text => "change the date", :width => :wrap_content
      button :text => "change the time", :width => :wrap_content
    end
  end

  handle_click do |view|
    showDialog(view.getText == "change the time" ? 1 : 0)
  end

  handle_create_dialog do |*args|
    if args[0] == 1
      TimePickerDialog.new(self, @time_set_listener, @time.hour, @time.min, false)
    else
      DatePickerDialog.new(self, @date_set_listener, @time.year, @time.month-1, @time.day)
    end
  end

  @date_set_listener = RubotoOnDateSetListener.new.handle_date_set do |view, year, month, day|
    @tv.setText("%d-%d-%d #{@tv.getText.split(' ')[1]}" % [month+1, day, year])
  end

  @time_set_listener = RubotoOnTimeSetListener.new.handle_time_set do |view, hour, minute|
    @tv.setText("#{@tv.getText.split(' ')[0]} %02d:%02d" % [hour, minute])
  end
end

