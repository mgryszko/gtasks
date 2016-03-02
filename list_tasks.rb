require 'google/apis/tasks_v1'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Tasks API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = 'credentials.yaml'
SCOPE = Google::Apis::TasksV1::AUTH_TASKS_READONLY

def authorize
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

def create_tasks_service(authorize)
  Google::Apis::TasksV1::TasksService.new.tap do |service|
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
  end
end

def print_task_lists(service)
  task_lists = service.list_tasklists()
  puts "No task lists found" if task_lists.items.empty?
  task_lists.items.each do |task_list|
    puts "#{task_list.title}"
    print_tasks(service, task_list.id)
    puts
  end
end

def print_tasks(service, task_list_id)
    tasks = service.list_tasks(task_list_id)
    puts "No tasks" if tasks.items.empty?
    tasks.items.reject { |task| task.title.empty? }.each do |task|
      puts "#{task.completed ? '+' : '-'} #{task.title}"
    end
end

service = create_tasks_service(authorize)
print_task_lists(service)
