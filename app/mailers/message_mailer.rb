class MessageMailer < ActionMailer::Base
  def bulk(message_id, member_id, task_id = false)
    @message = Message.find(message_id)
    @member = @message.organization.members.find(member_id)

    if @member
      @contact_token = @member.id * CONFIG["secret_number"]
      @message_token = @message.id * CONFIG["secret_number"]
      
      if @message.attachment.exists?
        attachment = open(@message.attachment.url).read
        attachments[@message.attachment_file_name] = attachment
        attachment = nil
      end
      
      if mail(
          from: @message.creator.name_and_email,
          to: !@message.to.blank? ? @message.to : @member.name_and_email,
          subject: Message.content_for(@message.subject, @member)
        )
        
        Message.create_delivery_for message_id, member_id, task_id
      end
    end
  end
end
