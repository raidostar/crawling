class LoglyController < ApplicationController
  require "open-uri"
  require "mechanize"
  require "nokogiri"
  require "date"

  def index
    # Login with Mechanize Gem
    agent = Mechanize.new
    page = agent.get("https://www.logly.co.jp/")
    login = page.form_with(:action => "/users/sign_in")
    login.field_with(:name => "user[email]").value = ENV["LOGLY_ACCOUNT"]
    login.field_with(:name => "user[password]").value = ENV["LOGLY_PASSWORD"]
    @login_result = agent.submit login
    host_page = @login_result.link_with(:text =>"すべての広告主").click

    number=0
    @number=0
    # Getting All the Advertiser
    @doc = host_page.css("div#collapse1 ul li");
    @num_of_advertiser = @doc.css("a").size();
    page_num=2 # is there page 2?
    # begin
    #   while(true)
    #     if number==@num_of_advertiser
    #       break
    #     end
    #     @advertiser_name = @doc.css("a")[number].text
    #     @advertiser_id = @doc.css("a")[number]["href"].delete("/agency/advertisers/redirect_to_dashboard")
    #     host_page.link_with(:text=>@advertiser_name).click
    #     @item_page = agent.get("https://www.logly.co.jp/ads")
    #     @test3 = @item_page.css("tr td")
    #     if @test3.inner_text.empty?
    #       number+=1
    #       @number = number
    #     else
    #       @test3_size = @test3.size()
    #       @col_num = 17
    #       @row_num = @test3_size/@col_num
    #       @test2 = @item_page.css("tr")
    #       break
    #     end
    #   end
    #   if number==@num_of_advertiser
    #     break
    #   end
    #   j=0;k=0;
    #   for i in 0...@row_num
    #     date = Date.today
    #     time = Time.now
    #     @report = DailyReport.new(
    #     date: date,
    #     platform_id: 20,
    #     advertiser_id: @advertiser_id,
    #     advertiser_name: @advertiser_name,
    #     group_advertiser_id: 20,
    #     order_id: @test3.css("a")[k+3]["href"].delete("/campaigns"),
    #     order_name: @test3[j+4].text,
    #     group_order_id: 20,
    #     schedule_id: @test3.css("a")[k+2]["href"].delete("/adgroups"),
    #     schedule_name: @test3[j+3].text,
    #     creative_id: @test3[j].text,
    #     creative_name: @test3[j+1].text,
    #     creative_image_url: @test3.css("img")[i*2+1]["src"],
    #     click_url: @test3.css("a")[k]["href"],
    #     imp: @test3[j+6].text,
    #     click: @test3[j+7].text,
    #     cv: @test3[j+8].text,
    #     gross: 0,
    #     net: 0,
    #     created_at: time,
    #     updated_at: time,
    #     lock_version: 0)
    #     @report.save
    #     j=j+@col_num
    #     k=k+@test2[i+1].css("a").size()
    #   end
    #   if @item_page.link_with(:href=>("/ads/list?page="+page_num.to_s)).nil?
    #     number+=1
    #     @number = number
    #   else
    #     @item_page =@item_page.link_with(:href=>("/ads/list?page="+page_num.to_s)).click
    #     page_num+=1
    #   end
    # end while number<@num_of_advertiser
  end
end