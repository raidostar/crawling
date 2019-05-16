set :output, "log/cron_log.log"
## config/schedule.rb
require "tzinfo"

def local(time)
  TZInfo::Timezone.get("Asia/Seoul").local_to_utc(Time.parse(time))
end

every :day, at: local("11:10 am") do
  rake "logly_collect:logly_collect"
end