class Resident < ActiveRecord::Base
  has_one :user, dependent: :destroy
  accepts_nested_attributes_for :user
  has_many :assessments, dependent: :destroy
  belongs_to :community
  has_one :assessor, dependent: :destroy  # only if they are an assessor

  validates_presence_of :community
  validates_presence_of :birthdate
  validates_presence_of :gender
  validates :gender, :inclusion => %w(male female)
  #validate :age_range

  def name
    "#{first_name} #{last_name}"
  end

  def assessment_chart_data
    data = {}
    data["columns"] = []
    data["raw"] = {}
    assessments.each do |assessment|
      c = [assessment.date.to_s].concat assessment.percentiles
      data["columns"] << c
      raw_scores = []
      [:chair_stand, :arm_curl, :two_minute_step, :sit_and_reach, :back_scratch, :eight_foot_up_and_go].each do |test|
        raw_scores << assessment.send(test)
      end
      data["raw"][assessment.date.to_s] = raw_scores
    end
    data["tests"] = ['Chair Stand', 'Arm Curl', 'Two-Minute Step', 'Sit & Reach', 'Back Scratch', '8-foot Up & Go']
    return data
  end

  def has_assessments?
    self.assessments.any?
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def age_for_norms
    actual_age = age
    return 94 if actual_age > 94
    return 60 if actual_age < 60
    return actual_age
  end

  def is_assessor?
    assessor.present?
  end

  def is_admin?
    self.admin
  end

  def assessor_for_resident?(other_resident)
    return true if is_admin?
    return false unless is_assessor?
    assessor = self.assessor
    assessor.communities.include? other_resident.community
  end

  def assessor_for_community?(community)
    return true if is_admin?
    return false unless is_assessor?
    assessor = self.assessor
    assessor.communities.include? community
  end

private
  def age_range
    if self.age < 65 || self.age > 94
      errors.add(:birthday, "Must be between 65 and 94 years of age.")
    end
  end
end
