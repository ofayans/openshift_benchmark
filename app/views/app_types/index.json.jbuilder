json.array!(@app_types) do |app_type|
  json.extract! app_type, :id, :name
  json.url app_type_url(app_type, format: :json)
end
