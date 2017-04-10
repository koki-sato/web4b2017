require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'sinatra/json'
require 'slim'
require 'uri'
require 'net/http'
require 'json'
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
    :expire_after => 36000,
    :secret => Digest::SHA256.hexdigest(rand.to_s)

  PANEL_MIN_ID = 1
  PANEL_MAX_ID = 300
  PANEL_HIT_ID = 183

  GAME = { win: 1, draw: 0, lose: -1 }

  helpers do
    # @return [Boolean]
    def half_complete?
      status = true
      (1..5).each do |i|
        status = false unless session[:"flag#{i}"]
      end
      status
    end

    # @return [Boolean]
    def full_complete?
      status = true
      (1..10).each do |i|
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
    before_status = half_complete?
    if check_flag(params['flag'])
      if before_status ^ half_complete?
        slim :'pages/congratulations'
      else
        slim :'pages/index', locals: { success: true, message: settings.messages[:success] }
      end
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
      slim :'pages/error', locals: { message: settings.messages[:only_admin] }
    end
  end

  get '/75e63ab2c2ed80bf811c09b073d82077' do
    if request.user_agent == settings.user_agent
      slim :'pages/flag', locals: { flag: settings.flags[:flag3] }
    else
      slim :'pages/error', locals: { message: settings.messages[:browser_check] }
    end
  end

  get '/game' do
    pass unless half_complete?
    slim :'pages/game'
  end

  post '/api/v1/game/judge' do
    params = JSON.parse(request.body.read)
    if params.key?('hand') && params.key?('record') && params.key?('check_digest')
      if params['check_digest'] == Digest::MD5.hexdigest("#{params['record']}:#{params['hand']}")
        result = GAME.values.sample
        record = params['record'].split(',').push(result).join(',')
        data = {
          result: result,
          record: record,
          message: settings.messages[GAME.key(result).to_sym]
        }
        if record =~ /(1,){9,}1/
          data[:flag] = "Congratulations! Flag is #{settings.flags[:flag6]}"
        end
        json data
      end
    end
  end

  get '/panels' do
    pass unless half_complete?
    slim :'pages/panel'
  end

  get '/panels/:id' do |id|
    pass unless half_complete?
    pass unless (id.to_i >= PANEL_MIN_ID && id.to_i <= PANEL_MAX_ID)
    if id == PANEL_HIT_ID.to_s
      slim :'pages/flag', locals: { flag: settings.flags[:flag7] }
    else
      slim :'pages/error', locals: { message: settings.messages[:incorrect_number] }
    end
  end

  get '/send' do
    pass unless half_complete?
    slim :'pages/send'
  end

  post '/send' do
    pass unless half_complete?
    begin
      uri = URI.parse(params['url'])
      param = { flag8: settings.flags[:flag8] }
      res = Net::HTTP.post_form(uri, param)
      slim :'pages/send', locals: { success: true, message: settings.messages[:send_ok] }
    rescue
      slim :'pages/send', locals: { success: false, message: settings.messages[:invalid_url] }
    end
  end

  get '/cookie' do
    pass unless half_complete?
    slim :'pages/cookie'
  end

  get '/mighty' do
    pass unless half_complete?
    slim :'pages/mighty'
  end

  # 404 Not Found
  not_found do
    html :'404'
  end

  # 500 Internal Server Error
  error do
    html :'500'
  end

  # @param view [Symbol]
  def html(view)
    File.read(File.join('public', "#{view.to_s}.html"))
  end

  # @param param [String]
  # @return [true, nil]
  def check_flag(param)
    if settings.flags.value?(param)
      key = settings.flags.key(param).to_sym
      session[key] = true
    end
  end
end
