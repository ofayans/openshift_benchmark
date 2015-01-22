class Run < ActiveRecord::Base

  class ValidateSpecificFields < ActiveModel::Validator
    def validate(record)
      product = Product.find_by(:id => record.product_id).name
      if product =~ /openshift/
        ["broker", "login", "password"].each do |elem|
          if record[elem].blank?
            record.errors[:name] << "For openshift the field #{elem} is required"
          end
        end
      elsif product =~ /heroku/
        if record.from_code.blank?
          record.errors[:name] << "We only suppport creating heroku apps from a pre-existing git repo. So, field from_code is required"
        end
      end
    end
  end
  belongs_to :gear_profile
  belongs_to :app_type
  belongs_to :addon
  has_many :rundockerservers
  validates_with ValidateSpecificFields
  validates :requestcount, :concurrency, presence: true
  accepts_nested_attributes_for :rundockerservers
end
