# frozen_string_literal: true

require 'rspec/expectations'
require 'capybara/spec/spec_helper'
require 'webdrivers' if ENV['CI']
require 'selenium_statistics'
require 'selenium-webdriver'
require 'capybara/rspec'

module Capybara
  module SpecHelper
    def firefox?(session)
      browser_name(session) == :firefox &&
        session.driver.browser.capabilities.is_a?(::Selenium::WebDriver::Remote::W3C::Capabilities)
    end

    def firefox_lt?(version, session)
      firefox?(session) && (session.driver.browser.capabilities[:browser_version].to_f < version)
    end

    def firefox_gte?(version, session)
      firefox?(session) && (session.driver.browser.capabilities[:browser_version].to_f >= version)
    end

    def chrome?(session)
      browser_name(session) == :chrome
    end

    def chrome_lt?(version, session)
      chrome?(session) && (session.driver.browser.capabilities[:version].to_f < version)
    end

    def chrome_gte?(version, session)
      chrome?(session) && (session.driver.browser.capabilities[:version].to_f >= version)
    end

    def edge?(session)
      browser_name(session) == :edge
    end

    def ie?(session)
      %i[internet_explorer ie].include?(browser_name(session))
    end

    def safari?(session)
      %i[safari Safari Safari_Technology_Preview].include?(browser_name(session))
    end

    def browser_name(session)
      session.driver.browser.browser if session.respond_to?(:driver)
    end

    def remote?(session)
      session.driver.browser.is_a? ::Selenium::WebDriver::Remote::Driver
    end
  end
end

RSpec.configure do |config|
  Capybara::SpecHelper.configure(config)
  config.filter_run_including focus_: true unless ENV['CI']
  config.run_all_when_everything_filtered = true
  config.after(:suite) { SeleniumStatistics.print_results }
end

# Capybara自体の設定、ここではどのドライバーを使うかを設定しています
Capybara.configure do |capybara_config|
  capybara_config.default_driver = :selenium_chrome
  capybara_config.default_max_wait_time = 10 # 一つのテストに10秒以上かかったらタイムアウトするように設定しています
end
# Capybaraに設定したドライバーの設定をします
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('headless') # ヘッドレスモードをonにするオプション
  options.add_argument('--disable-gpu') # 暫定的に必要なフラグとのこと
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome
