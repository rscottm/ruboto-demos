package org.ruboto.example;

import org.jruby.Ruby;
import org.jruby.javasupport.util.RuntimeHelpers;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.javasupport.JavaUtil;
import org.jruby.exceptions.RaiseException;
import org.ruboto.Script;

public class RubotoOnDateSetListener implements android.app.DatePickerDialog.OnDateSetListener {
  private Ruby __ruby__;

  public static final int CB_DATE_SET = 0;
  private IRubyObject[] callbackProcs = new IRubyObject[1];



  private Ruby getRuby() {
    if (__ruby__ == null) __ruby__ = Script.getRuby();
    return __ruby__;
  }

  public void setCallbackProc(int id, IRubyObject obj) {
    callbackProcs[id] = obj;
  }
	
  public void onDateSet(android.widget.DatePicker view, int year, int monthOfYear, int dayOfMonth) {
    if (callbackProcs[CB_DATE_SET] != null) {
      try {
        IRubyObject[] args = {JavaUtil.convertJavaToRuby(getRuby(), view), JavaUtil.convertJavaToRuby(getRuby(), year), JavaUtil.convertJavaToRuby(getRuby(), monthOfYear), JavaUtil.convertJavaToRuby(getRuby(), dayOfMonth)};
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_DATE_SET], "call" , args);
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    }
  }
}
