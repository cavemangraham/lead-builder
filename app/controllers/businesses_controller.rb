class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = Business.all

    respond_to do |format|
      format.html
      format.csv { send_data @businesses.to_csv, filename: 'Business_List.csv' }
    end
  end

  def filter
    @businesses = Business.where("responsive LIKE ?", "false")
    respond_to do |format|
      format.html
      format.csv { send_data @businesses.to_csv, filename: 'Responsive_Business_List.csv' }
    end
  end

  def responsive
    Business.all.each do |business|
      if business.website.present? and business.responsive.blank?
        begin
        response = HTTParty.get('http://tools.mercenie.com/responsive-check/api/?format=json&url=' + business.website, timeout: 3)
        rescue Net::ReadTimeout, Net::OpenTimeout
          response = {"responsive" => "error"}
        end
        if response["responsive"].include? "true" or response["responsive"].include? "false"
          business.responsive = response["responsive"]
          business.save
        elsif response["responsive"].include? "error" or response.include? "Warning"
          business.responsive = "error"
          business.save
        end
      end
    end
  end

  def speed
    Business.all.each do |business|
      if business.website.present? and business.responsive == "false" and business.speed.blank?
        begin
        response = HTTParty.get('https://www.googleapis.com/pagespeedonline/v2/runPagespeed?url=' + business.website + '&strategy=mobile&key=AIzaSyADhL5TjHi35A-DKbnRR8epPaPwhX5poDw')
        rescue Net::ReadTimeout, Net::OpenTimeout
          response = {"ruleGroups" => {"SPEED" => "101" , "USABILITY" => "101"}}
        end
        if response.include? "error"
          response = {"ruleGroups" => {"SPEED" => {"score" => "101"}  , "USABILITY" => {"score" => "101"}}}
        end
        business.speed = response["ruleGroups"]["SPEED"]["score"].to_i
        business.usability = response["ruleGroups"]["USABILITY"]["score"].to_i
        business.save
      end
    end
  end

  def remove_all
    @businesses = Business.all
    @businesses.each do |business|
      business.destroy
    end
    flash[:notice] = "All businesses have been deleted."
    redirect_to businesses_url
  end


  # GET /businesses/1
  # GET /businesses/1.json
  def show
  end

  # GET /businesses/new
  def new
    @business = Business.new
  end

  # GET /businesses/1/edit
  def edit
  end

  # POST /businesses
  # POST /businesses.json
  def create
    @business = Business.new(business_params)

    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: 'Business was successfully created.' }
        format.json { render :show, status: :created, location: @business }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to @business, notice: 'Business was successfully updated.' }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url, notice: 'Business was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business
      @business = Business.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_params
      params.require(:business).permit(:name, :address, :email, :website, :phone, :responsive)
    end
end
