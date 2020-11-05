module MessagesHelper
  def x_days_after
    x_days_after = []
    min_day = 0
    max_day = 100
    (min_day..max_day).each do |day|
      x_days_after.push([day, day])
    end
    x_days_after
  end
end
