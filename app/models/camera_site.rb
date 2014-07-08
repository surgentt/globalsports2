class CameraSite < ActiveRecord::Base


  belongs_to :state

  validates_presence_of :league_name
  validates_presence_of :contact_name
  validates_presence_of :contact_phone
  validates_presence_of :contact_email
  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :zip

  
end