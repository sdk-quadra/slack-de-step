# frozen_string_literal: true

class PushTiming < ApplicationRecord
  belongs_to :message

  validates :time, presence: true
  validates :in_x_days, presence: true

  MIN_POLLING_TIME = 5
  EXTRA_TIME = 300

  with_options if: -> { time.present? } do
    validate :limit_schedule_time
  end

  def limit_schedule_time
    hour = Time.now.strftime("%H").to_i
    minutes = Time.now.strftime("%M").to_i
    seconds = Time.now.strftime("%S").to_i

    set_time = message.push_timing.time
    time_now = Time.local(2000, 1, 1, hour, minutes, seconds)

    channel_member_count = message.channel.member_count
    add_errors(set_time, time_now, channel_member_count)
  end

  def add_errors(set_time, time_now, channel_member_count)
    min_wait_time = (channel_member_count * MIN_POLLING_TIME) + EXTRA_TIME

    if (set_time - time_now) >= 0 && (set_time - time_now) <= min_wait_time
      case min_wait_time
      when 1...600
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より10分以上後を指定してください")
      when 600...1200
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より20分以上後を指定してください")
      when 1200...1800
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より30分以上後を指定してください")
      when 1800...2400
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より40分以上後を指定してください")
      when 2400...3000
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より50分以上後を指定してください")
      when 3000...3600
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より60分以上後を指定してください")
      when 3600...4200
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より70分以上後を指定してください")
      when 4200...4800
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より80分以上後を指定してください")
      when 4800...5400
        errors.add(:time, "このチャネルには対象者が#{channel_member_count}人います。現在時刻より90分以上後を指定してください")
      end
    end
  end
end
