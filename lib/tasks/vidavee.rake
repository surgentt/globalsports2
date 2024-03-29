namespace :vidavee do

  desc "Load or update all video assets from the vidavee backend"
  task :load_video_assets => :environment do
    Vidavee.load_backend_video
  end

  desc "Update length on all videos without a valid length"
  task :update_video_length => :environment do
    vidavee = Vidavee.find(:first)
    login = vidavee.login
    if login.nil?
      puts "Cannot log into vidavee back end"
      return
    end
    assets = VideoAsset.find(:all, :conditions => ["video_length IS NULL OR video_length = ''"])
    assets.each do |asset|
      vidavee.update_asset_record(login,asset,{'video_length' => true})
      asset.save!
    end
  end
  
  desc "Load or update all video clips (vtags) from the vidavee backend"
  task :load_video_clips => :environment do
    Vidavee.load_backend_clips
  end
  
  desc "Load or update all video reels (playlists) from the vidavee backend"
  task :load_video_reels => :environment do
    Vidavee.load_backend_reels
  end

  desc "Update the status of the specified user video from the vidavee backend"
  task :update_video_user_status => :environment do
    id = ARGV[1]
    if id.nil?
      puts "Specify ID on the command line"
      return
    end
    video_asset = VideoUser.find(id)
    if video_asset.nil?
      puts "No video for id #{id}"
      return
    end
    vidavee = Vidavee.find(:first)
    login = vidavee.login
    if login.nil?
      puts "Cannot log into vidavee back end"
      return
    end
    vidavee.update_asset_record(login,video_asset)
    video_asset.save!
    puts "Status is #{video_asset.video_status}"
  end

  desc "Update the status of the specified video asset from the vidavee backend"
  task :update_video_asset_status => :environment do
    id = ARGV[1]
    if id.nil?
      puts "Specify ID on the command line"
      return
    end
    video_asset = VideoAsset.find(id)
    if video_asset.nil?
      puts "No video for id #{id}"
      return
    end
    vidavee = Vidavee.find(:first)
    login = vidavee.login
    if login.nil?
      puts "Cannot log into vidavee back end"
      return
    end
    vidavee.update_asset_record(login,video_asset)
    video_asset.save!
    puts "Status is #{video_asset.video_status}"
  end

  desc "Get updated status for all videos that are still queued"
  task :update_queued_videos_status => :environment do
    vidavee = Vidavee.find(:first)
    login = vidavee.login
    if login.nil?
      puts "Cannot log into vidavee back end"
      return
    end
    
    conditions = ['video_status IN (?)',[Vidavee.QUEUED,Vidavee.TRANSCODING,Vidavee.UPLOAD_FAILED]]
    
    queued_assets = VideoAsset.find(:all, :conditions => conditions)
    queued_assets += VideoUser.find(:all, :conditions => conditions)
    
    queued_assets.each do |asset|
#      pre = asset.video_status
      vidavee.update_asset_record(login,asset,{'video_status' => true, 'video_length' => true})
