class AddDiscourseQaTopicPathToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :discourse_qa_topic_id, :integer
  end
end
