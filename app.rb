require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'slim'
require 'base64'
require 'digest/md5'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  register Sinatra::ConfigFile

  config_file './config.yml'

  Slim::Engine.set_options pretty: true

  set :root, File.dirname(__FILE__)

  configure do
    enable :sessions
  end

  use Rack::Session::Cookie,
    :key => 'rack.session',
    :expire_after => 3600,
    :secret => Digest::SHA256.hexdigest(rand.to_s)

  helpers do
    # @return [Boolean]
    def complete?
      status = true
      (1..5).each do |i|
        status = false unless session[:"flag#{i}"]
      end
      status
    end
  end

  before do
    response.headers['Flag-5'] = Base64.encode64(settings.flags[:flag5])
  end

  get '/' do
    response.set_cookie('user', Digest::MD5.hexdigest('guest'))
    slim :'pages/index'
  end

  post '/' do
    if check_flag(params['flag'])
      slim :'pages/index', locals: { success: true, message: settings.messages[:success] }
    else
      slim :'pages/index', locals: { success: false, message: settings.messages[:wrong] }
    end
  end

  get '/flag' do
    slim :'pages/flag', locals: { flag: settings.flags[:flag1] }
  end

  get '/admin' do
    if request.cookies['user'] == Digest::MD5.hexdigest('admin')
      slim :'pages/flag', locals: { flag: settings.flags[:flag2] }
    else
      slim :'pages/error', locals: { message: settings.messages[:admin] }
    end
  end

  get '/75e63ab2c2ed80bf811c09b073d82077' do
    if request.user_agent == settings.user_agent
      slim :'pages/flag', locals: { flag: settings.flags[:flag3] }
    else
      slim :'pages/error', locals: { message: settings.messages[:browser] }
    end
  end

  # 404 Not Found
  not_found do
    slim :'pages/error', locals: { message: settings.messages[:not_found] }
  end

  # 500 Internal Server Error
  error do
    slim :'pages/error', locals: { message: settings.messages[:error] }
  end

  # @return [true | nil]
  def check_flag(param)
    if settings.flags.value?(param)
      key = settings.flags.key(param).to_sym
      session[key] = true
    end
  end
end
