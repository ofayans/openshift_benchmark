json.array!(@rundockerservers) do |rundockerserver|
  json.extract! rundockerserver, :id, :run_id, :dockerserver_id, :image_id, :jobcount
  json.url rundockerserver_url(rundockerserver, format: :json)
end
