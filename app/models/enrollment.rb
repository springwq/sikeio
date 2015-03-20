class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  has_many :checkouts

  def next_uncompleted_lesson
    #得到尚未完成的第一个课程
    self.course.lessons.find do |lesson|
      !(Checkout.check_out?(self, lesson))
    end
  end

  def course
    target_course = Course.find(self.course_id)
    target_course.current_version = self.version if self.version
    target_course
  end

  def uncompleted_lessons
    self.course.lessons.select do |lesson|
      self.is_released?(lesson) && (!Checkout.check_out?(self, lesson))
    end
  end

  def completed_lessons
    self.course.lessons.select do |lesson|
      Checkout.check_out?(self, lesson) && self.is_released?(lesson)
    end
  end

  def all_completed?
    self.course.lessons.all? do |lesson|
      Checkout.check_out?(self, lesson)
    end
  end

  def released_lessons
    self.course.lessons.select do |lesson|
      self.is_released? lesson
    end
  end

  def unreleased_lessons
    self.course.lessons.select do |lesson|
      !(self.is_released? lesson)
    end
    
  end


  def uncompleted_lesson_day_left 
    lesson = course.next_lesson(self.next_uncompleted_lesson)
    next_lesson_start_day = course.release_day_of_lesson(lesson)
    
    next_lesson_start_day - day_from_start_time
  end

  def is_released?(lesson)
    day = self.course.release_day_of_lesson(lesson)
    day_from_start_time >= day
  end

  private

  def day_from_start_time
    today = Time.now.beginning_of_day.to_date
    course_start_time = self.start_time.beginning_of_day.to_date
    (today - course_start_time).to_i + 1
  end

end
