class Business < ActiveRecord::Base
	def self.to_csv
		attributes = %w{id name address email website phone responsive}
		CSV.generate(headers: true) do |csv|
			csv << attributes

			all.each do |business|
				csv << business.attributes.values_at(*attributes)
			end
		end
	end
end
