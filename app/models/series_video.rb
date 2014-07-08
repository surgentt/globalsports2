require 'open-uri'

class SeriesVideo < ActiveRecord::Base

  belongs_to :series

  belongs_to :asset, :polymorphic => true

  STATUS_OLD_OVER = 'over'
  STATUS_OVER = 'Pending VOD'

  def thumbnail

    if asset
      asset.thumbnail
    elsif time && Time.now > time
      if status == STATUS_OLD_OVER || status == STATUS_OVER
        '/images/video_processing.jpg'
      else
        '/images/video_live.jpg'
      end
    else
      '/images/video_upcoming.jpg'
    end

  end

  def pull!
    url = "http://#{series.host_key}.video4ever.net/sportzcast.aspx?cmd=getmeta&id=#{media_id}"
    doc = Hpricot(open(url).read)

    (doc/:metadata/:event).each { |event|
      self.title = event[:title]
      self.time = "#{event[:time]} #{series.timezone}"
      self.sport = event[:sport]

      logger.info("Found #{self.title} - #{self.sport} - #{self.time}")

      save!
      logger.info("Am #{self.title} - #{self.sport} - #{self.time}")
      return
    }
  end


end
