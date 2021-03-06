class Document < ActiveRecord::Base
  jibe

  belongs_to :folder, touch: true
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  has_attached_file :file,
    default_url: "/imgs/path.jpg",
    s3_permissions: :private
  
  validates_attachment_content_type :file, content_type: /jpeg|jpg|gif|png|doc|docx|xls|pdf|rdoc|txt|readme|html|text|md|markdown|js/
  validates_presence_of :file, :creator_id, :folder_id
end
