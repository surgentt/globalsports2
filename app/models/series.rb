require 'open-uri'

class Series < ActiveRecord::Base

  has_many :series_videos, :order => 'time ASC'

  named_scope :active, { :conditions=>['end > ?', (Time.now + 1.day).in_time_zone] }

  def feature
    t = Time.now.in_time_zone
    c = ['time < ? and (status is null or (status != ? and status != ?) )', t, 'over', 'Pending VOD']
    f = series_videos.find(:last, :conditions=>c)
    f = series_videos.first if f.nil?
    f
  end

  def pull

    #http://gs9.video4ever.net/sportzcast.aspx?cmd=medialist&style=gs9
    url = "http://#{self.host_key}.video4ever.net/sportzcast.aspx?cmd=medialist&style=#{self.host_key}"
    doc = Hpricot(open(url).read)

    (doc/:medialist/:event).each { |event|

      event_id = event[:id]

      sv = SeriesVideo.find_by_media_id(event_id) || SeriesVideo.new()

      sv.series = self

      sv.media_id= event_id
      sv.sport = event[:typ]
      sv.title = event[:title]
      #self.time = "#{event[:time]} #{series.timezone}"
      sv.time = event[:dte]
      sv.status = event[:status]


      #typ="Baseball"
      #title="Game 4 - Clifton Park, NY vs. Eagle Pass, TX"
      #id="6882"
      #status="Pending"
      #datetime="081920110730"
      #style="gs3"
      #dte="08/19/11 7:30 PM EDT">

      logger.info("Found #{sv.id} #{sv.title} - #{sv.sport} - #{sv.time}")

      sv.save!
      logger.info("Am #{sv.id} #{sv.title} - #{sv.sport} - #{sv.time}")
    }

    # http://botweb.video4ever.net/botweb.aspx?bot=6
    # http://gs9.video4ever.net/(S(xh5negtmau1lzzxogftttktu))/sportzcast.aspx?cmd=getmedia&id=6672&style=gs9
    # http://gs7.video4ever.net/(S(oxldlcsfhqmcyki244zzygg3))/sportzcast.aspx?cmd=getmedia&id=6670&style=gs7
    # http://gs7.video4ever.net/(S(oxldlcsfhqmcyki244zzygg3))/sportzcast.aspx?cmd=getmeta&id=6670&bot=300
    # http://gs9.video4ever.net/(S(wut5usr1zshylyquqqow3a2b))/sportzcast.aspx?cmd=mediainfo&id=6672&style=gs9&user=v4e

    #series_videos.each() do |series_video|
    #  series_video.pull!
    #end

  end

end
