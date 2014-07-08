class Billing < ActiveRecord::Base

  belongs_to :user
  has_many :purchases

  def self.new_for_user(user)
    b = Billing.find(:last, :conditions=>{ :user_id => user.id })
    if b.nil?
      b=self.new
      #b.attributes= user.attributes

      copy = {}
      (user.attributes.keys & b.attributes.keys).each() do |k|
      copy[k] = user.attributes[k]
      end

      b.attributes=copy
      b.user = user
    end
    b
  end



  validates_presence_of :firstname
  validates_exclusion_of :firstname, :in => ['First Name'], :message => "can't be blank"

  validates_presence_of :lastname
  validates_exclusion_of :lastname, :in => ['Last Name'], :message => "can't be blank"
  
  validates_presence_of :address1
  #validates_presence_of :address2
  validates_presence_of :city

  belongs_to :state
  validates_presence_of :state


  validates_format_of :zip,
      :with => /^\d\d\d\d\d-?(\d\d\d\d)?$/,
      :message => 'must match 12345 or 12345-1234'







end
