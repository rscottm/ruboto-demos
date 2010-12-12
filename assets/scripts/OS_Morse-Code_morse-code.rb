#######################################################
#
# morse-code.rb (by Scott Moyer)
# 
# Port from Android API Demos
#
#######################################################

require "ruboto.rb"
confirm_ruboto_version(6, false)

ruboto_import_widgets :LinearLayout, :EditText, :Button

java_import "android.content.Context"

$activity.start_ruboto_activity "$morse_code" do
  @base  = 100
  @durations = {"." => [@base, @base],  "-" => [@base* 3, @base], 
                "|" => [0, @base * 2],  " " => [0, @base * 6]}
  @codes = {"A" => ".-",   "B" => "-...", "C" => "-.-.", "D" => "-..",
            "E" => ".",    "F" => "..-.", "G" => "--.",  "H" => "....",
            "I" => "..",   "J" => ".---", "K" => "-.-",  "L" => ".-..",
            "M" => "--",   "N" => "-.",   "O" => "---",  "P" => ".--.",
            "Q" => "--.-", "R" => ".-.",  "S" => "...",  "T" => "-",
            "U" => "..-",  "V" => "..-",  "W" => ".--",  "X" => "-..-",
            "Y" => "-.--", "Z" => "--..", "0" => "-----","1" => ".----",
            "2" => "..---","3" => "...--","4" => "....-","5" => ".....",
            "6" => "-....","7" => "--...","8" => "---..","9" => "----."}

  setTitle "OS/Morse Code"

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      @et = edit_text
      button :text => "Vibrate", :width => :wrap_content
    end
  end

  handle_click do |view|
    getSystemService(Context::VIBRATOR_SERVICE).vibrate(
      @et.getText.to_s.upcase.split('').
      map {|i| @codes[i] || " "}.join('|').split('').
      map {|i| @durations[i]}.flatten.unshift(0).to_java(:long), -1)
  end
end
