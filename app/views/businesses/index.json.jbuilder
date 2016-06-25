json.array!(@businesses) do |business|
  json.extract! business, :id, :name, :address, :email, :website, :phone, :responsive
  json.url business_url(business, format: :json)
end
