class AudioTimeline < ActiveRecord::Base
  has_many :audio_timeline_assets
  #has_many :audio_assets, :through => :audio_timeline_assets



  #belongs_to :video_asset
  belongs_to :user
  belongs_to :video, :polymorphic => true


  named_scope :for_video, lambda { |video| { :conditions => {:video_type=>video.class.name, :video_id=>video.id} }  }


  def self.for_dockey(dockey, user = nil)
    video = VideoAsset.find_by_dockey(dockey) || VideoClip.find_by_dockey(dockey) || VideoReel.find_by_dockey(dockey) || VideoUser.find_by_dockey(dockey)
    timeline = for_video(video).first
    if !timeline
      timeline = AudioTimeline.new()
      timeline.video = video
      timeline.status = AudioAsset::STATUS_NEW
      timeline.user = user
      timeline.save!
    end
    timeline
  end

  def set_dockey(dockey)
    self.video = VideoAsset.find_by_dockey(dockey) || VideoClip.find_by_dockey(dockey) || VideoReel.find_by_dockey(dockey) || VideoUser.find_by_dockey(dockey)
  end


  def xml_builder()
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml
  end

  def to_xml(xml = xml_builder())
    xml.audioTimeline(
      :id=>self.id,
      :status=>self.status,
      :dockey=>(self.video ? self.video.dockey : '')
    ) {
      xml.created_at(self.created_at)
      self.audio_timeline_assets.each() {|timeline_asset|
        asset = timeline_asset.audio_asset
        #xml.audioBite(:id=>asset.id, :timelinePosition=>self.start_position, :status=>asset.status, :dockey=>asset.dockey, :length=>asset.length)
        asset.to_xml(xml, :timelinePosition=>timeline_asset.start_position)
      }
    }
  end


end