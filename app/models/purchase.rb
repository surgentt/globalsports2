require 'base64'

class Purchase < ActiveRecord::Base

  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :billing

  named_scope :for_user, lambda {
    |user|
    if !user.admin?
      {:conditions=>{ :user_id => user.id} } 
    else
      {}
    end
  }

  named_scope :active, lambda {
    |active|
    if active || active.nil? # default positive
      {:conditions=>{ :billing_id => nil} }
    else
      {:conditions=>'billing_id is not null' }
    end
  }


  STATUS_CART = 1

  COST_DVD = 2000

  COST_SHIPPING = 500
  

  def self.url_to_buy(item)
    "/purchases/buy/#{CGI.escape(item_code(item))}"
  end

  def self.item_code(item)
    Base64.encode64 "#{item.class.name}/#{item.id}"
  end

  def buy(item_code)
    (self.item_type, self.item_id) = Base64.decode64(item_code).split('/')
    self.description = self.item.title
    self.cost = COST_DVD
    self.paid = false
    self.status = STATUS_CART
  end

  def self.shopping_cart(user)
    self.active.for_user(user)
  end


  
  def self.billing_gateway
    ActiveMerchant::Billing::PayflowGateway.new(
      :login => Active_Merchant_payflow_gateway_username,
      :password => Active_Merchant_payflow_gateway_password,
      :partner => Active_Merchant_payflow_gateway_partner
    )
  end


end
