json.array!(@addons) do |addon|
  json.extract! addon, :id, :name, :references
  json.url addon_url(addon, format: :json)
end
