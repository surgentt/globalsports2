require 'activesupport'


class PurchasesController < BaseController

  before_filter :admin_required, :only => [:show, :edit, :update]
  skip_before_filter :gs_login_required, :except => [:buy, :create, :destroy]


  def buy
    @code= params[:code]
    @purchase= Purchase.new()
    @purchase.user= current_user
    @purchase.buy(@code)
    @purchase.save

    redirect_to :action => :index

  end

  def checkout
      logger.info "DVDCHECKOUT *** "

    @purchases = Purchase.shopping_cart(current_user)
    @billing = Billing.new(params[:billing])
    @billing.user = current_user

      logger.debug "DVDCHECKOUT * #{@billing.user.full_name}"
    begin

#      #@user = current_user
#      #TODO update address if needed
#      if ! current_user.update_attributes(params[:user])
#        raise ActiveRecord::RecordInvalid.new(current_user)
#      end



      @credit_card = ActiveMerchant::Billing::CreditCard.new(params[:credit_card])
      
      @credit_card.first_name = @billing.firstname
      @credit_card.last_name = @billing.lastname

      if (!@credit_card.valid?)
        @credit_card.errors.add_to_base("Card information is not valid.")
        raise ActiveRecord::RecordInvalid.new(@credit_card)
      end


      gateway = Purchase.billing_gateway

      cost_for_gateway = @purchases.collect(&:cost).sum + Purchase::COST_SHIPPING

      logger.info "DVDCHECKOUT * #{@billing.user.full_name} at #{cost_for_gateway}"

      @response = gateway.purchase(cost_for_gateway, @credit_card, {:description=>"DVD Purchase for User ID: #{@billing.user.id}, $#{'%.2f' % (cost_for_gateway / 100.0)}.  #{@billing.id}"})


      logger.info "DVDCHECKOUT * Response from gateway #{@response.inspect} for #{@billing.user.full_name} at #{@cost}"

      if (!@response.success?)
        logger.info "DVDCHECKOUT * Gatway response failed"

        if @response.nil? || @response.message.nil? || @response.message.blank?
          flash.now[:error] = "Sorry, we are having technical difficulties contacting our payment gateway. Try again in a few minutes."
        else
          flash.now[:error] = @response.message
        end

        @credit_card.errors.add_to_base(@response.message)

        raise ActiveRecord::RecordInvalid.new(@credit_card)
      end


      logger.info "DVDCHECKOUT * Gatway response is success"

      #credit_card_for_db = CreditCard.from_active_merchant_cc(@credit_card)
      #credit_card_for_db.user = @user
      #credit_card_for_db.save!


      @billing.transaction_info= @response.message
      @billing.save!

      @billing.last_four= @credit_card.number[-4,4]

      @purchases.each() do |p|
        p.billing = @billing
        p.save
      end

      @billing.save!


      UserNotifier.deliver_billing_notice(@billing)


      redirect_to :action => :thanks

    rescue ActiveRecord::RecordInvalid
      #    flash.now[:error] = 'ack!'
      @credit_card.month = params[:credit_card][:month]
      @credit_card.year = params[:credit_card][:year]
      render :action => :index
    rescue ActiveRecord::StatementInvalid
      @credit_card.month = params[:credit_card][:month]
      @credit_card.year = params[:credit_card][:year]
      #    flash.now[:error] = 'bzam!'
      render :action => :index
    rescue Exception => e
      flash.now[:error] = "Trouble completing this transaction: #{e.message}"
      logger.warn(e)
      logger.info e.backtrace.join("\n")

      @credit_card.month = params[:credit_card][:month]
      @credit_card.year = params[:credit_card][:year]
      render :action => :index
    end

  end

  def thanks
    @billing = Billing.find(:last, :conditions=>{ :user_id => current_user.id })
  end


  def index
    if current_user.admin?
      @purchases = Purchase.paginate(:all, { :order => 'id desc', :page => params[:page] })
    else
      @purchases = Purchase.shopping_cart(current_user).paginate(:all, { :order => 'id desc', :page => params[:page] })
    end

    @credit_card = ActiveMerchant::Billing::CreditCard.new()
    @billing = Billing.new_for_user(current_user)
  end

#  def get_purchases
#
#    options = {
#        :order => 'id desc',
#        :page => params[:page]
#        }
##    options[:conditions]= { :user_id => current_user.id } if !current_user.admin?
#
#    @purchases = Purchase.active.for_user(current_user).paginate(:all, options)
#
#  end




  def show
    @purchase = Purchase.find(params[:id])
  end

  def new
    @purchase = Purchase.new
  end

  def edit
    @purchase = Purchase.find(params[:id])
  end

  def create
    @purchase = Purchase.new(params[:purchase])

    if @purchase.save
      render :action => 'thanks'
    else
      render :action => 'new'
    end

  end

  def update
    @purchase = Purchase.find(params[:id])

    if @purchase.update_attributes(params[:purchase])
      render :action => :index
    else
      render :action => 'edit'
    end

  end

  def destroy
    @purchase = Purchase.find(params[:id])

    @purchase.destroy if( @purchase.user == current_user || current_user.admin? )

    redirect_to(purchases_url)

#    render :update do |page|
#      target = "purchase_#{@purchase.id}"
#      page.replace_html target, :text => ''
#    end

  end











end
