json.array!(@gear_profiles) do |gear_profile|
  json.extract! gear_profile, :id, :name
  json.url gear_profile_url(gear_profile, format: :json)
end
