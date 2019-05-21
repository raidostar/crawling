class Gunosy
  require 'capybara'
  require 'capybara/poltergeist'
  require 'rest-client'
  require 'csv'

  DEFAULT_HEADERS = {
    'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36",
    'Accept-Language': 'ja'
  }.freeze
  DEFAULT_SLEEP = 8.freeze

  def initialize(options = {})
    %w(id password).each do |arg|
      instance_variable_set('@' + arg, options[arg.to_sym])
      raise "#{arg} is not set" unless options[arg.to_sym]
    end
    @session = nil
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3
  end

  def daily_report(date)
    obtain_login_cookie
    advertiser_ids = retrieve_advertiser_ids(date)

    advertiser_ids.each do |advertiser_id, advertiser_name|
      response = RestClient::Request.new(
        method:  :get,
        cookies: export_cookies,
        url:     "https://ads.gunosy.com/creative/list.json?campaign_id=#{advertiser_id}&date_range=custom&span_to=#{date.strftime('%Y/%m/%d')}&span_from=#{date.strftime('%Y/%m/%d')}&with_start_status=true&with_stop_status=true&with_finished_status=true&sEcho=2&iColumns=16&sColumns=&iDisplayStart=0&iDisplayLength=-1&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&mDataProp_7=7&mDataProp_8=8&mDataProp_9=9&mDataProp_10=10&mDataProp_11=11&mDataProp_12=12&mDataProp_13=13&mDataProp_14=14&mDataProp_15=15&sSearch=&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&sSearch_4=&bRegex_4=false&bSearchable_4=true&sSearch_5=&bRegex_5=false&bSearchable_5=true&sSearch_6=&bRegex_6=false&bSearchable_6=true&sSearch_7=&bRegex_7=false&bSearchable_7=true&sSearch_8=&bRegex_8=false&bSearchable_8=true&sSearch_9=&bRegex_9=false&bSearchable_9=true&sSearch_10=&bRegex_10=false&bSearchable_10=true&sSearch_11=&bRegex_11=false&bSearchable_11=true&sSearch_12=&bRegex_12=false&bSearchable_12=true&sSearch_13=&bRegex_13=false&bSearchable_13=true&sSearch_14=&bRegex_14=false&bSearchable_14=true&sSearch_15=&bRegex_15=false&bSearchable_15=true&iSortCol_0=14&sSortDir_0=desc&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&bSortable_6=true&bSortable_7=true&bSortable_8=true&bSortable_9=true&bSortable_10=true&bSortable_11=true&bSortable_12=true&bSortable_13=true&bSortable_14=true&bSortable_15=true&_=1532059421683",
        timeout: 300
      ).execute
      sleep DEFAULT_SLEEP / 2

      creative_reports = JSON.parse(response.body)["aaData"]

      creative_reports.each do |data|
        creative_id        = data[1]
        creative_name      = data[2].gsub(/<.*?>/, "")
        creative_image_url = data[5][/src=\"((.*?))\"/, 1]

        report = {
          date:               date,
          advertiser_id:      advertiser_id,
          advertiser_name:    advertiser_name,
          order_id:           advertiser_id,
          order_name:         advertiser_name,
          schedule_id:        creative_id,
          schedule_name:      creative_name,
          creative_id:        creative_id,
          creative_name:      creative_name,
          creative_image_url: creative_image_url,
          imp:   data[8].gsub(/\D/, ''),
          click: data[9].gsub(/\D/, ''),
          cv:    data[13].gsub(/\D/, ''),
          net:   data[17].gsub(/\D/, ''),
        }
        yield(report) if block_given?
      end
      sleep DEFAULT_SLEEP
    end
  end

  def retrieve_advertiser_ids(date)
    output = {}
    @session.visit('https://ads.gunosy.com/campaigns')
    sleep DEFAULT_SLEEP
    @session.find('#dateRange').find(:xpath, "//option[@value='custom']").select_option
    sleep DEFAULT_SLEEP / 4
    @session.find('#span_from').set(date.strftime('%Y/%m/%d'))
    sleep DEFAULT_SLEEP / 4
    @session.find('#span_to').set(date.strftime('%Y/%m/%d'))
    sleep DEFAULT_SLEEP / 4
    @session.find('#paginates_per').find(:xpath, "//option[@value='5000']").select_option
    sleep DEFAULT_SLEEP / 4
    @session.find(:xpath, "//*[@id='content-header']/div[3]/form/div[3]/div/input").trigger('click')
    sleep DEFAULT_SLEEP * 2

    @session.all("table tbody#records tr").each do |element|
      advertiser_id   = element.find(:xpath, "#{element.path}/td[1]").text
      advertiser_name = element.find(:xpath, "#{element.path}/td[2]").text
      net             = element.find(:xpath, "#{element.path}/td[17]/div").text.gsub(/\D/, '').to_i
      next if net == 0
      output[advertiser_id] = advertiser_name
    end
    return output
  end

  private

  def obtain_login_cookie
    @session = Capybara::Session.new(:poltergeist)
    login
  end

  def export_cookies
    output  = {}
    cookies = @session.driver.cookies
    cookies.each do |k,v|
      output[k.to_sym] = v.instance_variable_get(:@attributes)['value']
    end
    return output
  end

  def login
    @session.visit "https://ads.gunosy.com/client/sign_in"
    sleep DEFAULT_SLEEP
    @session.find('#client_email').set(@id)
    sleep DEFAULT_SLEEP / 4
    @session.find('#client_password').set(@password)
    sleep DEFAULT_SLEEP / 4
    @session.find(:xpath, "//input[@type='submit']").trigger('click')
    sleep DEFAULT_SLEEP
  end
end