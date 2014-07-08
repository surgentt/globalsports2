namespace :gs do

  desc "Reload active series from V4E"
  task :series_update => :environment do
    Series.active.each do |s| s.pull; end
  end

end