#      if (asset.video_status != pre)
#        puts "Updating status of video #{asset.id} from #{pre} to #{asset.video_status} #{Time.now}"
#        asset.save!
#
#        # If it's ready now and it wasn't ready before
#        # we can remove the uploaded file if it exists
#        if (asset.video_status == Vidavee.READY && asset.uploaded_file_path)
#          FileUtils.rm_f asset.uploaded_file_path
#
#        elsif (asset.video_status == Vidavee.BLOCKED || asset.video_status == Vidavee.FAILED)
#          # Vidavee had a problem with it, notify the admin and the owner
#          fn = fullpath[File.dirname(asset.uploaded_file_path).length+1..-1]
#          [User.find_by_email(ADMIN_EMAIL),video_asset.user_id].uniq.each do |u|
#            m = Message.create(:title => "Video upload or transcoding failed for #{fn}",
#                               :body => "Video file #{fn} was not successfully processed by the video engine.\n Something might be wrong with the format.",
#                               :from_id => User.find_by_email(ADMIN_EMAIL).id,
#                               :to_id => u )
#          end
#        end
#      end
    end
    
    
  end

  desc "Re-try to push the specified video_asset.id to the vidavee backend"
  task :push_video_file => :environment do
    id = ARGV[1]
    if id.nil?
      puts "Specify ID on the command line"
      return
    end
    video_asset = VideoAsset.find(id)
    if video_asset.nil?
      puts "Video asset not found for id #{id}"
      return
    end
    vidavee = Vidavee.find(:first)
    login = vidavee.login
    if login.nil?
      puts "Cannot log into vidavee back end"
      return
    end
    dockey = vidavee.push_video login, video_asset, video_asset.uploaded_file_path
    if dockey
      puts "Success dockey=#{dockey}"
    else
      puts "Failed"
    end
  end
  
  #  CALLED FROM CRON
  
  desc "Push the specified video_asset.status to the vidavee backend.  Default status is 'saving'"
  task :push_video_file_by_status, [:status] => :environment do |t,args|

    args.with_defaults(:status => Vidavee.SAVING)  
    
    push_count = VideoAsset.count(:all, :conditions=>{ :video_status => Vidavee.PUSHING })
    if push_count > 4
      puts "There are currently #{push_count} videos being pushed... let's wait."
      return
    end
        
    video_asset = VideoAsset.find(:first, :conditions=>{ :video_status => args.status })
    if video_asset.nil?
      puts "Video asset not found for status #{args.status}"
      return
    end
    
    puts "Pushing video_asset id:#{video_asset.id}"

    dockey = video_asset.push_me()

    if dockey
      puts "Success dockey=#{dockey}"
    else
      puts "Failed"
    end
    

  end




  desc "Push the specified video_asset.status to the vidavee backend.  Default status is 'saving'"
  task :push_user_video_file_by_status, [:status] => :environment do |t,args|

    args.with_defaults(:status => Vidavee.SAVING)

    push_count = VideoUser.count(:all, :conditions=>{ :video_status => Vidavee.PUSHING })
    if push_count > 4
      puts "There are currently #{push_count} user videos being pushed... let's wait."
      return
    end

    video_user = VideoUser.find(:first, :conditions=>{ :video_status => args.status })
    if video_user.nil?
      puts "Video asset not found for status #{args.status}"
      return
    end

    puts "Pushing video_user id:#{video_user.id}"

    dockey = video_user.push_me()

    if dockey
      puts "Success dockey=#{dockey}"
    else
      puts "Failed"
    end


  end



  desc "Push new audio files to the vidavee backend."
  task :push_new_audio => :environment do

    push_count = AudioAsset.count(:all, :conditions=>{ :status => AudioAsset::STATUS_PUSHING })
    if push_count > 4
      puts "There are currently #{push_count} audio files being pushed... let's wait."
      return
    end

    audio_asset = AudioAsset.find(:first, :conditions=>{ :status => AudioAsset::STATUS_PULLED })
    if audio_asset.nil?
      puts "No new AudioAssets to push"
      return
    end

    puts "Pushing AudioAssets id:#{audio_asset.id}"

    dockey = audio_asset.push()

    if dockey
      puts "Success dockey=#{dockey}"
    else
      puts "Failed"
    end

  end


  desc "Pull new audio files from red5."
  task :pull_new_audio => :environment do

    push_count = AudioAsset.count(:all, :conditions=>{ :status => AudioAsset::STATUS_PULLING })
    if push_count > 4
      puts "There are currently #{push_count} audio files being pulled... let's wait."
      return
    end

    audio_asset = AudioAsset.find(:first, :conditions=>{ :status => AudioAsset::STATUS_NEW })
    if video_user.nil?
      puts "No new AudioAssets to pull"
      return
    end

    puts "Pulling AudioAssets id:#{audio_asset.id}"

    audio_asset.pull()

  end



  
end
