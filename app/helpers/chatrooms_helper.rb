module ChatroomsHelper
  def check_message(message)
    @chatroom_user.last_read_at < message.created_at
  end

  def get_other_users
    @users - [current_user]
  end

  def check_topic
    if @chatroom.topic && !@chatroom.direct_message
      "<button class='purpose-btn' data-toggle='modal'
      data-target='#exampleModal'>
       </i> #{@chatroom.topic} </button>".html_safe
    elsif @chatroom.direct_message && @chatroom.topic.nil?
      "Direct Conversation"
    else
      "<button class='purpose-btn' data-toggle='modal'
      data-target='#exampleModal' >
        <i class='fa fa-pencil'> </i>Add a topic
      </button>".html_safe
    end
  end

  def get_reciever_info
    arr = []
    arr += [
      current_user.username,
      current_user.first_name,
      current_user.last_name,
      current_user.job_description
    ]

    @reciever_info = (show_members(@chatroom.id) - [arr]).flatten
  end

  def check_purpose
    get_reciever_info
    if !@chatroom.direct_message && !@chatroom.purpose.nil?
      "<div class='purpose-panel' id='purpose-panel'>
        <div class='purpose'>
          <span><strong>Purpose</strong></span>
          <span class='hide-edit-btn'>Edit</span>
          <p class='channel-purpose'>#{@chatroom.purpose}<p>
        </div>
       <div id='purpose-form'>
        #{render 'chatrooms/purpose_form'}
       </div>
      </div>".html_safe
    elsif !@chatroom.direct_message
      if @chatroom.purpose.blank?
        "<div class='purpose-panel' id='purpose-panel'>
          <div class='purpose'>
            <span><strong>Purpose</strong></span>
            <span class='hide-edit-btn'>Edit</span>
            <p class='channel-purpose'>Add chatroom purpose<p>
          </div>
        <div id='purpose-form'>
          #{render 'chatrooms/purpose_form'}
        </div>
        </div>".html_safe
      end
    else
      "<p class='username'>#{@reciever_info[0]}</p>
      <p class='full-name'>#{@reciever_info[1]} #{@reciever_info[2]}</p>
      <p class='job-description'>#{@reciever_info[3]}</p>
      ".html_safe
    end
  end

  def reciever_fullname
    get_reciever_info
    if @chatroom.direct_message
      "<span class='full-name'>#{@reciever_info[1]} #{@reciever_info[2]}</span>
      ".html_safe
    end
  end

  def show_public_channels(current_user)
    current_user.chatrooms.where("direct_message = ?", false)
  end

  def show_user_count(chatroom_id)
    ChatroomUser.member?(chatroom_id).count
  end

  def show_members(chatroom_id)
    ChatroomUser.member?(chatroom_id).pluck(
      :username,
      :first_name,
      :last_name,
      :job_description
    )
  end

  def check_member(chatroom_id, user_id)
    ChatroomUser.has_joined?(chatroom_id, user_id).present?
  end

  def channel_details(chatroom_id)
    Chatroom.check_dm(chatroom_id) ? "this conversation" : @chatroom.name.to_s
  end

  def pinned_message_length(chatroom_id)
    Message.pinned?(chatroom_id).count
  end
end
