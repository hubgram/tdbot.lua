--[[

   Naji - tdbot.lua - A simple Lua library for the telegram-bot.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see <http://www.gnu.org/licenses/>. 

]]--

-- telegram-bot's vector example form is like this : {v1, v2, v3}

-- If false or true crashed your telegram-bot, try to change true to 1 and false to 0

-- Main table
local I = {}

-- It's do nothing but suppress "lua: attempt to call a nil value" warning
function dl_cb(i, Naji)
end

-- There are three type of chats:
-- @chat_id = user, group, channel, and broadcast
-- @group_id = normal group
-- @channel_id = channel and broadcast
function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)

  if chat_id:match('^-100') then
    local channel_id = chat_id:gsub('-100', '')
    chat = {_ = channel_id, type = 'channel'}
  else
    local group_id = chat_id:gsub('-', '')
    chat = {_ = group_id, type = 'group'}
  end

  return chat
end

local function getInputFile(file, conversion_str, expectedsize)
  local input = tostring(file)
  local infile = {}

  if (conversion_str and expectedsize) then
    infile = {
      _ = 'inputFileGenerated',
      original_path = tostring(file),
      conversion = tostring(conversion_str),
      expected_size = expectedsize
    }
  else
    if input:match('/') then
      infile = {_ = 'inputFileLocal', path = file}
    elseif input:match('^%d+$') then
      infile = {_ = 'inputFileId', id = file}
    else
      infile = {_ = 'inputFilePersistentId', persistent_id = file}
    end
  end

  return infile
end

-- User can send bold, italic, and monospace text uses HTML or Markdown format.
function getParseMode(parse_mode)
  local P
  if parse_mode then
    local mode = parse_mode:lower()

    if mode == 'markdown' or mode == 'md' then
      P = {_ = "textParseModeMarkdown"}
    elseif mode == 'html' then
      P = {_ = "textParseModeHTML"}
    end
  end

  return P
end

-- (Temporary) workaround for currently buggy telegram-bot's vector(tanx to @rizaumami)
-- This will return lua array from strings:
-- {one, two, three}
-- {[0] = one, two, three}
-- {[0] = one, [1] = two, [2] = three}
local function getVector(str)
  local v = ''
  local i = 0

  for k in string.gmatch(str, '(%d%d%d+)') do
    v = v .. '[' .. i .. ']=' .. k .. ','
    i = i+1
  end

  return load('return {' .. v .. '}')()
end

-- Sends a message request.
-- @chat_id Chat to send message
-- @reply_to_message_id Identifier of a message to reply to or 0
-- @disable_notification Pass true, to disable notification about the message, doesn't works in secret chats
-- @from_background Pass true, if the message is sent from background
-- @reply_markup Bots only. Markup for replying to message
-- @input_message_content Content of a message to send
local function sendmsg(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, InputMessageContent, cb, cmd)
  assert (tdbot_function ({
    _ = 'sendMessage',
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification or 0,
    from_background = from_background or 1,
    reply_markup = reply_markup,
    input_message_content = InputMessageContent
  }, cb or dl_cb, cmd))
end

I.sendmsg = sendmsg

-- Returns current authorization state, offline request
function I.getAuthState(cb, cmd)
  assert (tdbot_function ({
    _ = "getAuthState",
  }, cb or dl_cb, cmd))
end

-- Sets user's phone number and sends authentication code to the user.
-- Works only when getAuthState returns authStateWaitPhoneNumber.
-- If phone number is not recognized or another error has happened, returns an error. Otherwise returns authStateWaitCode
-- @phone_number User's phone number in any reasonable format
-- @allow_flash_call Pass True, if code can be sent via flash call to the specified phone number
-- @is_current_phone_number Pass true, if the phone number is used on the current device. Ignored if allow_flash_call is False
function I.setAuthPhoneNumber(phone_number, allow_flash_call, is_current_phone_number, cb, cmd)
  assert (tdbot_function ({
    _ = "setAuthPhoneNumber",
    phone_number = phone_number,
    allow_flash_call = allow_flash_call,
    is_current_phone_number = is_current_phone_number
  }, cb or dl_cb, cmd))
end


-- Resends authentication code to the user.
-- Works only when getAuthState returns authStateWaitCode and next_codetype of result is not null.
-- Returns authStateWaitCode on success
function I.resendAuthCode(cb, cmd)
  assert (tdbot_function ({
    _ = "resendAuthCode",
  }, cb or dl_cb, cmd))
end


-- Checks authentication code.
-- Works only when getAuthState returns authStateWaitCode.
-- Returns authStateWaitPassword or authStateOk on success
-- @code Verification code from SMS, Telegram message, phone call or flash call
-- @first_name User first name, if user is yet not registered, 1-255 characters
-- @last_name Optional user last name, if user is yet not registered, 0-255 characters
function I.checkAuthCode(code, first_name, last_name, cb, cmd)
  assert (tdbot_function ({
    _ = "checkAuthCode",
    code = code,
    first_name = first_name,
    last_name = last_name
  }, cb or dl_cb, cmd))
end

-- Checks password for correctness.
-- Works only when getAuthState returns authStateWaitPassword.
-- Returns authStateOk on success
-- @password Password to check
function I.checkAuthPassword(password, cb, cmd)
  assert (tdbot_function ({
    _ = "checkAuthPassword",
    password = password
  }, cb or dl_cb, cmd))
end


-- Requests to send password recovery code to email.
-- Works only when getAuthState returns authStateWaitPassword.
-- Returns authStateWaitPassword on success
function I.requestAuthPasswordRecovery(cb, cmd)
  assert (tdbot_function ({
    _ = "requestAuthPasswordRecovery"
  }, cb or dl_cb, cmd))
end


-- Recovers password with recovery code sent to email.
-- Works only when getAuthState returns authStateWaitPassword.
-- Returns authStateOk on success
-- @recovery_code Recovery code to check
function I.recoverAuthPassword(recovery_code, cb, cmd)
  assert (tdbot_function ({
    _ = "recoverAuthPassword",
    recovery_code = recovery_code
  }, cb or dl_cb, cmd))
end


-- Logs out user.
-- If force == false, begins to perform soft log out, returns authStateLoggingOut after completion.
-- If force == true then succeeds almost immediately without cleaning anything at the server, but returns error with code 401 and description "unauthorized"
-- @force If true, just delete all local data. Session will remain in list of active sessions
function I.resetAuth(force, cb, cmd)
  assert (tdbot_function ({
    _ = "resetAuth",
    force = force or false
  }, cb or dl_cb, cmd))
end


-- Check bot's authentication token to log in as a bot.
-- Works only when getAuthState returns authStateWaitPhoneNumber.
-- Can be used instead of setAuthPhoneNumber and checkAuthCode to log in.
-- Returns authStateOk on success
-- @token Bot token
function I.checkAuthBotToken(token, cb, cmd)
  assert (tdbot_function ({
    _ = "checkAuthBotToken",
    token = token
  }, cb or dl_cb, cmd))
end


-- Returns current state of two-step verification
function I.getPasswordState(cb, cmd)
  assert (tdbot_function ({
    _ = "getPasswordState",
  }, cb or dl_cb, cmd))
end


-- Changes user password.
-- If new recovery email is specified, then error emailUNCONFIRMED is returned and password change will not be applied until email confirmation.
-- Application should call getPasswordState from time to time to check if email is already confirmed
-- @old_password Old user password
-- @new_password New user password, may be empty to remove the password
-- @new_hint New password hint, can be empty
-- @set_recovery_email Pass True, if recovery email should be changed
-- @new_recovery_email New recovery email, may be empty
function I.setPassword(old_password, new_password, new_hint, set_recovery_email, new_recovery_email, cb, cmd)
  assert (tdbot_function ({
    _ = "setPassword",
    old_password = old_password,
    new_password = new_password,
    new_hint = new_hint,
    set_recovery_email = set_recovery_email,
    new_recovery_email = new_recovery_email
  }, cb or dl_cb, cmd))
end

-- Returns set up recovery email.
-- This method can be used to verify a password provided by the user
-- @password Current user password
function I.getRecoveryEmail(password, cb, cmd)
  assert (tdbot_function ({
    _ = "getRecoveryEmail",
    password = password
	}, cb or dl_cb, cmd))
end


-- Changes user recovery email.
-- If new recovery email is specified, then error emailUNCONFIRMED is returned and email will not be changed until email confirmation.
-- Application should call getPasswordState from time to time to check if email is already confirmed.
-- If new_recovery_email coincides with the current set up email succeeds immediately and aborts all other requests waiting for email confirmation
-- @password Current user password
-- @new_recovery_email New recovery email
function I.setRecoveryEmail(password, new_recovery_email, cb, cmd)
  assert (tdbot_function ({
    _ = "setRecoveryEmail",
    password = password,
    new_recovery_email = new_recovery_email
  }, cb or dl_cb, cmd))
end

-- Requests to send password recovery code to email
function I.requestPasswordRecovery(cb, cmd)
  assert (tdbot_function ({
    _ = "requestPasswordRecovery",
  }, cb or dl_cb, cmd))
end

-- Recovers password with recovery code sent to email
-- @recovery_code Recovery code to check
function I.recoverPassword(recovery_code, cb, cmd)
  assert (tdbot_function ({
    _ = "recoverPassword",
    recovery_code = tostring(recovery_code)
  }, cb or dl_cb, cmd))
end

-- Creates new temporary password for payments processing
-- @password Persistent user password
-- @valid_for Time before temporary password will expire, seconds. Should be between 60 and 86400
function I.createTemporaryPassword(password, valid_for, cb, cmd)
  local valid_for = valid_for or 60

  if valid_for < 60 then
      valid_for = 60
  elseif valid_for > 86400 then
      valid_for = 86400
  end

  assert (tdbot_function ({
    _ = "createTemporaryPassword",
    password = tostring(password),
	valid_for = tonumber(valid_for)
  }, cb or dl_cb, cmd))
end

-- Returns information about current temporary password
function I.getTemporaryPasswordState(cb, cmd)
  assert (tdbot_function ({
    _ = 'getTemporaryPasswordState'
  }, cb or dl_cb, cmd))
end

-- Handles DC_UPDATE push service notification.
-- Can be called before authorization
-- @dc Value of 'dc' paramater of the notification
-- @addr Value of 'addr' parameter of the notification
function I.processDcUpdate(dc, addr, cb, cmd)
  assert (tdbot_function ({
    _ = 'processDcUpdate',
    dc = tostring(dc),
    addr = tostring(addr)
  }, cb or dl_cb, cmd))
end

-- Returns current logged in user
function I.getMe(cb, cmd)
  assert (tdbot_function ({
    _ = "getMe",
  }, cb or dl_cb, cmd))
end

-- Returns information about a user by its identifier, offline request if current user is not a bot
-- @user_id User identifier
function I.getUser(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getUser",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Returns full information about a user by its identifier
-- @user_id User identifier
function I.getUserFull(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getUserFull",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Returns information about a group by its identifier, offline request if current user is not a bot
-- @group_id Group identifier
function I.getGroup(group_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getGroup",
    group_id = getChatId(group_id)._
  }, cb or dl_cb, cmd))
end

-- Returns full information about a group by its identifier
-- @group_id Group identifier
function I.getGroupFull(group_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getGroupFull",
    group_id = getChatId(group_id)._
  }, cb or dl_cb, cmd))
end

-- Returns information about a channel by its identifier, offline request if current user is not a bot
-- @channel_id Channel identifier
function I.getChannel(channel_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getChannel",
    channel_id = getChatId(channel_id)._
  }, cb or dl_cb, cmd))
end

-- Returns full information about a channel by its identifier, cached for at most 1 minute
-- @channel_id Channel identifier
function I.getChannelFull(channel_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getChannelFull",
    channel_id = getChatId(channel_id)._
  }, cb or dl_cb, cmd))
end

-- Returns information about a secret chat by its identifier, offline request
-- @secret_chat_id Secret chat identifier
function I.getSecretChat(secret_chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getSecretChat",
    secret_chat_id = secret_chat_id
  }, cb or dl_cb, cmd))
end

