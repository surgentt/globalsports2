class AudioTimelineAsset < ActiveRecord::Base
  belongs_to :audio_asset
  belongs_to :audio_timeline

  named_scope :for, lambda { |timeline_id, asset_id| { :conditions => { :audio_timeline_id => timeline_id, :audio_asset_id => asset_id  } } }

end