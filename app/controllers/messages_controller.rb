class MessagesController < ApplicationController
  before_action :set_organization
  before_action :set_permissions, except: [:open, :click]
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = @org.messages
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = @org.messages.new()
    @message.assign_attributes params.fetch(:message).permit(permitted) if params[:message]
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = @org.messages.new(message_params)
    @message.creator = @member

    respond_to do |format|
      if @message.save!
        format.html { render nothing: true, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
        format.js
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def open
    begin
      @this_message = @org.messages.find(params[:message_token].to_i / CONFIG["secret_number"].to_i)
      @this_member = @org.members.find(params[:member_token].to_i / CONFIG["secret_number"].to_i)
      Message.create_event_for @this_message.id, @this_member.id, nil, "opened"
    rescue
    end
    
    render text: Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), content_type: 'image/gif'
  end
  
  def click
    begin
      @this_message = @org.messages.find(params[:message_token].to_i / CONFIG["secret_number"].to_i)
      @this_member = @org.members.find(params[:member_token].to_i / CONFIG["secret_number"].to_i)
      
      if @org.events.where(verb: "opened").where("data @> 'message.id=>#{@this_message.id}'").where("data @> 'member.id=>#{@this_member.id}'").empty?
        Message.create_event_for @this_message.id, @this_member.id, nil, "opened"
      end
      
      verb = "clicked"
      @org.events.create!(
        description: "{{ member.name }} #{verb} {{ message.subject }}",
        verb: verb,
        json_data: {
          ordinal: params[:ordinal],
          href: params[:href],
          message: @this_message.attributes,
          member: {
            key: @this_member.key
          }
        }
      )
    rescue
    end
    
    redirect_to CGI::unescape(params[:href])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = @org.messages.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(permitted)
    end
    
    def permitted
      [:subject, :body, :via, :attachment, member_ids: [], segment_ids: []]
    end
end