-- Returns information about a chat by its identifier, offline request if current user is not a bot
-- @chat_id Chat identifier
function I.getChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Returns information about a message
-- @chat_id Identifier of the chat, message belongs to
-- @message_id Identifier of the message to get
function I.getMessage(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getMessage",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Returns information about messages.
-- If message is not found, returns null on the corresponding position of the result
-- @chat_id Identifier of the chat, messages belongs to
-- @message_ids Identifiers of the messages to get
function I.getMessages(chat_id, message_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "getMessages",
    chat_id = chat_id,
    message_ids = getVector(messageids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Returns information about a file, offline request
-- @file_id Identifier of the file to get
function I.getFile(file_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getFile",
    file_id = file_id
  }, cb or dl_cb, cmd))
end

-- Returns information about a file by its persistent id, offline request.
-- May be used to register a URL as a file for further uploading or sending as message.
-- @persistent_file_id Persistent identifier of the file to get
-- @file_type File type, if known, file_type = None|Animation|Audio|Document|Photo|ProfilePhoto|Secret|Sticker|Thumb|Unknown|Video|VideoNote|Voice|Wallpaper|SecretThumb
function I.getFilePersistent(persistent_file_id, file_type, cb, cmd)
  assert (tdbot_function ({
    _ = "getFilePersistent",
    persistent_file_id = persistent_file_id,
    file_type = "fileType" .. (file_type or "Unknown") 
  }, cb or dl_cb, cmd))
end

-- Returns list of chats in the right order, chats are sorted by (order, chat_id) in decreasing order.
-- For example, to get list of chats from the beginning, the offset_order should be equal 2^63 - 1
-- @offset_order Chat order to return chats from
-- @offset_chat_id Chat identifier to return chats from
-- @limit Maximum number of chats to be returned. There may be less than limit chats returned even the end of the list is not reached
function I.getChats(offset_order, offset_chat_id, limit, cb, cmd)
  if not limit or limit > 20 then
    limit = 20
  end

  assert (tdbot_function ({
    _ = "getChats",
    offset_order = offset_order or 9223372036854775807,
    offset_chat_id = offset_chat_id or 0,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Searches public chat by its username.
-- Currently only private and channel chats can be public.
-- Returns chat if found, otherwise some error is returned
-- @username Username to be resolved
function I.searchPublicChat(username, cb, cmd)
  assert (tdbot_function ({
    _ = "searchPublicChat",
    username = username
  }, cb or dl_cb, cmd))
end

-- Searches public chats by prefix of their username.
-- Currently only private and channel (including supergroup) chats can be public.
-- Returns meaningful number of results.
-- Returns nothing if length of the searched username prefix is less than 5.
-- Excludes private chats with contacts from the results
-- @username_prefix Prefix of the username to search
function I.searchPublicChats(username_prefix, cb, cmd)
  assert (tdbot_function ({
    _ = "searchPublicChats",
    username_prefix  = username_prefix
  }, cb or dl_cb, cmd))
end

-- Searches for specified query in the title and username of known chats, offline request.
-- Returns chats in the order of them in the chat list
-- @query Query to search for, if query is empty, returns up to 20 recently found chats
-- @limit Maximum number of chats to be returned
function I.searchChats(query, limit, cb, cmd)
  if not limit or limit > 20 then
    limit = 20
  end

  assert (tdbot_function ({
    _ = "searchChats",
    query = query,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Returns a list of frequently used chats.
-- Supported only if chat info database is enabled.
-- @category Category of chats to return
-- category : Users|Bots|Groups|Channels|InlineBots|Calls
-- @limit Maximum number of chats to be returned, at most 30
function I.getTopChats(category, limit, cb, cmd)
  if not limit or limit > 30 then
    limit = 30
  end

  assert (tdbot_function ({
    _ = "getTopChats",
    category = {
	  _ = "topChatCategory" .. (category or "Channels")
	},
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Delete a chat from a list of frequently used chats.
-- Supported only if chat info database is enabled.
-- @category Category
-- @chat_id Chat identifier
function I.deleteTopChat(category, chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteTopChat",
    category = {
	  _ = "topChatCategory" .. (category or "Channels")
	},
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Adds chat to the list of recently found chats.
-- The chat is added to the beginning of the list.
-- If the chat is already in the list, at first it is removed from the list
-- @chat_id Identifier of the chat to add
function I.addRecentlyFoundChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "addRecentlyFoundChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Deletes chat from the list of recently found chats
-- @chat_id Identifier of the chat to delete
function I.deleteRecentlyFoundChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteRecentlyFoundChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Clears list of recently found chats
function I.deleteRecentlyFoundChats(cb, cmd)
  assert (tdbot_function ({
    _ = "deleteRecentlyFoundChats",
  }, cb or dl_cb, cmd))
end

-- Returns list of common chats with an other given user.
-- Chats are sorted by their type and creation date
-- @user_id User identifier
-- @offset_chat_id Chat identifier to return chats from, use 0 for the first request
-- @limit Maximum number of chats to be returned, up to 100
function I.getCommonChats(user_id, offset_chat_id, limit, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "getCommonChats",
    user_id = user_id,
    offset_chat_id = offset_chat_id,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Returns list of created public chats
function I.getCreatedPublicChats(cb, cmd)
  assert (tdbot_function ({
    _ = 'getCreatedPublicChats'
  }, cb or dl_cb, cmd))
end

-- Returns messages in a chat.
-- Automatically calls openChat.
-- Returns result in reverse chronological order, i.e. in order of decreasing message.message_id.
-- Offline request if only_local is true
-- @chat_id Chat identifier
-- @from_message_id Identifier of the message near which we need a history, you can use 0 to get results from the beginning, i.e. from oldest to newest
-- @offset Specify 0 to get results exactly from from_message_id or negative offset to get specified message and some newer messages
-- @limit Maximum number of messages to be returned, should be positive and can't be greater than 100.
-- If offset is negative, limit must be greater than -offset.
-- There may be less than limit messages returned even the end of the history is not reached
-- @only_local Return only locally available messages without sending network requests
function I.getChatHistory(chat_id, from_message_id, offset, limit, only_local, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "getChatHistory",
    chat_id = chat_id,
    from_message_id = from_message_id,
    offset = offset or 0,
    limit = limit,
    only_local = only_local
  }, cb or dl_cb, cmd))
end

-- Deletes all messages in the chat.
-- Can't be used for channel chats
-- @chat_id Chat identifier
-- @remove_from_chat_list Pass true, if chat should be removed from the chat list
function I.deleteChatHistory(chat_id, remove_from_chat_list, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteChatHistory",
    chat_id = chat_id,
    remove_from_chat_list = remove_from_chat_list
  }, cb or dl_cb, cmd))
end

-- Searches for messages with given words in the chat.
-- Returns result in reverse chronological order, i.e. in order of decreasing message_id.
-- Doesn't work in secret chats with non-empty query (searchSecretMessages should be used instead) or without enabled message database
-- @chat_id Chat identifier to search in
-- @query Query to search for
-- @sender_user_id If not 0, only messages sent by the specified user will be returned.
-- Doesn't supported in secret chats
-- @from_message_id Identifier of the message from which we need a history, you can use 0 to get results from the beginning
-- @limit Maximum number of messages to be returned, can't be greater than 100.
-- There may be less than limit messages returned even the end of the history is not reached
-- @filter Filter for content of searched messages
-- filter (Return all found messages) = Empty
-- flter : Animation|Audio|Document|Photo|Video|Voice|PhotoAndVideo|Url|ChatPhoto|Call|MissedCall|VideoNote|VoiceAndVideoNote
function I.searchChatMessages(chat_id, query, sender_user_id, from_message_id, limit, filter, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "searchChatMessages",
    chat_id = chat_id,
	query = query,
	sender_user_id = sender_user_id or 0,
    from_message_id = from_message_id or 0,
    limit = limit,
    filter = {
      _ = 'searchMessagesFilter' .. (filter or "Empty")
    },
  }, cb or dl_cb, cmd))
end

-- Searches for messages in all chats except secret chats.
-- Returns result in reverse chronological order, i.e. in order of decreasing (date, chat_id, message_id)
-- @query Query to search for
-- @offset_date Date of the message to search from, you can use 0 or any date in the future to get results from the beginning
-- @offset_chat_id Chat identifier of the last found message or 0 for the first request
-- @offset_message_id Message identifier of the last found message or 0 for the first request
-- @limit Maximum number of messages to be returned, at most 100
function I.searchMessages(query, offset_date, offset_chat_id, offset_message_id, limit, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "searchMessages",
    query = query,
    offset_date = offset_date,
    offset_chat_id = offset_chat_id,
    offset_message_id = offset_message_id,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Searches for messages in secret chats.
-- Returns result in reverse chronological order
-- @chat_id Identifier of a chat to search in. Specify 0 to search in all secret chats
-- @query Query to search for. If empty, searchChatMessages should be used instead
-- @from_search_id Identifier from the result of previous request, use 0 to get results from the beginning
-- @limit Maximum number of messages to be returned, can't be greater than 100
-- @filter Filter for content of searched messages
function I.searchSecretMessages(chat_id, query, from_search_id, limit, filter, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "searchSecretMessages",
    chat_id = chat_id,
    query = query,
    from_search_id = from_search_id,
    limit = limit,
    filter = {
      _ = 'SearchMessagesFilter' .. (filter or "Empty")
    }
  }, cb or dl_cb, cmd))
end

-- Searches for call messages. Returns result in reverse chronological order, i.e. in order of decreasing message_id
-- @from_message_id Identifier of the message from which to search, you can use 0 to get results from beginning
-- @limit Maximum number of messages to be returned, can't be greater than 100.
-- There may be less than limit messages returned even the end of the history is not reached filter
-- @only_missed If true, return only messages with missed calls
function I.searchCallMessages(from_message_id, limit, only_missed, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end

  assert (tdbot_function ({
    _ = "searchChatMessages",
    from_message_id = from_message_id,
    limit = limit,
    only_missed = only_missed
  }, cb or dl_cb, cmd))
end

-- Returns public HTTPS link to a message. Available only for messages in public channels
-- @chat_id Identifier of the chat, message belongs to
-- @message_id Identifier of the message
function I.getPublicMessageLink(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getPublicMessageLink",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Invites bot to a chat (if it is not in the chat) and send /start to it.
-- Bot can't be invited to a private chat other than chat with the bot.
-- Bots can't be invited to broadcast channel chats and secret chats.
-- Returns sent message.
-- @bot_user_id Identifier of the bot
-- @chat_id Identifier of the chat
-- @parameter Hidden parameter sent to bot for deep linking (https://api.telegram.org/bots#deep-linking)
function I.sendBotStartMessage(bot_user_id, chat_id, parameter, cb, cmd)
  assert (tdbot_function ({
    _ = "sendBotStartMessage",
    bot_user_id = bot_user_id,
    chat_id = chat_id,
    parameter = parameter
  }, cb or dl_cb, cmd))
end

-- Sends result of the inline query as a message.
-- Returns sent message.
-- Always clears chat draft message
-- @chat_id Chat to send message
-- @reply_to_message_id Identifier of a message to reply to or 0
-- @disable_notification Pass true, to disable notification about the message, doesn't works in secret chats
-- @from_background Pass true, if the message is sent from background
-- @query_id Identifier of the inline query
-- @result_id Identifier of the inline result
function I.sendInlineQueryResultMessage(chat_id, reply_to_message_id, disable_notification, from_background, query_id, result_id, cb, cmd)
  assert (tdbot_function ({
    _ = "sendInlineQueryResultMessage",
    chat_id = chat_id,
    reply_to_message_id = reply_to_message_id,
    disable_notification = disable_notification,
    from_background = from_background,
    query_id = query_id,
    result_id = result_id
  }, cb or dl_cb, cmd))
end

-- Forwards previously sent messages.
-- Returns forwarded messages in the same order as message identifiers passed in message_ids.
-- If message can't be forwarded, null will be returned instead of the message.
-- @chat_id Identifier of a chat to forward messages
-- @from_chat_id Identifier of a chat to forward from
-- @message_ids Identifiers of messages to forward
-- @disable_notification Pass true, to disable notification about the message, doesn't works if messages are forwarded to secret chat
-- @from_background Pass true, if the message is sent from background
function I.forwardMessages(chat_id, from_chat_id, message_ids, disable_notification, cb, cmd)
  assert (tdbot_function ({
    _ = "forwardMessages",
    chat_id = chat_id,
    from_chat_id = from_chat_id,
    message_ids = getVector(message_ids), -- vector<int>
    disable_notification = disable_notification,
    from_background = 1
  }, cb or dl_cb, cmd))
end

-- Changes current ttl setting in a secret chat and sends corresponding message
-- @chat_id Chat identifier
-- @ttl New value of ttl in seconds
function I.sendChatSetTtlMessage(chat_id, ttl, cb, cmd)
  assert (tdbot_function ({
    _ = "sendChatSetTtlMessage",
    chat_id = chat_id,
    ttl = ttl
  }, cb or dl_cb, cmd))
end

-- Sends notification about screenshot taken in a chat
-- Works only in private and secret chats
-- @chat_id Chat identifier
function I.sendChatScreenshotTakenNotification(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "sendChatScreenshotTakenNotification",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Deletes messages.
-- @chat_id Chat identifier
-- @message_ids Identifiers of messages to delete
-- @revoke Pass true to try to delete sent messages for all chat members (may fail if messages are too old). Is always true for Channels and SecretChats
function I.deleteMessages(chat_id, message_ids, revoke, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteMessages",
    chat_id = chat_id,
    message_ids = getVector(message_ids), -- vector
    revoke = revoke or true
  }, cb or dl_cb, cmd))
end

-- Deletes all messages in the chat sent by the specified user.
-- Works only in supergroup channel chats, needs can_delete_messages administrator privileges
-- @chat_id Chat identifier
-- @user_id User identifier
function I.deleteMessagesFromUser(chat_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteMessagesFromUser",
    chat_id = chat_id,
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Edits text of text or game message.
-- Non-bots can edit message in a limited period of time.
-- Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to
-- @message_id Identifier of the message
-- @reply_markup Bots only. New message reply markup
-- @input_message_content New text content of the message. Should be of type InputMessageText
function I.editMessageText(p)

  local params
  if type(p) == 'table' then
        params = p
    else
        params = {p}
  end
  
  setmetatable(params,{__index={message_id=0, reply_markup=nil, disable_web_page_preview= 1, entities = {},parse_mode = nil, cb=dl_cb,cmd= nil}})
  local chat_id, message_id, reply_markup, text, disable_web_page_preview, entities, parse_mode, cb, cmd=
    params[1] or params.chat_id, 
    params[2] or params.message_id,
    params[3] or params.reply_markup,
	params[4] or params.text, 
    params[5] or params.disable_web_page_preview,
    params[6] or params.entities,
	getParseMode(params[7] or params.entities),
	params[8] or params.cb,
    params[9] or params.cmd
	
  assert (tdbot_function ({
    _ = "editMessageText",
    chat_id,
    message_id ,
    reply_markup , -- reply_markup:ReplyMarkup
    input_message_content = {
      _ = "inputMessageText",
      text ,
      disable_web_page_preview,
      clear_draft = 0,
      entities , -- vector<textEntity>
      parse_mode
    },
  }, cb, cmd))
end

-- Edits message content caption.
-- Non-bots can edit message in a limited period of time.
-- Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to
-- @message_id Identifier of the message
-- @reply_markup Bots only. New message reply markup
-- @caption New message content caption, 0-200 characters
function I.editMessageCaption(chat_id, message_id, reply_markup, caption, cb, cmd)
  assert (tdbot_function ({
    _ = "editMessageCaption",
    chat_id = chat_id,
    message_id = message_id,
    reply_markup = reply_markup, -- reply_markup:ReplyMarkup
    caption = caption
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Edits message reply markup.
-- Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to
-- @message_id Identifier of the message
-- @reply_markup New message reply markup
function I.editMessageReplyMarkup(inline_message_id, reply_markup, caption, cb, cmd)
  assert (tdbot_function ({
    _ = "editInlineMessageCaption",
    inline_message_id = inline_message_id,
    reply_markup = reply_markup, -- reply_markup:ReplyMarkup
    caption = caption
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Edits text of an inline text or game message sent via bot
-- @inline_message_id Inline message identifier
-- @reply_markup New message reply markup
-- @input_message_content New text content of the message. Should be of type InputMessageText
function I.editInlineMessageText(inline_message_id, reply_markup, text, disable_web_page_preview, cb, cmd)
  assert (tdbot_function ({
    _ = "editInlineMessageText",
    inline_message_id = inline_message_id,
    reply_markup = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content = {
      _ = "inputMessageText",
      text = text,
      disable_web_page_preview = disable_web_page_preview,
      clear_draft = 0,
      entities = {}
    },
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Edits caption of an inline message content sent via bot
-- @inline_message_id Inline message identifier
-- @reply_markup New message reply markup
-- @caption New message content caption, 0-200 characters
function I.editInlineMessageCaption(inline_message_id, reply_markup, caption, cb, cmd)
  assert (tdbot_function ({
    _ = "editInlineMessageCaption",
    inline_message_id = inline_message_id,
    reply_markup = reply_markup, -- reply_markup:ReplyMarkup
    caption = caption
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Edits reply markup of an inline message sent via bot
-- @inline_message_id Inline message identifier
-- @reply_markup New message reply markup
function I.editInlineMessageReplyMarkup(inline_message_id, reply_markup, cb, cmd)
  assert (tdbot_function ({
    _ = "editInlineMessageReplyMarkup",
    inline_message_id = inline_message_id,
    reply_markup = reply_markup -- reply_markup:ReplyMarkup
  }, cb or dl_cb, cmd))
end

-- Returns all mentions, hashtags, bot commands, URLs and emails contained in the text. Offline method.
-- Can be called before authorization.
-- Can be called synchronously
-- @text Text to find entites in
function I.getTextEntities(text, cb, cmd)
  assert (tdbot_function ({
    _ = "getTextEntities",
    text = text
  }, cb or dl_cb, cmd))
end

-- Returns file's mime type guessing only by its extension.
-- Offline method. Can be called before authorization.
-- Can be called synchronously
--  @file_name Name of the file or path to the file
function I.getFileMimeType(file_name, cb, cmd)
  assert (tdbot_function ({
    _ = "getFileMimeType",
    file_name = file_name
  }, cb or dl_cb, cmd))
end

-- Sends inline query to a bot and returns its results.
-- Returns error with code 502 if bot fails to answer the query before query timeout expires.
-- Unavailable for bots
-- @bot_user_id Identifier of the bot send query to
-- @chat_id Identifier of the chat, where the query is sent
-- @user_location User location, only if needed
-- @latitude Latitude of location in degrees as defined by sender
-- @longitude Longitude of location in degrees as defined by sender
-- @query Text of the query
-- @offset Offset of the first entry to return
function I.getInlineQueryResults(bot_user_id, chat_id, latitude, longitude, query, offset, cb, cmd)
  assert (tdbot_function ({
    _ = "getInlineQueryResults",
    bot_user_id = bot_user_id,
    chat_id = chat_id,
    user_location = {
      _ = "location",
      latitude = latitude,
      longitude = longitude
    },
    query = query,
    offset = offset
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Sets result of the inline query
-- @inline_queryid Identifier of the inline query
-- @is_personal Does result of the query can be cached only for specified user
-- @results Results of the query
-- @cache_time Allowed time to cache results of the query in seconds
-- @next_offset Offset for the next inline query, pass empty string if there is no more results
-- @switch_pm_text If non-empty, this text should be shown on the button, which opens private chat with the bot and sends bot start message with parameter switch_pm_parameter
-- @switch_pm_parameter Parameter for the bot start message
function I.answerInlineQuery(inline_query_id, is_personal, results, cache_time, next_offset, switch_pm_text, switch_pm_parameter, cb, cmd)
  assert (tdbot_function ({
    _ = "answerInlineQuery",
    inline_query_id = inline_query_id,
    is_personal = is_personal,
    results = results, --vector<InputInlineQueryResult>,
    cache_time = cache_time,
    next_offset = next_offset,
    switch_pm_text = switch_pm_text,
    switch_pm_parameter = switch_pm_parameter
  }, cb or dl_cb, cmd))
end

-- Sends callback query to a bot and returns answer to it.
-- Returns error with code 502 if bot fails to answer the query before query timeout expires.
-- Unavailable for bots
-- @chat_id Identifier of the chat with a message
-- @message_id Identifier of the message, from which the query is originated
-- @payload Query payload
-- @text Text of the answer
-- @show_alert If true, an alert should be shown to the user instead of a toast
-- @url URL to be open
function I.getCallbackQueryAnswer(chat_id, message_id, query_payload, cb, cmd)
  local callback_query_payload = {}

  if query_payload == 'Data' then
    callback_query_payload.data = cb_query_payload
  elseif query_payload == 'Game' then
    callback_query_payload.game_short_name = cb_query_payload
  end

  callback_query_payload._ = 'callbackQueryPayload' .. query_payload,

  assert (tdbot_function ({
    _ = 'getCallbackQueryAnswer',
    chat_id = chat_id,
    message_id = message_id,
    payload = callback_query_payload
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Sets result of a callback query
-- @callback_queryid Identifier of the callback query
-- @text Text of the answer
-- @show_alert If true, an alert should be shown to the user instead of a toast
-- @url Url to be opened
-- @cache_time Allowed time to cache result of the query in seconds
function I.answerCallbackQuery(callback_query_id, text, show_alert, url, cache_time, cb, cmd)
  assert (tdbot_function ({
    _ = "answerCallbackQuery",
    callback_query_id = callback_query_id,
    text = text,
    show_alert = show_alert,
    url = url,
    cache_time = cache_time
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Sets result of a shipping query
-- @shipping_query_id Identifier of the shipping query
-- @shipping_options Available shipping options
-- @error_message Error message, empty on success
function I.answerShippingQuery(shipping_query_id, shipping_options, error_message, cb, cmd)
  assert (tdbot_function ({
    _ = "answerShippingQuery",
    shipping_query_id = shipping_query_id,
    shipping_options = shipping_options, -- vector<shippingOption>
    error_message = error_message
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Sets result of a pre checkout query
-- @pre_checkout_queryid Identifier of the pre-checkout query
-- @error_message Error message, empty on success
function I.answerPreCheckoutQuery(pre_checkout_queryid, error_message, cb, cmd)
  assert (tdbot_function ({
    _ = "answerPreCheckoutQuery",
    pre_checkout_queryid = pre_checkout_queryid,
    error_message = error_message
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Updates game score of the specified user in the game
-- @chat_id Chat a message with the game belongs to
-- @message_id Identifier of the message
-- @edit_message True, if message should be edited
-- @user_id User identifier
-- @score New score
-- @force Pass True to update the score even if it decreases. If score is 0, user will be deleted from the high scores table
function I.setGameScore(chat_id, message_id, edit_message, user_id, score, force, cb, cmd)
  assert (tdbot_function ({
    _ = "setGameScore",
    chat_id = chat_id,
    message_id = message_id,
    edit_message = edit_message,
    user_id = user_id,
    score = score,
    force = force
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Updates game score of the specified user in the game
-- @inline_message_id Inline message identifier
-- @edit_message True, if message should be edited
-- @user_id User identifier
-- @score New score
-- @force Pass True to update the score even if it decreases. If score is 0, user will be deleted from the high scores table
function I.setInlineGameScore(inline_message_id, edit_message, user_id, score, force, cb, cmd)
  assert (tdbot_function ({
    _ = "setInlineGameScore",
    inline_message_id = inline_message_id,
    edit_message = edit_message,
    user_id = user_id,
    score = score,
    force = force
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Returns game high scores and some part of the score table around of the specified user in the game
-- @chat_id Chat a message with the game belongs to
-- @message_id Identifier of the message
-- @user_id User identifie
function I.getGameHighScores(chat_id, message_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getGameHighScores",
    chat_id = chat_id,
    message_id = message_id,
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Returns game high scores and some part of the score table around of the specified user in the game
-- @inline_message_id Inline message identifier
-- @user_id User identifier
function I.getInlineGameHighScores(inline_message_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getInlineGameHighScores",
    inline_message_id = inline_message_id,
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Deletes default reply markup from chat.
-- This method needs to be called after one-time keyboard or ForceReply reply markup has been used.
-- UpdateChatReplyMarkup will be send if reply markup will be changed
-- @chat_id Chat identifier
-- @message_id Message identifier of used keyboard
function I.deleteChatReplyMarkup(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteChatReplyMarkup",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Sends notification about user activity in a chat
-- @chat_id Chat identifier
-- @action Action description
-- action = Typing|Cancel|RecordingVideo|UploadingVideo|RecordingVoice|UploadingVoice|UploadingPhoto|UploadingDocument|ChoosingLocation|ChoosingContact|StartPlayingGame|RecordingVideoNote|UploadingVideoNote
function I.sendChatAction(chat_id, action, progress, cb, cmd)
  assert (tdbot_function ({
    _ = "sendChatAction",
    chat_id = chat_id,
    action = {
      _ = "chatAction" .. action,
      progress = progress or 100
    }
  }, cb or dl_cb, cmd))
end

-- Chat is opened by the user.
-- Many useful activities depends on chat being opened or closed. For example, in channels all updates are received only for opened chats
-- @chat_id Chat identifier
  function I.openChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "openChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Chat is closed by the user.
-- Many useful activities depends on chat being opened or closed.
-- @chat_id Chat identifier
function I.closeChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "closeChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Messages are viewed by the user.
-- Many useful activities depends on message being viewed. For example, marking messages as read, incrementing of view counter, updating of view counter, removing of deleted messages in channels
-- @chat_id Chat identifier
-- @message_ids Identifiers of viewed messages
function I.viewMessages(chat_id, message_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "viewMessages",
    chat_id = chat_id,
    message_ids = message_ids -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Message content is opened, for example the user has opened a photo, a video, a document, a location or a venue or have listened to an audio or a voice message.
-- You will receive updateOpenMessageContent if something has changed
-- @chat_id Chat identifier of the message
-- @message_id Identifier of the message with opened content
function I.openMessageContent(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "openMessageContent",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Returns existing chat corresponding to the given user
-- @user_id User identifier
function I.createPrivateChat(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "createPrivateChat",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Returns existing chat corresponding to the known group
-- @group_id Group identifier
function I.createGroupChat(group_id, cb, cmd)
  assert (tdbot_function ({
    _ = "createGroupChat",
    group_id = getChatId(group_id)._
  }, cb or dl_cb, cmd))
end

-- Returns existing chat corresponding to the known channel
-- @channel_id Channel identifier
function I.createChannelChat(channel_id, cb, cmd)
  assert (tdbot_function ({
    _ = "createChannelChat",
    channel_id = getChatId(channel_id)._
  }, cb or dl_cb, cmd))
end

-- Returns existing chat corresponding to the known secret chat
-- @secret_chat_id SecretChat identifier
function I.createSecretChat(secret_chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "createSecretChat",
    secret_chat_id = secret_chat_id
  }, cb or dl_cb, cmd))
end

-- Creates new group chat and send corresponding messageGroupChatCreate, returns created chat
-- @user_ids Identifiers of users to add to the group
-- @title Title of new group chat, 1-255 characters
function I.createNewGroupChat(user_ids, title, cb, cmd)
  assert (tdbot_function ({
    _ = "createNewGroupChat",
    user_ids = user_ids, -- vector<int>
    title = title
  }, cb or dl_cb, cmd))
end

-- Creates new channel chat and send corresponding messageChannelChatCreate, returns created chat
-- @title Title of new channel chat, 1-255 characters
-- @is_supergroup True, if supergroup chat should be created
-- @description Information about the channel, 0-255 characters
function I.createNewChannelChat(title, is_supergroup, description, cb, cmd)
  assert (tdbot_function ({
    _ = "createNewChannelChat",
    title = title,
    is_supergroup = is_supergroup,
    description = description
  }, cb or dl_cb, cmd))
end

-- Creates new secret chat, returns created chat
-- @user_id Identifier of a user to create secret chat with
function I.createNewSecretChat(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "createNewSecretChat",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Creates new channel supergroup chat from existing group chat and send corresponding messageChatMigrateTo and messageChatMigrateFrom. Deactivates group
-- @chat_id Group chat identifier
function I.migrateGroupChatToChannelChat(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "migrateGroupChatToChannelChat",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Changes chat title.
-- Works only for group and channel chats.
-- Requires administrator rights in groups and appropriate administrator right in channels.
-- Title will not change before request to the server completes
-- @chat_id Chat identifier
-- @title New title of the chat, 1-255 characters
function I.changeChatTitle(chat_id, title, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatTitle",
    chat_id = chat_id,
    title = title
  }, cb or dl_cb, cmd))
end

-- Changes chat photo.
--  Works only for group and channel chats.
-- Requires administrator rights in groups and appropriate administrator right in channels.
-- Photo will not change before request to the server completes
-- @chat_id Chat identifier
-- @photo New chat photo. You can use zero InputFileId to delete chat photo. Files accessible only by HTTP URL are not acceptable
function I.changeChatPhoto(chat_id, photo, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatPhoto",
    chat_id = chat_id,
    photo = getInputFile(photo)
  }, cb or dl_cb, cmd))
end

-- Changes chat draft message
-- @chat_id Chat identifier
-- @draft_message New draft message, nullable
function I.changeChatDraftMessage(chat_id, reply_to_message_id, text, disable_web_page_preview, clear_draft, entities, parse_mode, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatDraftMessage",
    chat_id = chat_id,
    draft_message = {
      _ = "draftMessage",
      reply_to_message_id = reply_to_message_id,
      input_message_text = {
        _ = "inputMessageText",
        text = text,
        disable_web_page_preview = disable_web_page_preview,
        clear_draft = clear_draft,
        entities = entities or {}, -- vector<textEntity>
        parse_mode = getParseMode(parse_mode),
      },
    },
  }, cb or dl_cb, cmd))
end

-- description Changes chat pinned state.
-- You can pin up to getOption("pinned_chat_count_max") non-secret chats and the same number of secret chats
-- @chat_id Chat identifier
-- @is_pinned New value of is_pinned
function I.toggleChatIsPinned(chat_id, is_pinned, cb, cmd)
  assert (tdbot_function ({
    _ = "toggleChatIsPinned",
    chat_id = chat_id,
    is_pinned = is_pinned,
  }, cb or dl_cb, cmd))
end

-- Changes client data associated with a chat
-- @chat_id Chat identifier
-- @client_data New value of client_data
function I.setChatClientData(chat_id, client_data, cb, cmd)
  assert (tdbot_function ({
    _ = "setChatClientData",
    chat_id = chat_id,
    client_data = client_data,
  }, cb or dl_cb, cmd))
end

-- Adds new member to chat.
-- Members can't be added to private or secret chats.
-- Member will not be added until chat state will be synchronized with the server.
-- Member will not be added if application is killed before it can send request to the server
-- @chat_id Chat identifier
-- @user_id Identifier of the user to add
-- @forward_limit Number of previous messages from chat to forward to new member, ignored for channel chats
function I.addChatMember(chat_id, user_id, forward_limit, cb, cmd)
  assert (tdbot_function ({
    _ = "addChatMember",
    chat_id = chat_id,
    user_id = user_id,
    forward_limit = forward_limit or 50
  }, cb or dl_cb, cmd))
end

-- Adds many new members to the chat.
-- Currently, available only for channels.
-- Can't be used to join the channel.
-- Member will not be added until chat state will be synchronized with the server.
-- Member will not be added if application is killed before it can send request to the server
-- @chat_id Chat identifier
-- @user_ids Identifiers of the users to add
function I.addChatMembers(chat_id, user_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "addChatMembers",
    chat_id = chat_id,
    user_ids = getVector(user_ids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Changes status of the chat member, need appropriate privileges.
-- This function is currently  not suitable for adding new members to the chat, use addChatMember instead.
-- Status will not be changed until chat state will be synchronized with the server.
-- Status will not be changed if application is killed before it can send request to the server
-- @chat_id Chat identifier
-- @user_id Identifier of the user to edit status
-- @status New status of the member in the chat
-- status = Creator|Administrator|Restricted|Member|Left|Banned

-- User is creator of the chat which has all administrator priviledges
function I.creator_user(chat_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusCreator"
	}
  }, cb or dl_cb, cmd))
end

-- User is a member of the chat, but have no any additional privileges or restrictions
function I.demote_user(chat_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusMember"
	}
  }, cb or dl_cb, cmd))
end

-- User is not a chat member
function I.kick_user(chat_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = tonumber(chat_id),
    user_id = user_id,
    status = {
      _ = "chatMemberStatusLeft"
	}
  }, cb or dl_cb, cmd))
end

-- User was banned (and obviously is not a chat member) and can't return to the chat or view messages
-- @banned_until_date Date when the user will be unbanned,
-- 0 if never. Unix time. If user is banned for more than 366 days or less than 30 seconds from the current time it considered to be banned forever
function I.ban_user(chat_id, user_id, banned_until_date, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
      _ = "chatMemberStatusBanned",
	  banned_until_date = banned_until_date
	}
  }, cb or dl_cb, cmd))
end

-- @can_be_edited True, if current user has rights to edit administrator privileges of that user
-- @can_change_info True, if the administrator can change chat title, photo and other settings
-- @can_delete_messages True, if the administrator can delete messages of other users
-- @can_invite_users True, if the administrator can invite new users to the chat
-- @can_restrict_members True, if the administrator can restrict, ban or unban chat members
-- @can_pin_messages True, if the administrator can pin messages, supergroup channels only
-- @can_promote_members True, if the administrator can add new administrators with a subset of his own privileges or demote administrators directly or indirectly promoted by him
function I.promote_user(chat_id, user_id, can_change_info, can_delete_messages, can_invite_users, can_restrict_members, can_pin_messages, can_promote_members, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
	  _ = "chatMemberStatusAdministrator",
	  can_change_info = can_change_info or false,
	  can_delete_messages = can_delete_messages or false,
	  can_invite_users = can_invite_users or false,
	  can_restrict_members = can_restrict_members or false,
	  can_pin_messages = can_pin_messages or false,
	  can_promote_members = can_promote_members or false
    }
  }, cb or dl_cb, cmd))
end

-- @can_post_messages True, if the administrator can create channel posts, broadcast channels only
-- @can_edit_messages True, if the administrator can edit messages of other users, broadcast channels only
function I.promote_chuser(chat_id, user_id, can_change_info, can_delete_messages, can_invite_users, can_restrict_members, can_pin_messages, can_promote_members, can_post_messages, can_edit_messages, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
	  _ = "chatMemberStatusAdministrator",
	  can_change_info = can_change_info or false,
	  can_delete_messages = can_delete_messages or false,
	  can_invite_users = can_invite_users or false,
	  can_restrict_members = can_restrict_members or false,
	  can_pin_messages = can_pin_messages or false,
	  can_promote_members = can_promote_members or false,
	  can_post_messages = can_post_messages or false,
	  can_edit_messages = can_edit_messages or false
    }
  }, cb or dl_cb, cmd))
end

-- @is_member True, if user is chat member
-- @restricted_until_date Date when the user will be unrestricted, 0 if never. Unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time it considered to be restricted forever
-- @can_send_messages True, if the user can send text messages, contacts, locations and venues
-- @can_send_media_messages True, if the user can send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
-- @can_send_other_messages True, if the user can send animations, games, stickers and use inline bots, implies can_send_media_messages
-- @can_add_web_page_previews True, if user may add web page preview to his messages, implies can_send_messages
function I.limit_user(chat_id, user_id, can_change_info, can_delete_messages, can_invite_users, can_restrict_members, can_pin_messages, can_promote_members, can_post_messages, can_edit_messages, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatMemberStatus",
    chat_id = chat_id,
    user_id = user_id,
    status = {
	  _ = "chatMemberStatusAdministrator",
	  is_member = is_member or false,
	  restricted_until_date = restricted_until_date or false,
	  can_send_messages = can_send_messages or false,
	  can_send_other_messages = can_send_other_messages or false,
	  can_add_web_page_previews = can_add_web_page_previews or false
    }
  }, cb or dl_cb, cmd))
end

-- grneral function change chat member status (tanx to @rizaumami)
function I.changeChatMemberStatus(chat_id, user_id, status, limit, cb, cmd)
  local stat = {}
  if status == 'Administrator' then
    stat = {
      can_be_edited = limit[1] or 1,
      can_change_info = limit[2] or 1,
      can_post_messages = limit[3] or 1,
      can_edit_messages = limit[4] or 1,
      can_delete_messages = limit[5] or 1,
      can_invite_users = limit[6] or 1,
      can_restrict_members = limit[7] or 1,
      can_pin_messages = limit[8] or 1,
      can_promote_members = limit[9] or 1
    }
  elseif status == 'Restricted' then
    stat = {
      is_member = limit[1] or 1,
      restricted_until_date = limit[2] or 0,
      can_send_messages = limit[3] or 1,
      can_send_media_messages = limit[4] or 1,
      can_send_other_messages = limit[5] or 1,
      can_add_web_page_previews = limit[6] or 1
    }
  elseif status == 'Banned' then
    stat = {
      banned_until_date = limit[1] or 0
    }
  end
  
  stat._ = 'chatMemberStatus' .. rank

  assert (tdbot_function ({
    _ = 'changeChatMemberStatus',
    chat_id = chat_id,
    user_id = user_id,
    status = stat
  }, cb or dl_cb, cmd))
end

-- Returns information about one participant of the chat
-- @chat_id Chat identifier
-- @user_id User identifier
function I.getChatMember(chat_id, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getChatMember",
    chat_id = chat_id,
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Searches for the specified query in the first name, last name and username among members of the specified chat.
-- Requires administrator rights in broadcast channels
-- @chat_id Chat identifier
-- @query Query to search for
-- @limit Maximum number of users to be returned
function I.searchChatMembers(chat_id, query, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "searchChatMembers",
    chat_id = chat_id,
    query = query,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Changes list or order of pinned chats
-- @chat_ids New list of pinned chats
function I.setPinnedChats(chat_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "setPinnedChats",
    chat_ids = chat_ids --vector<int>
  }, cb or dl_cb, cmd))
end

-- Asynchronously downloads file from cloud.
-- Updates updateFileProgress will notify about download progress and successful download.
-- Update updateFile will notify about successful download
-- @file_id Identifier of file to download
-- @priority Priority of download, 1-32.
-- The higher priority, the earlier file will be downloaded. If priorities of two files are equal then the last one for which downloadFile is called will be downloaded first
function I.downloadFile(file_id, priority, cb, cmd)
  assert (tdbot_function ({
    _ = "downloadFile",
    file_id = file_id,
    priority = priority
  }, cb or dl_cb, cmd))
end

-- Stops file downloading.
-- If file is already downloaded, does nothing
-- @file_id Identifier of file to cancel download
function I.cancelDownloadFile(file_id, cb, cmd)
  assert (tdbot_function ({
    _ = "cancelDownloadFile",
    file_id = file_id
  }, cb or dl_cb, cmd))
end

-- Asynchronously uploads file to the cloud without sending it in a message.
-- Updates updateFile will notify about upload progress and successful upload.
-- The file will not have persistent identifier until it will be sent in a message
-- @file File to upload
-- @file_type File type
-- file_type : None|Animation|Audio|Document|Photo|ProfilePhoto|Secret|Sticker|Thumb|Unknown|Video|VideoNote|Voice|Wallpaper|SecretThumb
-- @priority Priority of upload, 1-32. The higher priority, the earlier file will be uploaded. If priorities of two files are equal then the first one for which uploadFile is called will be uploaded first
function I.uploadFile(file, file_type, priority, cb, cmd)
  assert (tdbot_function ({
    _ = "uploadFile",
    file = getInputFile(file),
    file_type = "fileType" .. file_type,
    priority = priority
  }, cb or dl_cb, cmd))
end

-- Stops file uploading.
-- Works only for files uploaded using uploadFile.
-- For other files the behavior is undefined
-- @file_id Identifier of file to cancel upload
function I.cancelUploadFile(file_id, cb, cmd)
  assert (tdbot_function ({
    _ = "cancelUploadFile",
    file_id = file_id
  }, cb or dl_cb, cmd))
end

-- Next part of a file was generated
-- @generation_id Identifier of the generation process
-- @size Full size of file in bytes, 0 if unknown.
-- @local_size Number of bytes already generated. Negative number means that generation has failed and should be terminated
function I.setFileGenerationProgress(generation_id, size, local_size, cb, cmd)
  assert (tdbot_function ({
    _ = "setFileGenerationProgress",
    generation_id = generation_id,
    size = size,
    local_size = local_size
  }, cb or dl_cb, cmd))
end

-- Finishes file generation
-- @generation_id Identifier of the generation process
function I.finishFileGeneration(generation_id, cb, cmd)
  assert (tdbot_function ({
    _ = "finishFileGeneration",
    generation_id = generation_id
  }, cb or dl_cb, cmd))
end

-- Deletes a file from TDLib file cache
-- @file_id Identifier of the file to delete
function I.deleteFile(file_id, cb, cmd)
  assert (tdbot_function ({
    _ = 'deleteFile',
    file_id = fileid
  }, cb or dl_cb, cmd))
end

-- Generates new chat invite link, previously generated link is revoked.
-- Available for group and channel chats.
-- In groups can be called only by creator, in channels requires appropriate rights
-- @chat_id Chat identifier
function I.exportChatInviteLink(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "exportChatInviteLink",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Checks chat invite link for validness and returns information about the corresponding chat
-- @invite_link Invite link to check. Should begin with "https://t.me/joinchat/", "https://telegram.me/joinchat/" or "https://telegram.dog/joinchat/"
function I.checkChatInviteLink(link, cb, cmd)
  assert (tdbot_function ({
    _ = "checkChatInviteLink",
    invite_link = link
  }, cb or dl_cb, cmd))
end

-- Imports chat invite link, adds current user to a chat if possible.
-- Member will not be added until chat state will be synchronized with the server.
-- Member will not be added if application is killed before it can send request to the server
-- @invite_link Invite link to import. Should begin with "https://t.me/joinchat/", "https://telegram.me/joinchat/" or "https://telegram.dog/joinchat/"
function I.importChatInviteLink(invite_link, cb, cmd)
  assert (tdbot_function ({
    _ = "importChatInviteLink",
    invite_link = invite_link
  }, cb or dl_cb, cmd))
end

-- Creates new call
-- @user_id Identifier of user to call
-- @protocol Description of supported by the client call protocols
-- @udp_p2p True, if UDP peer to peer connections are supported
-- @udp_reflector True, if connection through UDP reflectors are supported
-- @min_layer Minimum supported layer, use 65
-- @max_layer Maximum supported layer, use 65
function I.createCall(user_id, udp_p2p, udp_reflector, min_layer, max_layer, cb, cmd)
  assert (tdbot_function ({
    _ = "createCall",
    user_id = user_id,
    protocol = {
        _ = "callProtocol",
        udp_p2p = udp_p2p or true,
        udp_reflector = udp_reflector or true,
        min_layer = min_layer or 65,
        max_layer = max_layer or 65
    }
  }, cb or dl_cb, cmd))
end

-- Accepts incoming call
-- @call_id Call identifier
-- @protocol Description of supported by the client call protocols
-- @udp_p2p True, if UDP peer to peer connections are supported
-- @udp_reflector True, if connection through UDP reflectors are supported
-- @min_layer Minimum supported layer, use 65
-- @max_layer Maximum supported layer, use 65
function I.acceptCall(user_id, udp_p2p, udp_reflector, min_layer, max_layer, cb, cmd)
  assert (tdbot_function ({
    _ = "acceptCall",
    user_id = user_id,
    protocol = {
        _ = "callProtocol",
        udp_p2p = udp_p2p or true,
        udp_reflector = udp_reflector or true,
        min_layer = min_layer or 65,
        max_layer = max_layer or 65
    }
  }, cb or dl_cb, cmd))
end

-- Discards a call
-- @call_id Call identifier
-- @is_disconnected True, if users was disconnected
-- @duration Call duration in seconds
-- @connection_id Identifier of a connection used during the call
function I.discardCall(user_id, is_disconnected, duration, connection_id, cb, cmd)
  assert (tdbot_function ({
    _ = "discardCall",
    user_id = user_id,
    is_disconnected = is_disconnected,
    duration = duration,
    connection_id = connection_id
  }, cb or dl_cb, cmd))
end

-- Sends call rating
-- @call_id Call identifier
-- @rating Call rating, 1-5
-- @comment Optional user comment if rating is less than 5
function I.rateCall(user_id, rating, comment, cb, cmd)
  local rating = rating or 0
  if not comment and  rating < 1 then
    comment = "nothing"
  elseif rating > 5 then
    rating = 5
  end

  assert (tdbot_function ({
    _ = "rateCall",
    user_id = user_id,
    rating = rating,
    comment = comment
  }, cb or dl_cb, cmd))
end

-- Sends call debug information
-- @call_id Call identifier
-- @debug Debug information in application specific format
function I.debugCall(call_id, debug, cb, cmd)
  assert (tdbot_function ({
    _ = "debugCall",
    call_id = call_id,
    debug = debug
  }, cb or dl_cb, cmd))
end

-- Adds user to black list
-- @user_id User identifier
function I.blockUser(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "blockUser",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Removes user from black list
-- @user_id User identifier
function I.unblockUser(user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "unblockUser",
    user_id = user_id
  }, cb or dl_cb, cmd))
end

-- Returns users blocked by the current user
-- @offset Number of users to skip in result, must be non-negative
-- @limit Maximum number of users to return, can't be greater than 100
function I.getBlockedUsers(offset, limit, cb, cmd)
    if not limit or limit > 100 then
        limit = 100
    end
  assert (tdbot_function ({
    _ = "getBlockedUsers",
    offset = offset,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Adds new contacts/edits existing contacts, contacts user identifiers are ignored.
-- @contacts List of contacts to import/edit
-- @phone_number User's phone number
-- @first_name User first name, 1-255 characters
-- @last_name User last name
-- @user_id User identifier if known, 0 otherwise
function I.importContacts(phone_number, first_name, last_name, user_id, cb, cmd)
  assert (tdbot_function ({
    _ = "importContacts",
    contacts = {[0] = {
	  _ = 'contact',
      phone_number = tostring(phone_number),
      first_name = tostring(first_name),
      last_name = tostring(last_name),
      user_id = user_id
      },
    },
  }, cb or dl_cb, cmd))
end

-- Searches for specified query in the first name, last name and username of the known user contacts
-- @query Query to search for, can be empty to return all contacts
-- @limit Maximum number of users to be returned
function I.searchContacts(query, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "searchContacts",
    query = query,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Deletes users from contacts list
-- @user_ids Identifiers of users to be deleted
function I.deleteContacts(user_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteContacts",
    user_ids = getVector(user_ids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Returns profile photos of the user.
-- Result of this query may be outdated: some photos may be already deleted
-- @user_id User identifier
-- @offset Photos to skip, must be non-negative
-- @limit Maximum number of photos to be returned, can't be greater than 100
function I.getUserProfilePhotos(user_id, offset, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "getUserProfilePhotos",
    user_id = user_id,
    offset = offset,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Returns stickers from installed ordinary sticker sets corresponding to the given emoji
-- @emoji String representation of emoji. If empty, returns all known
-- @limit Maximum number of stickers to return
function I.getStickers(emoji, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "getStickers",
    emoji = emoji,
	limit = limit
  }, cb or dl_cb, cmd))
end

-- Returns list of installed sticker sets
-- @is_masks Pass true to return mask sticker sets, pass false to return ordinary sticker sets
function I.getInstalledStickerSets(is_masks, cb, cmd)
  assert (tdbot_function ({
    _ = "getInstalledStickerSets",
    is_masks = is_masks
  }, cb or dl_cb, cmd))
end

-- Returns list of archived sticker sets
-- @is_masks Pass true to return mask stickers sets, pass false to return ordinary sticker sets
-- @offsetstickerset_id Identifier of the sticker set from which return the result
-- @limit Maximum number of sticker sets to return
function I.getArchivedStickerSets(is_masks, offsetstickerset_id, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "getArchivedStickerSets",
    is_masks = is_masks,
    offsetstickerset_id = offsetstickerset_id,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Returns list of trending sticker sets
function I.getTrendingStickerSets(cb, cmd)
  assert (tdbot_function ({
    _ = "getTrendingStickerSets"
  }, cb or dl_cb, cmd))
end

-- Returns list of sticker sets attached to a file, currently only photos and videos can have attached sticker sets
-- @file_id File identifier
function I.getAttachedStickerSets(file_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getAttachedStickerSets",
    file_id = file_id
  }, cb or dl_cb, cmd))
end

-- Returns information about sticker set by its identifier
-- @set_id Identifier of the sticker set
function I.getStickerSet(set_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getStickerSet",
    set_id = set_id
  }, cb or dl_cb, cmd))
end

-- Searches sticker set by its short name
-- @name Name of the sticker set
function I.searchStickerSet(name, cb, cmd)
  assert (tdbot_function ({
    _ = "searchStickerSet",
    name = name
  }, cb or dl_cb, cmd))
end

-- Installs/uninstalls or enables/archives sticker set.
-- @set_id Identifier of the sticker set
-- @is_installed New value of is_installed
-- @is_archived New value of is_archived
-- A sticker set can't be installed and archived simultaneously
function I.changeStickerSet(set_id, is_installed, is_archived, cb, cmd)
  assert (tdbot_function ({
    _ = "changeStickerSet",
    set_id = set_id,
    is_installed = is_installed,
    is_archived = is_archived
  }, cb or dl_cb, cmd))
end

-- Informs that some trending sticker sets are viewed by the user
-- @stickerset_ids Identifiers of viewed trending sticker sets
function I.viewTrendingStickerSets(stickerset_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "viewTrendingStickerSets",
    stickerset_ids = getVector(stickerset_ids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Changes the order of installed sticker sets
-- @is_masks Pass true to change mask sticker sets order, pass false to change ordinary sticker sets order
-- @stickerset_ids Identifiers of installed sticker sets in the new right order
function I.reorderInstalledStickerSets(is_masks, stickerset_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "reorderInstalledStickerSets",
    is_masks = is_masks,
    stickerset_ids = stickerset_ids -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Returns list of recently used stickers
-- @is_attached Pass true to return stickers and masks recently attached to photo or video files, pass false to return recently sent stickers
function I.getRecentStickers(is_attached, cb, cmd)
  assert (tdbot_function ({
    _ = "getRecentStickers",
    is_attached = is_attached
  }, cb or dl_cb, cmd))
end

-- Manually adds new sticker to the list of recently used stickers.
-- New sticker is added to the beginning of the list.
-- If the sticker is already in the list, at first it is removed from the list
-- @is_attached Pass true to add the sticker to the list of stickers recently attached to photo or video files, pass false to add the sticker to the list of recently sent stickers
-- @sticker Sticker file to add
function I.addRecentSticker(is_attached, sticker, cb, cmd)
  assert (tdbot_function ({
    _ = "addRecentSticker",
    is_attached = is_attached,
    sticker = getInputFile(sticker)
  }, cb or dl_cb, cmd))
end

-- Removes a sticker from the list of recently used stickers
-- @is_attached Pass true to remove the sticker from the list of stickers recently attached to photo or video files, pass false to remove the sticker from the list of recently sent stickers
-- @sticker Sticker file to delete
function I.deleteRecentSticker(is_attached, sticker, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteRecentSticker",
    is_attached = is_attached,
    sticker = getInputFile(sticker)
  }, cb or dl_cb, cmd))
end

-- Clears list of recently used stickers
-- @is_attached Pass true to clear list of stickers recently attached to photo or video files, pass false to clear the list of recently sent stickers
function I.clearRecentStickers(is_attached, cb, cmd)
  assert (tdbot_function ({
    _ = "clearRecentStickers",
    is_attached = is_attached
  }, cb or dl_cb, cmd))
end

-- Returns emojis corresponding to a sticker
-- @sticker Sticker file identifier
function I.getStickerEmojis(sticker, cb, cmd)
  assert (tdbot_function ({
    _ = "getStickerEmojis",
    sticker = getInputFile(sticker)
  }, cb or dl_cb, cmd))
end

-- Returns saved animations
function I.getSavedAnimations(cb, cmd)
  assert (tdbot_function ({
    _ = "getSavedAnimations",
  }, cb or dl_cb, cmd))
end

-- Manually adds new animation to the list of saved animations.
-- New animation is added to the beginning of the list.
-- If the animation is already in the list, at first it is removed from the list.
-- Only non-secret video animations with MIME type "video/mp4" can be added to the list
-- @animation Animation file to add. Only known to server animations (i.e. successfully sent via message) can be added to the list
function I.addSavedAnimation(animation, cb, cmd)
  assert (tdbot_function ({
    _ = "addSavedAnimation",
    animation = getInputFile(animation)
  }, cb or dl_cb, cmd))
end

-- Removes animation from the list of saved animations
-- @animation Animation file to delete
function I.deleteSavedAnimation(animation, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteSavedAnimation",
    animation = getInputFile(animation)
  }, cb or dl_cb, cmd))
end

-- Returns up to 20 recently used inline bots in the order of the last usage
function I.getRecentInlineBots(cb, cmd)
  assert (tdbot_function ({
    _ = "getRecentInlineBots",
  }, cb or dl_cb, cmd))
end

-- Searches for recently used hashtags by their prefix
-- @prefix Hashtag prefix to search for
-- @limit Maximum number of hashtags to return
function I.searchHashtags(prefix, limit, cb, cmd)
  assert (tdbot_function ({
    _ = "searchHashtags",
    prefix = prefix,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Deletes a hashtag from the list of recently used hashtags
-- @hashtag The hashtag to delete
function I.deleteRecentHashtag(hashtag, cb, cmd)
  assert (tdbot_function ({
    _ = "searchHashtags",
    hashtag = hashtag
  }, cb or dl_cb, cmd))
end

-- Returns web page preview by text of the message.
-- Do not call this function to often
-- Returns error 404 if web page has no preview
-- @message_text Message text
function I.getWebPagePreview(message_text, cb, cmd)
  assert (tdbot_function ({
    _ = "getWebPagePreview",
    message_text = message_text
  }, cb or dl_cb, cmd))
end

-- Returns web page instant view if available.
-- Returns error 404 if web page has no instant view
-- @url Web page URL
-- @forcefull If true, full web page instant view will be returned
function I.getWebPageInstantView(url, forcefull, cb, cmd)
  assert (tdbot_function ({
    _ = "getWebPageInstantView",
    url = url,
    forcefull = forcefull
  }, cb or dl_cb, cmd))
end

-- Returns notification settings for a given scope
-- @scope Scope to return information about notification settings
-- scope = Chat|PrivateChats|GroupChats|AllChats
function I.getNotificationSettings(scope, chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getNotificationSettings",
    scope = {
      _ = 'NotificationSettingsFor' .. scope,
      chat_id = chat_id or nil
    },
  }, cb or dl_cb, cmd))
end

-- Changes notification settings for a given scope
-- @scope Scope to change notification settings
-- @notification_settings New notification settings for given scope
-- scope = Chat(chat_id)|PrivateChats|GroupChats|AllChats
-- @mute_for Time left before notifications will be unmuted, seconds
-- @sound Audio file name for notifications, iPhone apps only
-- @show_preview Display message text/media in notification
function I.setNotificationSettings(scope, chat_id, mute_for, sound, show_preview, cb, cmd)
  assert (tdbot_function ({
    _ = "setNotificationSettings",
    scope = {
      _ = 'NotificationSettingsScope' .. scope,
      chat_id = chat_id
    },
    notification_settings = {
      _ = "notificationSettings",
      mute_for = mute_for,
      sound = sound,
      show_preview = show_preview
    }
  }, cb or dl_cb, cmd))
end

-- Resets all notification settings to the default value.
-- By default the only muted chats are supergroups, sound is set to 'default' and message previews are showed
function I.resetAllNotificationSettings(cb, cmd)
  assert (tdbot_function ({
    _ = "resetAllNotificationSettings"
  }, cb or dl_cb, cmd))
end

-- Uploads new profile photo for logged in user.
-- Photo will not change until change will be synchronized with the server.
-- Photo will not be changed if application is killed before it can send request to the server.
-- If something changes, updateUser will be sent
-- @photo Profile photo to set. inputFileId and inputFilePersistentId may be unsupported
function I.setProfilePhoto(photo, cb, cmd)
  assert (tdbot_function ({
    _ = "setProfilePhoto",
    photo = getInputFile(photo)
  }, cb or dl_cb, cmd))
end

-- Deletes profile photo.
-- If something changes, updateUser will be sent
-- @profile_photoid Identifier of profile photo to delete
function I.deleteProfilePhoto(profile_photo_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteProfilePhoto",
    profile_photo_id = profile_photo_id
  }, cb or dl_cb, cmd))
end

-- Changes first and last names of logged in user.
-- If something changes, updateUser will be sent
-- @first_name New value of user first name, 1-255 characters
-- @last_name New value of optional user last name, 0-255 characters
function I.changeName(first_name, last_name, cb, cmd)
  assert (tdbot_function ({
    _ = "changeName",
    first_name = first_name,
    last_name = last_name
  }, cb or dl_cb, cmd))
end

-- Changes about information of logged in user
-- @about New value of userFull.about, 0-70 characters without line feeds
function I.changeAbout(about, cb, cmd)
  assert (tdbot_function ({
    _ = "changeAbout",
    about = about
  }, cb or dl_cb, cmd))
end

-- Changes username of logged in user.
-- If something changes, updateUser will be sent
-- @username New value of username. Use empty string to remove username
function I.changeUsername(username, cb, cmd)
  assert (tdbot_function ({
    _ = "changeUsername",
    username = username
  }, cb or dl_cb, cmd))
end

-- Changes user's phone number and sends authentication code to the new user's phone number.
-- Returns authStateWaitCode with information about sent code on success
-- @phone_number New user's phone number in any reasonable format
-- @allow_flash_call Pass True, if code can be sent via flash call to the specified phone number
-- @is_current_phone_number Pass true, if the phone number is used on the current device. Ignored if allow_flash_call is False
function I.changePhoneNumber(phone_number, allow_flash_call, is_current_phone_number, cb, cmd)
  assert (tdbot_function ({
    _ = "changePhoneNumber",
    phone_number = phone_number,
    allow_flash_call = allow_flash_call,
    is_current_phone_number = is_current_phone_number
  }, cb or dl_cb, cmd))
end

-- Resends authentication code sent to change user's phone number.
-- Works only if in previously received authStateWaitCode next_code_type was not null.
-- Returns authStateWaitCode on success
function I.resendChangePhoneNumberCode(cb, cmd)
  assert (tdbot_function ({
    _ = "resendChangePhoneNumberCode",
  }, cb or dl_cb, cmd))
end

-- Checks authentication code sent to change user's phone number.
-- Returns authStateOk on success
-- @code Verification code from SMS, phone call or flash call
function I.checkChangePhoneNumberCode(code, cb, cmd)
  assert (tdbot_function ({
    _ = "checkChangePhoneNumberCode",
    code = code
  }, cb or dl_cb, cmd))
end

-- Returns all active sessions of logged in user
function I.getActiveSessions(cb, cmd)
  assert (tdbot_function ({
    _ = "getActiveSessions",
  }, cb or dl_cb, cmd))
end

-- Terminates another session of logged in user
-- @session_id Session identifier
function I.terminateSession(session_id, cb, cmd)
  assert (tdbot_function ({
    _ = "terminateSession",
    session_id = session_id
  }, cb or dl_cb, cmd))
end

-- Terminates all other sessions of logged in user
function I.terminateAllOtherSessions(cb, cmd)
  assert (tdbot_function ({
    _ = "terminateAllOtherSessions",
  }, cb or dl_cb, cmd))
end

-- Gives or revokes all members of the group administrator rights.
-- Needs creator privileges in the group
-- @group_id Identifier of the group
-- @everyone_is_administrator New value of everyone_is_administrator
function I.toggleGroupAdministrators(group_id, everyone_is_administrator, cb, cmd)
  assert (tdbot_function ({
    _ = "toggleGroupEditors",
    group_id = getChatId(group_id)._,
    everyone_is_administrator = everyone_is_administrator
  }, cb or dl_cb, cmd))
end

-- Changes username of the channel.
-- Needs creator privileges in the channel
-- @channel_id Identifier of the channel
-- @username New value of username. Use empty string to remove username
function I.changeChannelUsername(channel_id, username, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChannelUsername",
    channel_id = getChatId(channel_id)._,
    username = username
  }, cb or dl_cb, cmd))
end

-- Gives or revokes right to invite new members to all current members of the channel.
-- Needs appropriate rights in the channel.
-- Available only for supergroups
-- @channel_id Identifier of the channel
-- @anyone_can_invite New value of anyone_can_invite
function I.toggleChannelInvites(channel_id, anyone_can_invite, cb, cmd)
  assert (tdbot_function ({
    _ = "toggleChannelInvites",
    channel_id = getChatId(channel_id)._,
    anyone_can_invite = anyone_can_invite
  }, cb or dl_cb, cmd))
end

-- Enables or disables sender signature on sent messages in the channel.
-- Needs appropriate rights in the channel.
-- Not available for supergroups
-- @channel_id Identifier of the channel
-- @sign_messages New value of sign_messages
function I.toggleChannelSignMessages(channel_id, sign_messages, cb, cmd)
  assert (tdbot_function ({
    _ = "toggleChannelSignMessages",
    channel_id = getChatId(channel_id)._,
    sign_messages = sign_messages
  }, cb or dl_cb, cmd))
end

-- Changes information about the channel.
-- Needs appropriate rights in the channel
-- @channel_id Identifier of the channel
-- @param_description New channel description, 0-255 characters
function I.changeChannelDescription(channel_id, description, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChannelDescription",
    channel_id = getChatId(channel_id)._,
    description = description
  }, cb or dl_cb, cmd))
end

-- Pins a message in a supergroup channel chat.
-- Needs appropriate rights in the channel
-- @channel_id Identifier of the channel
-- @message_id Identifier of the new pinned message
-- @disable_notification True, if there should be no notification about the pinned message
function I.pinChannelMessage(channel_id, message_id, disable_notification, cb, cmd)
  assert (tdbot_function ({
    _ = "pinChannelMessage",
    channel_id = getChatId(channel_id)._,
    message_id = message_id,
    disable_notification = disable_notification
  }, cb or dl_cb, cmd))
end

-- Removes pinned message in the supergroup channel.
-- Needs appropriate rights in the channel
-- @channel_id Identifier of the channel
function I.unpinChannelMessage(channel_id, cb, cmd)
  assert (tdbot_function ({
    _ = "unpinChannelMessage",
    channel_id = getChatId(channel_id)._
  }, cb or dl_cb, cmd))
end

-- Reports some supergroup channel messages from a user as spam messages
-- @channel_id Channel identifier
-- @user_id User identifier
-- @message_ids Identifiers of messages sent in the supergroup by the user, the list should be non-empty
function I.reportChannelSpam(channel_id, user_id, message_ids, cb, cmd)
  assert (tdbot_function ({
    _ = "reportChannelSpam",
    channel_id = getChatId(channel_id)._,
    user_id = user_id,
    message_ids = getVector(message_ids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Returns information about channel members or banned from channel users.
-- Can be used only if channel_full->can_get_members == true
-- Administrator privileges may be additionally needed for some filters
-- @channel_id Identifier of the channel
-- @filter Kind of channel users to return, defaults to channelMembersRecent
-- @query Query to search for
-- @offset Number of channel users to skip
-- @limit Maximum number of users be returned, can't be greater than 200
-- filter = Recent|Administrators|Kicked|Bots
function I.getChannelMembers(channel_id, filter, query, offset, limit, cb, cmd)
  if not limit or limit > 200 then
    limit = 200
  end

  assert (tdbot_function ({
    _ = "getChannelMembers",
    channel_id = getChatId(channel_id)._,
    filter = {
      _ = "channelMembersFilter" .. filter,
	  query = query
    },
    offset = offset or 0,
    limit = limit
  }, cb or dl_cb, cmd))
end

-- Deletes channel along with all messages in corresponding chat.
-- Releases channel username and removes all members.
-- Needs creator privileges in the channel.
-- Channels with more than 1000 members can't be deleted
-- @channel_id Identifier of the channel
function I.deleteChannel(channel_id, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteChannel",
    channel_id = getChatId(channel_id)._
  }, cb or dl_cb, cmd))
end

-- Closes secret chat, effectively transfering its state to "closed"
-- @secret_chat_id Secret chat identifier
function I.closeSecretChat(secret_chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "closeSecretChat",
    secret_chat_id = secret_chat_id
  }, cb or dl_cb, cmd))
end

-- Returns list of service actions taken by chat members and administrators in the last 48 hours, available only in channels.
-- Requires administrator rights.
-- Returns result in reverse chronological order, i.e. in order of decreasing event_id
-- @chat_id Chat identifier
-- @query Search query to filter events
-- @from_event_id Identifier of an event from which to return result, you can use 0 to get results from the latest events
-- @limit Maximum number of events to return, can't be greater than 100
-- @filters Types of events to return, defaults to all
-- chatEventLogFilters Represents a set of filters used to obtain a chat event log
-- MessageEdited|MessageDeleted|MessagePinned|MessageUnpinned|MemberJoined|MemberLeft|MemberInvited|MemberPromoted|MemberRestricted|TitleChanged
-- @message_edits True, if message edits should be returned
-- @message_deletions True, if message deletions should be returned
-- @message_pins True, if message pins should be returned
-- @member_joins True, if chat member joins should be returned
-- @member_leaves True, if chat member leaves should be returned
-- @member_invites True, if chat member invites should be returned
-- @member_promotions True, if chat member promotions/demotions should be returned
-- @member_restrictions True, if chat member restrictions/unrestrictions including bans/unbans should be returned
-- @info_changes True, if changes of chat information should be returned
-- @setting_changes True, if changes of chat settings should be returned-- @user_ids User identifiers, which events to return, defaults to all users
function I.getChatEventLog(chat_id, query, from_event_id, limit, user_ids, message_edits ,message_deletions, message_pins, member_joins, member_leaves, member_invites, member_promotions, member_restrictions, info_changes, setting_changes, cb, cmd)
  if not limit or limit > 100 then
    limit = 100
  end
  filters = {
    _ = "chatEventLogFilters",
    message_edits = message_edits or 1,
    message_deletions = message_deletions or 1,
    message_pins = message_pins or 1,
    member_joins = member_joins or 1,
    member_leaves = member_leaves or 1,
    member_invites = member_invites or 1,
    member_promotions = member_promotions or 1,
    member_restrictions = member_restrictions or 1,
    info_changes = info_changes or 1,
    setting_changes = setting_changes or 1
  }

  assert (tdbot_function ({
    _ = "getChatEventLog",
    chat_id = chat_id,
    query = query,
    from_event_id = from_event_id,
    limit = limit,
    filters = filters,
    user_ids = getVector(user_ids) -- vector<int>
  }, cb or dl_cb, cmd))
end

-- Returns invoice payment form.
-- The method should be called when user presses inlineKeyboardButtonBuy
-- @chat_id Chat identifier of the Invoice message
-- @message_id Message identifier
function I.getPaymentForm(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getPaymentForm",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Validates order information provided by the user and returns available shipping options for flexible invoice
-- @chat_id Chat identifier of the Invoice message
-- @message_id Message identifier
-- @order_info Order information, provided by the user
-- @phone_number User's phone number
-- @email User email
-- @shipping_address User shipping address, nullable
-- @country_code Two letter ISO 3166-1 alpha-2 country code
-- @state State if applicable @city City
-- @street_line1 First line for the address
-- @street_line2 Second line for the address
-- @post_code Address post code
-- @allow_save True, if order information can be saved
function I.validateOrderInfo(chat_id, message_id, name, phone_number, email, country_code, state, city, street_line1, street_line2, post_code, allow_save, cb, cmd)
  assert (tdbot_function ({
    _ = "validateOrderInfo",
    chat_id = chat_id,
    message_id = message_id,
    order_info = {
      _ = "orderInfo",
      name = name,
      phone_number = phone_number,
      email = email,
      shipping_address = {
        _ = "shippingAddress",
        country_code = country_code,
        state = state,
        city = city,
        street_line1 = street_line1,
        street_line2 = street_line2,
        post_code = post_code
      }
    },
    allow_save = allow_save
  }, cb or dl_cb, cmd))
end

-- Sends filled payment form to the bot for the final verification
-- @chat_id Chat identifier of the Invoice message
-- @message_id Message identifier
-- @order_info_id Identifier returned by ValidateOrderInfo or empty string
-- @shipping_option_id Identifier of a chosen shipping option, if applicable
-- @credentials Credentials choosed by user for payment
-- @saved_credentials_id Identifier of saved credentials
-- @data JSON-encoded data with credentials identifier from the payment provider
-- @allow_save True, if credentials identifier can be saved server-side
function I.sendPaymentForm(chat_id, message_id, order_info_id, shipping_option_id, credentials, input_credentials, cb, cmd)
  local input_credentials = input_credentials or {}

  if credentials == 'Saved' then
    input_credentials = {
      saved_credentials_id = tostring(input_credentials[1])
    }
  elseif credentials == 'New' then
    input_credentials = {
      data = tostring(input_credentials[1]),
      allow_save = input_credentials[2]
    }
  end

  input_credentials._ = 'inputCredentials' .. credentials

  assert (tdbot_function ({
    _ = "sendPaymentForm",
    chat_id = chat_id,
    message_id = message_id,
    order_info_id = order_info_id,
    shipping_option_id = shipping_option_id,
    credentials = credentials -- credentials:InputCredentials
  }, cb or dl_cb, cmd))
end

-- Returns information about successful payment
-- @chat_id Chat identifier of the PaymentSuccessful message
-- @message_id Message identifier
function I.getPaymentReceipt(chat_id, message_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getPaymentReceipt",
    chat_id = chat_id,
    message_id = message_id
  }, cb or dl_cb, cmd))
end

-- Returns saved order info if any
function I.getSavedOrderInfo(cb, cmd)
  assert (tdbot_function ({
    _ = "getSavedOrderInfo",
  }, cb or dl_cb, cmd))
end

-- Deletes saved order info
function I.deleteSavedOrderInfo(cb, cmd)
  assert (tdbot_function ({
    _ = "deleteSavedOrderInfo",
  }, cb or dl_cb, cmd))
end

-- Deletes saved credentials for all payments provider bots
function I.deleteSavedCredentials(cb, cmd)
  assert (tdbot_function ({
    _ = "deleteSavedCredentials",
  }, cb or dl_cb, cmd))
end

-- Returns user that can be contacted to get support
function I.getSupportUser(cb, cmd)
  assert (tdbot_function ({
    _ = "getSupportUser",
  }, cb or dl_cb, cmd))
end

-- Returns background wallpapers
function I.getWallpapers(cb, cmd)
  assert (tdbot_function ({
    _ = "getWallpapers",
  }, cb or dl_cb, cmd))
end

-- Registers current used device for receiving push notifications
-- @device_token Device token
-- deviceToken: Apns|Gcm|SimplePush|UbuntuPhone|Blackberry
function I.registerDevice(device_token, token, cb, cmd)
  assert (tdbot_function ({
    _ = "registerDevice",
    device_token = {
	  _ = device_token .. 'DeviceToken',
	  token = token
	}
  }, cb or dl_cb, cmd))
end

-- Changes privacy settings
-- @key Privacy key
-- @rules New privacy rules
-- key = UserStatus|ChatInvite
-- rules = AllowAll|AllowContacts|AllowUsers(user_ids)|DisallowAll|DisallowContacts|DisallowUsers(user_ids)
function I.setPrivacy(key, rule, allowed_user_ids, disallowed_user_ids, cb, cmd)
  local rules = {[0] = {_ = 'PrivacyRule' .. rule}}

  if allowed_user_ids then
    rules = {
      {
        _ = 'PrivacyRule' .. rule
      },
      [0] = {
        _ = "privacyRuleAllowUsers",
        user_ids = getVector(allowed_user_ids) -- vector
      },
    }
  end
  if disallowed_user_ids then
    rules = {
      {
        _ = 'PrivacyRule' .. rule
      },
      [0] = {
        _ = "privacyRuleDisallowUsers",
        user_ids = getVector(disallowed_user_ids) -- vector
      },
    }
  end
  if allowed_user_ids and disallowed_user_ids then
    rules = {
      {
        _ = 'PrivacyRule' .. rule
      },
      {
        _ = "privacyRuleAllowUsers",
        user_ids = getVector(allowed_user_ids)
      },
      [0] = {
        _ = "privacyRuleDisallowUsers",
        user_ids = getVector(disallowed_user_ids)
      },
    }
  end
  assert (tdbot_function ({
    _ = "setPrivacy",
    key = {
      _ = 'PrivacyKey' .. key
    },
    rules = {
      _ = "privacyRules",
      rules = rules
    },
  }, cb or dl_cb, cmd))
end

-- Returns current privacy settings
-- @key Privacy key
-- key = UserStatus|ChatInvite|Call
function I.getPrivacy(key, cb, cmd)
  assert (tdbot_function ({
    _ = "getPrivacy",
    key = {
      _ = "privacyKey" .. key
    },
  }, cb or dl_cb, cmd))
end

-- Returns value of an option by its name.
-- See list of available options on https://core.telegram.org/tdlib/options.
-- Can be called before authorization
-- @name Name of the option
function I.getOption(name, cb, cmd)
  assert (tdbot_function ({
    _ = "getOption",
    name = name
  }, cb or dl_cb, cmd))
end

-- Sets value of an option.
-- See list of available options on https://core.telegram.org/tdlib/options.
-- Only writable options can be set
-- Can be called before authorization
-- @name Name of the option
-- @value New value of the option
-- Value: Boolean | Empty | Integer | String
function I.setOption(name, option, value, cb, cmd)
  assert (tdbot_function ({
    _ = "setOption",
    name = name,
    value = {
      _ = 'optionValue' .. option,
      value = value
    },
  }, cb or dl_cb, cmd))
end

-- Changes period of inactivity, after which the account of currently logged in user will be automatically deleted
-- @ttl New account TTL
-- @days Number of days of inactivity before account deletion, should be from 30 and up to 366
function I.changeAccountTtl(days, cb, cmd)
  assert (tdbot_function ({
    _ = "changeAccountTtl",
    ttl = {
      _ = "accountTtl",
      days = days
    },
  }, cb or dl_cb, cmd))
end

-- Returns period of inactivity, after which the account of currently logged in user will be automatically deleted
function I.getAccountTtl(cb, cmd)
  assert (tdbot_function ({
    _ = "getAccountTtl",
  }, cb or dl_cb, cmd))
end

-- Deletes the account of currently logged in user, deleting from the server all information associated with it.
-- Account's phone number can be used to create new account, but only once in two weeks
-- @reason Optional reason of account deletion
function I.deleteAccount(reason, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteAccount",
    reason = reason
  }, cb or dl_cb, cmd))
end

-- Returns current chat report spam state
-- @chat_id Chat identifier
function I.getChatReportSpamState(chat_id, cb, cmd)
  assert (tdbot_function ({
    _ = "getChatReportSpamState",
    chat_id = chat_id
  }, cb or dl_cb, cmd))
end

-- Reports chat as a spam chat or as not a spam chat.
-- Can be used only if ChatReportSpamState.can_report_spam is true.
-- After this request ChatReportSpamState.can_report_spam became false forever
-- @chat_id Chat identifier
-- @is_spam_chat If true, chat will be reported as a spam chat, otherwise it will be marked as not a spam chat
function I.changeChatReportSpamState(chat_id, is_spam_chat, cb, cmd)
  assert (tdbot_function ({
    _ = "changeChatReportSpamState",
    chat_id = chat_id,
    is_spam_chat = is_spam_chat
  }, cb or dl_cb, cmd))
end

-- Reports chat to Telegram moderators.
-- Can be used only for a channel chat or a private chat with a bot, because all other chats can't be checked by moderators
-- @chat_id Chat identifier
-- @reason Reason, the chat is reported.
-- reason: Spam|Violence|Pornography|Other
-- @text Report text
function I.reportChat(chat_id, reason, text, cb, cmd)
  assert (tdbot_function ({
    _ = "reportChat",
    chat_id = chat_id,
    reason = {
      _ = 'chatReportReason' .. reason,
      text = text
    }
  }, cb or dl_cb, cmd))
end

-- Returns storage usage statistics
-- @chat_limit Maximum number of chats with biggest storage usage for which separate statistics should be returned.
-- All other chats will be grouped in entries with chat_id == 0.
-- If chat info database is not used, chat_limit is ignored and is always set to 0
function I.getStorageStatistics(hat_limit, cb, cmd)
  assert (tdbot_function ({
    _ = "getStorageStatistics",
    hat_limit = hat_limit
  }, cb or dl_cb, cmd))
end

-- Quickly returns approximate storage usage statistics
function I.getStorageStatisticsFast(cb, cmd)
  assert (tdbot_function ({
    _ = "getStorageStatisticsFast"
  }, cb or dl_cb, cmd))
end

-- description Optimizes storage usage, i.e. deletes some files and return new storage usage statistics.
-- Secret thumbnails can't be deleted
-- @size Limit on total size of files after deletion. Pass -1 to use default limit
-- @ttl Limit on time passed since last access time (or creation time on some filesystems) to a file. Pass -1 to use default limit
-- @count Limit on total count of files after deletion. Pass -1 to use default limit
-- @immunity_delay Number of seconds after creation of a file, it can't be delited. Pass -1 to use default value
-- @file_types If not empty, only files with given types are considered. By default, all types except thumbnails, profile photos, stickers and wallpapers are deleted
-- @chat_ids If not empty, only files from the given chats are considered. Use 0 as chat identifier to delete files not belonging to any chat, for example profile photos
-- @exclude_chat_ids If not empty, files from the given chats are exluded. Use 0 as chat identifier to exclude all files not belonging to any chat, for example profile photos
-- @chat_limit Same as in getStorageStatistics. Affects only returned statistics
function I.optimizeStorage(size, ttl, count, immunity_delay, file_types, chat_ids, exclude_chat_ids, chat_limit, cb, cmd)
  assert (tdbot_function ({
    _ = "optimizeStorage",
    size = size or -1,
    ttl = ttl or -1,
    count = count or -1,
    immunity_delay = immunity_delay or -1,
    file_types = {
      _ = 'fileType' .. file_types
    },
    chat_ids = getVector(chat_ids), -- vector<int>
    exclude_chat_ids = getVector(exclude_chat_ids), -- vector<int>
    chat_limit = chat_limit
  }, cb or dl_cb, cmd))
end

-- Sets current network type.
-- Can be called before authorization.
-- Call to this method forces reopening of all network connections mitigating delay in switching between different networks, so it should be called whenever network is changed even network type remains the same.
-- Network type is used to check if library can use network at all and for collecting detailed network data usage statistics
-- @type New network defaults to networkTypeNone
-- type: None|Mobile|MobileRoaming|WiFi|Other
function I.setNetworkType(net_type, cb, cmd)
  assert (tdbot_function ({
    _ = "setNetworkType",
    pending_update_count = pending_update_count,
    type = {
      _ = 'networkType' .. net_type
    },
  }, cb or dl_cb, cmd))
end

-- Returns network data usage statistics.
-- Can be called before authorization
-- @only_current If true, returns only data for the current library launch
function I.getNetworkStatistics(only_current, cb, cmd)
  assert (tdbot_function ({
    _ = "getNetworkStatistics",
    only_current = only_current
  }, cb or dl_cb, cmd))
end

-- Adds specified data to data usage statistics. Can be called before authorization
-- @entry Network statistics entry with a data to add to statistics
-- @sent_bytes Total number of sent bytes
-- @received_bytes Total number of received bytes
-- @file_type Type of a file the data is part of
-- @network_type Type of a network the data was sent through. Call setNetworkType to maintain actual network type
-- @sent_bytes Total number of sent bytes
-- @received_bytes Total number of received bytes
-- entry: File | Call
function I.addNetworkStatistics(entry, file_type, network_type, sent_bytes, received_bytes, duration, cb, cmd)
  assert (tdbot_function ({
    _ = 'addNetworkStatistics',
    entry = {
      _ = 'networkStatisticsEntry' .. entry,
      file_type = file_type,
      network_type = network_type,
      sent_bytes = sent_bytes,
      received_bytes = received_bytes,
      duration = duration
    },
  }, cb or dl_cb, cmd))
end

-- Resets all network data usage statistics to zero.
-- Can be called before authorization
function I.resetNetworkStatistics(cb, cmd)
  assert (tdbot_function ({
    _ = "resetNetworkStatistics"
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Informs server about number of pending bot updates if they aren't processed for a long time
-- @pending_update_count Number of pending updates
-- @error_message Last error's message
function I.setBotUpdatesStatus(pending_update_count, error_message, cb, cmd)
  assert (tdbot_function ({
    _ = "setBotUpdatesStatus",
    pending_update_count = pending_update_count,
    error_message = error_message
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Uploads a png image with a sticker.
-- Returns uploaded file
-- @user_id Sticker file owner
-- @png_sticker Png image with the sticker, must be up to 512 kilobytes in size and fit in 512x512 square
function I.uploadStickerFile(user_id, png_sticker, cb, cmd)
  assert (tdbot_function ({
    _ = "setBotUpdatesStatus",
    user_id = user_id,
    png_sticker = getInputFile(png_sticker)
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Creates new sticker set.
-- Returns created sticker set
-- @user_id Sticker set owner
-- @title Sticker set title, 1-64 characters
-- @name Sticker set name. Can contain only english letters, digits and underscores. Should end on *"_by_<bot username>"*. *<bot_username>* is case insensitive, 1-64 characters
-- @is_masks True, is stickers are masks
-- @stickers List of stickers to add to the set
-- @png_sticker Png image with the sticker, must be up to 512 kilobytes in size and fit in 512x512 square
-- @emojis Emojis corresponding to the sticker
-- @mask_position Position where the mask should be placed, nullable
-- @point Part of a face relative to which the mask should be placed. 0 - forehead, 1 - eyes, 2 - mouth, 3 - chin
-- @x_shift Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position
-- @y_shift Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
-- @scale Mask scaling coefficient. For example, 2.0 means double size
function I.createNewStickerSet(user_id, title, name, is_masks, png_sticker, emojis, point, x_shift, y_shift, scale, cb, cmd)
  assert (tdbot_function ({
    _ = "createNewStickerSet",
    user_id = user_id,
    title = title,
    name = name,
    is_masks = is_masks,
    stickers = {
      _ = 'inputSticker',
      png_sticker = getInputFile(png_sticker),
      emojis = emojis,
      mask_position = {
        _ = 'maskPosition',
        point = point,
        x_shift = x_shift,
        y_shift = y_shift,
        scale = scale
      },
    },
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Adds new sticker to a set.
-- Returns the sticker set
-- @user_id Sticker set owner
-- @name Sticker set name
-- @png_sticker Png image with the sticker, must be up to 512 kilobytes in size and fit in 512x512 square
-- @emojis Emoji corresponding to the sticker
-- @mask_position Position where the mask should be placed
-- @point Part of a face relative to which the mask should be placed. 0 - forehead, 1 - eyes, 2 - mouth, 3 - chin
-- @x_shift Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position
-- @y_shift Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
-- @scale Mask scaling coefficient. For example, 2.0 means double size
function I.addStickerToSet(user_id, name, png_sticker, emojis, point, x_shift, y_shift, scale, cb, cmd)
  assert (tdbot_function ({
    _ = "addStickerToSet",
    user_id = user_id,
    name = name,
    sticker = {
      _ = "inputSticker",
      png_sticker = getInputFile(png_sticker),
      emojis = emojis,
      mask_position = {
        _ = "maskPosition",
        point = point,
        x_shift = x_shift,
        y_shift = y_shift,
        scale = scale
      }
    }
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Changes position of a sticker in the set it belongs to.
-- Sticker set should be created by the bot
-- @sticker The sticker
-- @position New sticker position in the set, zero-based
function I.setStickerPositionInSet(sticker, position, cb, cmd)
  assert (tdbot_function ({
    _ = "setStickerPositionInSet",
    sticker = getInputFile(sticker),
    position = position
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Deletes a sticker from the set it belongs to.
-- Sticker set should be created by the bot
-- @sticker The sticker
function I.deleteStickerFromSet(sticker, cb, cmd)
  assert (tdbot_function ({
    _ = "deleteStickerFromSet",
    sticker = getInputFile(sticker)
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Sends custom request
-- @method Method name
-- @parameters JSON-serialized method parameters
function I.sendCustomRequest(method, parameters, cb, cmd)
  assert (tdbot_function ({
    _ = "sendCustomRequest",
    method = method,
    parameters = parameters
  }, cb or dl_cb, cmd))
end

-- Bots only.
-- Answers a custom query
-- @custom_queryid Identifier of a custom query
-- @data JSON-serialized answer to the query
function I.answerCustomQuery(custom_query_id, data, cb, cmd)
  assert (tdbot_function ({
    _ = "answerCustomQuery",
    custom_query_id = custom_query_id,
    data = data
  }, cb or dl_cb, cmd))
end

-- Returns Ok after specified amount of the time passed.
-- Can be called before authorization
-- @seconds Number of seconds before that function returns
function I.setAlarm(seconds, cb, cmd)
  assert (tdbot_function ({
    _ = "setAlarm",
    seconds = seconds
  }, cb or dl_cb, cmd))
end

-- Returns invite text for invitation of new users
function I.getInviteText(cb, cmd)
  assert (tdbot_function ({
    _ = "getInviteText",
  }, cb or dl_cb, cmd))
end

-- Returns terms of service.
-- Can be called before authorization
function I.getTermsOfService(cb, cmd)
  assert (tdbot_function ({
    _ = "getTermsOfService",
  }, cb or dl_cb, cmd))
end

-- description Sets proxy server for network requests.
-- Can be called before authorization
-- @proxy The proxy to use.
-- You can specify null to remove proxy server
-- @server Proxy server ip address
-- @port Proxy server port
-- @username Username to log in
-- @password Password to log in
-- proxy: Empty | Socks5
function I.setProxy(server, port, username, password, cb, cmd)
  if not server or port or username or password then
    proxy = {_ = "proxyEmpty"}
  else
    proxy = {
      _ = "proxySocks5",
      port = port,
      username = username,
      password = password
    }
  end

  assert (tdbot_function ({
    _ = "setProxy",
    proxy = proxy
  }, cb or dl_cb, cmd))
end

-- Returns current set up proxy. Can be called before authorization
function I.getProxy(cb, cmd)
  assert (tdbot_function ({
    _ = "getProxy",
  }, cb or dl_cb, cmd))
end

-- Text message
-- @chat_id Chat to send message
-- @reply_to_message_id Identifier of a message to reply to or 0
-- @text Text to send
-- @disable_notification Pass true, to disable notification about the message, doesn't works in secret chats
-- @from_background Pass true, if the message is sent from background
-- @reply_markup Bots only. Markup for replying to message
-- @disable_web_page_preview Pass true to disable rich preview for link in the message text
-- @clear_draft Pass true if chat draft message should be deleted
-- @entities Bold, Italic, Code, Pre, PreCode and TextUrl entities contained in the text. Non-bot users can't use TextUrl entities. Can't be used with non-null parse_mode
-- @parse_mode Text parse mode, nullable. Can't be used along with enitities
function I.sendMessage(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, text, disable_web_page_preview, entities, parse_mode, cb, cmd)
  local input_message_content = {
    _ = "inputMessageText",
    text = text,
    disable_web_page_preview = disable_web_page_preview,
    clear_draft = 0,
    entities = entities or {},
    parse_mode = getParseMode(parse_mode),
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Animation message
-- @animation Animation file to send
-- @thumb Animation thumb, if available
-- @duration Duration of the animation in seconds
-- @width Width of the animation, may be replaced by the server
-- @height Height of the animation, may be replaced by the server
-- @caption Animation caption, 0-200 characters
function I.sendAnimation(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, animation, duration, width, height, caption, ttl, cb, cmd)
  local input_message_content = {
    _ = "inputMessageAnimation",
    animation = getInputFile(animation),
	thumb = thumb,
    duration = duration or 0,
    width = width or 0,
    height = height or 0,
    caption = caption,
	ttl = ttl
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Audio message
-- @audio Audio file to send
-- @album_cover_thumb Thumb of the album's cover, if available
-- @duration Duration of the audio in seconds, may be replaced by the server
-- @title Title of the audio, 0-64 characters, may be replaced by the server
-- @performer Performer of the audio, 0-64 characters, may be replaced by the server
-- @caption Audio caption, 0-200 characters
function I.sendAudio(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, audio, duration, title, performer, caption, cb, cmd)
  local input_message_content = {
    _ = "inputMessageAudio",
    audio = getInputFile(audio),
	album_cover_thumb = album_cover_thumb,
    duration = duration or 0,
    title = title or 0,
    performer = performer,
    caption = caption
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Document message
-- @document Document to send
-- @thumb Document thumb, if available
-- @caption Document caption, 0-200 characters
function I.sendDocument(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, document, caption, cb, cmd)
  local input_message_content = {
    _ = "inputMessageDocument",
    document = getInputFile(document),
	thumb = thumb,
    caption = caption
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Photo message
-- @photo Photo to send
-- @thumb Photo thumb to send, is sent to the other party in secret chats only
-- @added_sticker_file_ids File identifiers of stickers added onto the photo
-- @width Photo width
-- @height Photo height
-- @caption Photo caption, 0-200 characters
-- @ttl Photo TTL in seconds, 0-60. Non-zero TTL can be only specified in private chats
function I.sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption, ttl, cb, cmd)
  local input_message_content = {
    _ = "inputMessagePhoto",
    photo = getInputFile(photo),
	thumb = thumb
    added_stickerfile_ids = {},
    width = 0,
    height = 0,
    caption = caption,
    ttl = ttl or 0
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Sticker message
-- @sticker Sticker to send
-- @thumb Sticker thumb, if available
-- @width Sticker width
-- @height Sticker height
function I.sendSticker(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, sticker, width, height, cb, cmd)
  local input_message_content = {
    _ = "inputMessageSticker",
    sticker = getInputFile(sticker),
	thumb = thumb,
    width = width or 0,
    height = height or 0
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Video message
-- @video Video to send
-- @thumb Video thumb, if available
-- @duration Duration of the video in seconds
-- @width Video width
-- @height Video height
-- @caption Video caption, 0-200 characters
-- @ttl Video TTL in seconds, 0-60. Non-zero TTL can be only specified in private chats
function I.sendVideo(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, video, duration, width, height, caption, ttl, cb, cmd)
  local input_message_content = {
    _ = "inputMessageVideo",
    video = getInputFile(video),
    added_stickerfile_ids = {},
    duration = duration or 0,
    width = width or 0,
    height = height or 0,
    caption = caption,
    ttl = ttl
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Video note message
-- @video_note Video note to send
-- @thumb Video thumb, if available
-- @duration Duration of the video in seconds
-- @length Video width and height, should be positive and not greater than 640
function I.sendVideoNote(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, video_note, duration, length, cb, cmd)
  if not length or length > 640 then
    length = 640
  end
  local input_message_content = {
    _ = "inputMessageVideoNote",
    video_note = getInputFile(video_note),
    added_stickerfile_ids = {},
    duration = duration or 0,
    length = length
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Voice message
-- @voice Voice file to send
-- @duration Duration of the voice in seconds
-- @waveform Waveform representation of the voice in 5-bit format
-- @caption Voice caption, 0-200 characters
function I.sendVoice(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, voice, duration, waveform, caption, cb, cmd)
  local input_message_content = {
    _ = "inputMessageVoice",
    voice = getInputFile(voice),
    duration = duration or 0,
    waveform = waveform,
    caption = caption
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Message with location
-- @location Location to send
-- @latitude Latitude of location in degrees as defined by sender
-- @longitude Longitude of location in degrees as defined by sender
function I.sendLocation(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, latitude, longitude, cb, cmd)
  local input_message_content = {
    _ = "inputMessageLocation",
    location = {
      _ = "location",
      latitude = latitude,
      longitude = longitude
    },
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Message with information about venue
-- @venue Venue to send
-- @latitude Latitude of location in degrees as defined by sender
-- @longitude Longitude of location in degrees as defined by sender
-- @title Venue name as defined by sender
-- @address Venue address as defined by sender
-- @provider Provider of venue database as defined by sender. Only "foursquare" need to be supported currently
-- @id Identifier of the venue in provider database as defined by sender
function I.sendVenue(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, latitude, longitude, title, address, provider, id, cb, cmd)
  local input_message_content = {
    _ = "inputMessageVenue",
    venue = {
      _ = "venue",
      location = {
        _ = "location",
        latitude = latitude,
        longitude = longitude
      },
      title = title,
      address = address,
      provider = provider or 'foursquare',
      id = id
    },
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- User contact message
-- @contact Contact to send
-- @phone_number User's phone number
-- @first_name User first name, 1-255 characters
-- @last_name User last name
-- @user_id User identifier if known, 0 otherwise
function I.sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id, cb, cmd)
  local input_message_content = {
    _ = "inputMessageContact",
    contact = {
      _ = "contact",
      phone_number = phone_number,
      first_name = first_name,
      last_name = last_name,
      user_id = user_id
    },
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Message with a game
-- @bot_user_id User identifier of a bot owned the game
-- @game_short_name Game short name
function I.sendGame(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, bot_user_id, game_short_name, cb, cmd)
  local input_message_content = {
    _ = "inputMessageGame",
    bot_user_id = bot_user_id,
    game_short_name = game_short_name
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Message with an invoice
-- can be used only by bots and in private chats only
-- @prices List of objects used to calculate total price
-- @currency ISO 4217 currency code
-- @is_test True, if payment is test
-- @need_name True, if user's name is needed for payment
-- @need_phone_number True, if user's phone number is needed for payment
-- @need_email True, if user's email is needed for payment
-- @need_shipping_address True, if user's shipping address is needed for payment
-- @is_flexible True, if total price depends on shipping method
-- @invoice The invoice
-- @title Product title, 1-32 characters
-- @param_description Product description, 0-255 characters
-- @photourl Goods photo URL, optional
-- @photosize Goods photo size
-- @photowidth Goods photo width
-- @photoheight Goods photo height
-- @payload Invoice payload
-- @provider_token Payments provider token
-- @start_parameter Unique invoice bot start_parameter for generation of this invoice
function I.sendInvoice(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, currency, prices, is_test, need_name, need_phone_number, need_email, need_shipping_address, is_flexible, title, description,  photourl, photosize,  photowidth, photoheight, payload, provider_token, start_parameter, cb, cmd)
  local input_message_content = {
    _ = "inputMessageInvoice",
    invoice = {
      _ = "invoice",
      currency = currency,
      prices = prices,
      is_test = is_test,
      need_name = need_name,
      need_phone_number = need_phone_number,
      need_email = need_email,
      eed_shipping_address = need_shipping_address,
      is_flexible = is_flexible
    },
    title = title,
    description = description,
    photourl = photourl,
    photosize = photosize or 0,
    photowidth = photowidth or 0,
    photoheight = photoheight or 0,
    payload = payload,
    provider_token = provider_token,
    start_parameter = start_parameter
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

-- Forwarded message
-- @from_chat_id Chat identifier of the message to forward
-- @message_id Identifier of the message to forward
-- @in_game_share Pass true to share a game message within a launched game, for Game messages only
function I.sendForwarded(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, from_chat_id, in_game_share, message_id, cb, cmd)
  local input_message_content = {
    _ = "inputMessageForwarded",
    from_chat_id = from_chat_id,
    message_id = message_id,
    in_game_share = in_game_share
  }
  sendRequest('sendMessage', chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end

return I
