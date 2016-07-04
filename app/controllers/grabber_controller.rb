class GrabberController < ApplicationController 
  def add_business
    pages = params[:pages].to_i
    region = params[:region]
    locality = params[:locality]

    require 'factual'
    factual = Factual.new("WevzSzGmAiUz27P0yi5Wak1c2EGWeaVT076pTiEp","hnd5j1bxG8VYMDlqZs3dSBvkIc8U47FbB56fVp1p")

    (0..pages).each do |current_page|

      directory = factual.table("places-us").search("").filters("$and" => [{"locality" => {"$eq" =>  locality}}, {"region" => {"$eq" => region}}]).page(current_page, :per => 50).rows
      (0..49).each do |x|
        business = Business.create(:name => directory[x]["name"],
                       :address => directory[x]["address"],
                       :email => directory[x]["email"],
                       :phone => directory[x]["tel"], 
                       :website => directory[x]["website"])
      end
    end
    redirect_to :back
  end
end