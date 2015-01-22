json.array!(@images) do |image|
  json.extract! image, :id, :tag
end
