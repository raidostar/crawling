class Akane
  require 'capybara'
  require 'capybara/poltergeist'
  require 'rest-client'
  require 'csv'

  DEFAULT_HEADERS = {
    'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
    'Accept-Language': 'ja'
  }.freeze
  DEFAULT_SLEEP = 3.freeze

  def initialize(options = {})
    %w(id password).each do |arg|
      instance_variable_set('@' + arg, options[arg.to_sym])
      raise "#{arg} is not set" unless options[arg.to_sym]
    end
    @session = nil
    @cookie = nil
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
    end
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist
    Capybara.default_max_wait_time = 3
  end

  def daily_report(date)
    obtain_login_cookie

    report_url = "https://www.akane-ad.com/agent/reports"
    payload = {
      sponsor_id: "0",
      period: "sel",
      start_date: date.strftime('%Y-%m-%d'),
      end_date: date.strftime('%Y-%m-%d'),
      type: "sponsor",
      carrier_type_ids: ["1", "5", "6"],
      status: "except_delete",
      csv: "csv"
    }
    advertiser_ids = {}
=begin response looks like this
"集計区分：広告主別"
"集計期間：2017-07-13 〜 2017-07-13"

"ID","広告主名","表示回数","クリック数","CTR","CPC","MCV","MCVR","MCPA","CV","CVR","CPA","eCPM","課金金額"
"7793","株式会社ART OF LIFE","1880493","418","0.022","32.9","25","5.98","550","2","0.478","6879","7.316","13758"
"7825","株式会社メディアハーツ","71722","115","0.16","46.0","22","19.13","240","0","0.0","0","73.896","5300"
"7907","株式会社ラッシャーマン(DCH)","1850","5","0.27","40.0","0","0.0","0","0","0.0","0","108.108","200"
"7919","株式会社メビウス製薬","409190","80","0.019","38.9","9","11.25","346","0","0.0","0","7.61","3114"
"7952","株式会社ECスタジオ","333949","129","0.038","39.8","0","0.0","0","0","0.0","0","15.412","5147"
"7976","株式会社オンライフ","33644","118","0.35","50.9","16","13.559","376","0","0.0","0","178.843","6017"
"8044","株式会社メディアハーツ（すっきりレッドスムージー）","65177","135","0.207","38.9","17","12.592","309","0","0.0","0","80.703","5260"
"合計","","2796025","1000","0.035","38.7","89","8.9","435","2","0.2","19398","13.875","38796"
=end
    Tempfile.create("advertisers") do |f|
      f.binmode
      block = proc do |response|
        response.read_body do |chunk|
          f.write chunk
        end
      end
      RestClient::Request.new(
        method: :get,
        cookies: export_cookies,
        url: report_url,
        timeout: 300,
        payload: payload,
        block_response: block
      ).execute
      f.read
      CSV.foreach(f.path, encoding: "CP932:UTF-8").with_index do |row, i|
        next if i < 4 || row[0] == '合計'
        advertiser_ids[row[0]] = row[1]
      end
    end

    advertiser_ids.each do |advertiser_id, advertiser_name|
      payload = {
        sponsor_id: [advertiser_id],
        period: "sel",
        start_date: date.strftime('%Y-%m-%d'),
        end_date: date.strftime('%Y-%m-%d'),
        type: "creative",
        carrier_type_ids: ["1", "5", "6"],
        status: "except_delete",
        csv: "csv"
      }
      Tempfile.create("creatives") do |f|
        f.binmode
        block = proc do |response|
          response.read_body do |chunk|
            f.write chunk
          end
        end
        RestClient::Request.new(
          method: :get,
          cookies: export_cookies,
          url: report_url,
          timeout: 300,
          payload: payload,
          block_response: block
        ).execute
        f.read
        CSV.foreach(f.path, encoding: "CP932:UTF-8").with_index do |row, i|
          next if i < 4 || row[0] == '合計'
          report = {
            date: date,
            advertiser_id: advertiser_id,
            advertiser_name: advertiser_name,
            order_id: advertiser_id,
            order_name: advertiser_name,
            schedule_id: row[0],
            schedule_name: row[1],
            creative_id: row[2],
            creative_name: row[3],
            click_url: row[6],
            imp: row[7],
            click: row[8],
            cv: row[14],
            net: row[18],
          }
          yield(report) if block_given?
        end
      end
    end
  ensure
    @session.driver.quit
  end

  private

  def obtain_login_cookie
    @session = Capybara::Session.new(:poltergeist)
    login
  end

  def export_cookies
    output = {}
    cookies = @session.driver.cookies
    cookies.each do |k,v|
      output[k.to_sym] = v.instance_variable_get(:@attributes)['value']
    end
    return output
  end

  def login
    action do
      @session.visit "https://www.akane-ad.com/agent/login"
      @session.find('#login_id').set(@id)
      @session.find('#password').set(@password)
      @session.find(:xpath, "//input[@type='submit']").trigger('click')
    end
  end

  def action
    yield if block_given?
    sleep DEFAULT_SLEEP
  end
end