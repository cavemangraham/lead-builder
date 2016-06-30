require 'rake'
require 'httparty'
namespace :grabber do
	task :businesses, [:region, :locality] => [:environment] do |t, args|
		args.with_defaults(:region => "NJ", :locality => "newark")
		require 'factual'
		factual = Factual.new("WevzSzGmAiUz27P0yi5Wak1c2EGWeaVT076pTiEp","hnd5j1bxG8VYMDlqZs3dSBvkIc8U47FbB56fVp1p")

		directory_size = factual.facets("places-us").select("locality").filters("$and" => [{"region" => {"$eq" => args[:region]}}, {"locality" => {"$eq" => args[:locality]}}]).columns
		directory_size["locality"][args[:locality]]
		p "#{directory_size}"

		(0..10).each do |current_page|

			directory = factual.table("places-us").search("").filters("$and" => [{"locality" => {"$eq" =>  args[:locality]}}, {"region" => {"$eq" => args[:region]}}]).page(current_page, :per => 50).rows
			(0..49).each do |x|
				business = Business.create(:name => directory[x]["name"],
										   :address => directory[x]["address"],
										   :email => directory[x]["email"],
										   :phone => directory[x]["tel"], 
										   :website => directory[x]["website"])
				p "Grabbed - #{business.name}"
			end
		end
	end
	task responsive: [:environment] do
		Business.all.each do |business|
			if business.website.present? and business.responsive.blank?
				begin
				response = HTTParty.get('http://tools.mercenie.com/responsive-check/api/?format=json&url=' + business.website, timeout: 3)
				rescue Net::ReadTimeout, Net::OpenTimeout
					response = {"responsive" => "error"}
				end

				p "#{business.name}"
				p "#{response}"
				if response["responsive"].include? "true" or response["responsive"].include? "false"
					business.responsive = response["responsive"]
					business.save
					p "#{business.name} - #{business.responsive}"
				elsif response["responsive"].include? "error" or response.include? "Warning"
					business.responsive = "error"
					business.save
					p "#{business.name} - #{business.responsive}"
				end
			end
		end
	end
	task speed: [:environment] do
		Business.all.each do |business|
			if business.website.present? and business.speed.blank? and business.responsive = "false"
				p "#{business.name}"
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
				p "#{business.name}"
				p "#{business.speed} - #{business.usability}"
			end
		end
	end
end