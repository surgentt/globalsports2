
require 'open-uri'

module SharedItem

  def share!
    unless self.shared_access_id
      shared_access = SharedAccess.new
      shared_access.item= self
      logger.debug "New shared access for item_id #{shared_access.item_id}"
      shared_access.save!
      logger.debug "Saved new shared access for item_id #{shared_access.item_id}, new id #{shared_access.id}"
      self.update_attribute :shared_access_id, shared_access.id
      self.shared_access_id= shared_access.id
    end
    self.shared_access_id
  end

  def share_url
    share!
    "#{APP_URL}/shared_access/show?key=#{shared_access.key}"
  end

  def fb_update
    url ="https://api.facebook.com/method/fql.query?query=SELECT+share_count%2C+like_count%2C+comment_count%2C+total_count+FROM+link_stat+WHERE+url+%3D+%22#{share_url()}%22"

    doc = open(url) { |f| Hpricot(f) }
    puts '!!!'
    puts '!! '+(doc/'like_count').inner_html
    puts '!! '+(doc/'share_count').inner_html
    shared_access.fb_like = (doc/'like_count').inner_html
    shared_access.fb_share = (doc/'share_count').inner_html
    shared_access.save
    puts shared_access.inspect
    puts '!!!'
  end

end

