#######################################################
#
# arcs.rb (by Scott Moyer)
# 
# Port from Android API Demos
#
#######################################################

require "ruboto.rb"
confirm_ruboto_version(6, false)

java_import "android.graphics.Color"
java_import "android.graphics.Paint"
java_import "android.graphics.RectF"

ruboto_import "org.ruboto.RubotoView"

$activity.start_ruboto_activity "$arcs" do
  setTitle "Graphics/Arcs"

  @ruboto_view = RubotoView.new(self)

  setup_content do
    @sweep_inc = 2
    @start_inc = 15
    @mStart = 0.0
    @mSweep = 0.0
    @mBigIndex = 0

    @mPaints = []
    @mUseCenters = []
    @mOvals = []

    @mPaints[0] = Paint.new
    @mPaints[0].setAntiAlias(true)
    @mPaints[0].setStyle(Paint::Style::FILL)
    @mPaints[0].setColor(0x88FF0000)
    @mUseCenters[0] = false
        
    @mPaints[1] = Paint.new(@mPaints[0])
    @mPaints[1].setColor(0x8800FF00)
    @mUseCenters[1] = true
       
    @mPaints[2] = Paint.new(@mPaints[0])
    @mPaints[2].setStyle(Paint::Style::STROKE)
    @mPaints[2].setStrokeWidth(4)
    @mPaints[2].setColor(0x880000FF)
    @mUseCenters[2] = false

    @mPaints[3] = Paint.new(@mPaints[2])
    @mPaints[3].setColor(0x88888888)
    @mUseCenters[3] = true
        
    @mBigOval  = RectF.new( 40,  10, 280, 250)
    @mOvals[0] = RectF.new( 10, 270,  70, 330)
    @mOvals[1] = RectF.new( 90, 270, 150, 330)
    @mOvals[2] = RectF.new(170, 270, 230, 330)
    @mOvals[3] = RectF.new(250, 270, 310, 330)
        
    @mFramePaint = Paint.new
    @mFramePaint.setAntiAlias(true)
    @mFramePaint.setStyle(Paint::Style::STROKE)
    @mFramePaint.setStrokeWidth(0)

    @ruboto_view
  end

  def self.draw(canvas, oval, useCenters, paints, drawBig)
    if drawBig
      canvas.drawRect(@mBigOval, @mFramePaint)
      canvas.drawArc(@mBigOval, @mStart, @mSweep, useCenters, paints)
    end

    canvas.drawRect(oval, @mFramePaint)
    canvas.drawArc(oval, @mStart, @mSweep, useCenters, paints)
  end

  @ruboto_view.handle_draw do |canvas|
    canvas.drawColor(Color::WHITE)

    0.upto(3) {|i| draw(canvas, @mOvals[i], @mUseCenters[i], @mPaints[i], @mBigIndex == i)}
        
    @mSweep += @sweep_inc
    if (@mSweep > 360) 
      @mSweep -= 360
      @mStart += @start_inc
      @mStart -= 360 if @mStart >= 360 
      @mBigIndex = (@mBigIndex + 1) % @mOvals.length
    end

    @ruboto_view.invalidate
  end
end

