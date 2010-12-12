#######################################################
#
# sensors.rb (by Scott Moyer)
# 
# Port from Android API Demos
#
#######################################################

require "ruboto.rb"
confirm_ruboto_version(6, false)

java_import "android.content.Context"
java_import "android.graphics.Color"
java_import "android.graphics.Paint"
java_import "android.graphics.RectF"
java_import "android.graphics.Path"
java_import "android.graphics.Canvas"
java_import "android.graphics.Bitmap"
java_import "android.hardware.SensorManager"
java_import "android.hardware.Sensor"

ruboto_import "org.ruboto.RubotoView"
ruboto_import "#{$package_name}.RubotoSensorEventListener"

$activity.start_ruboto_activity "$sensors" do
  setTitle "OS/Sensors"

  @rv = RubotoView.new(self)

  setup_content do
    @rv
  end

  handle_finish_create do |*args|
    @manager = getSystemService(Context::SENSOR_SERVICE)
    @sensors = [Sensor::TYPE_ACCELEROMETER, 
                Sensor::TYPE_MAGNETIC_FIELD, 
                Sensor::TYPE_ORIENTATION].map {|s| @manager.getDefaultSensor(s)}

    @canvas = Canvas.new
    @last_values = []
    @orientation_values = [0.0, 0.0, 0.0]
    @speed = 1.0
    
    @line_colors = [Color.argb(192, 255, 64,  64),
                    Color.argb(192, 64,  128, 64),
                    Color.argb(192, 64,  64,  255),
                    Color.argb(192, 64,  255, 255),
                    Color.argb(192, 128, 64,  128),
                    Color.argb(192, 255, 255, 64)]

    @paint = Paint.new
    @paint.setFlags(Paint::ANTI_ALIAS_FLAG);

    @rect = RectF.new(-0.5, -0.5, 0.5, 0.5)

    @path = Path.new
    @path.arcTo(@rect, 0, 180)
  end

  handle_resume do 
    @sensors.each{|s| @manager.registerListener(@sensor_event_listener, s, SensorManager::SENSOR_DELAY_FASTEST)}
  end

  handle_stop do 
    @sensors.each{|s| @manager.unregisterListener(@sensor_event_listener, s)}
  end

  @rv.handle_draw do |canvas|
    if @bitmap
      if (@last_x >= @max_x)
        @last_x = 0
        oneG = SensorManager::STANDARD_GRAVITY * @scale[0]
        @paint.setColor(0xFFAAAAAA)
        @canvas.drawColor(0xFFFFFFFF)
        @canvas.drawLine(0, @y_offset,        @max_x, @y_offset,        @paint)
        @canvas.drawLine(0, @y_offset + oneG, @max_x, @y_offset + oneG, @paint)
        @canvas.drawLine(0, @y_offset - oneG, @max_x, @y_offset - oneG, @paint)
      end

      canvas.drawBitmap(@bitmap, 0, 0, nil)

      0.upto(2) do |i|
        canvas.save(Canvas::MATRIX_SAVE_FLAG)
        canvas.translate(@circle_centers[i][0], @circle_centers[i][1])
        canvas.save(Canvas::MATRIX_SAVE_FLAG)
        @paint.setColor(0xFFC0C0C0)
        canvas.scale(@circle_size, @circle_size)
        canvas.drawOval(@rect, @paint)
        canvas.restore
        canvas.scale(@circle_size - 5, @circle_size - 5)
        @paint.setColor(0xFFff7010)
        canvas.rotate(0.0 - @orientation_values[i])
        canvas.drawPath(@path, @paint)
        canvas.restore
      end
    end
  end

  @rv.handle_size_changed do |w, h, oldw, oldh|
    @bitmap   = Bitmap.createBitmap(w, h, Bitmap::Config::RGB_565)
    @y_offset = h * 0.5
    @scale    = [(h * -0.5 * (1.0 / (SensorManager::STANDARD_GRAVITY * 2))),
                  (h * -0.5 * (1.0 / (SensorManager::MAGNETIC_FIELD_EARTH_MAX)))]
    @width    = w
    @height   = h
    @max_x    = w + ((@width < @height) ? 0 : 50)
    @last_x   = @max_x

    @canvas.setBitmap(@bitmap)
    @canvas.drawColor(0xFFFFFFFF)

    @circle_space = ((@width < @height) ? @width : @height) * 0.333333
    @circle_size = @circle_space - 32
    @circle_centers = []
    x = @circle_space * 0.5
    y = @circle_space * 0.5
    0.upto(2) do |i|
      if (@width < @height)
        @circle_centers << [x, y + 4.0]
        x += @circle_space
      else
        @circle_centers << [@width - (x + 4.0), y]
        y += @circle_space
      end
    end
  end

  @sensor_event_listener = RubotoSensorEventListener.new.handle_sensor_changed do |event|
    if @bitmap
      if (event.sensor.getType == Sensor::TYPE_ORIENTATION)
        @orientation_values = [event.values[0], event.values[1], event.values[2]]
      else
        j = (event.sensor.getType == Sensor::TYPE_MAGNETIC_FIELD) ? 1 : 0
        0.upto(2) do |i|
          k = i + j * 3
          v = @y_offset + event.values[i] * @scale[j]
          @paint.setColor(@line_colors[k])
          @canvas.drawLine(@last_x, @last_values[k], @last_x + @speed, v, @paint)
          @last_values[k] = v
        end
        @last_x += @speed if (event.sensor.getType == Sensor::TYPE_MAGNETIC_FIELD)
      end
      @rv.invalidate
    end
  end
end

