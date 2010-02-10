class ClientGroup
  include DataMapper::Resource
  before :valid?, :add_created_by_staff_member
  
  property :id,                Serial
  property :name,              String, :nullable => false
  property :number_of_members, Integer, :nullable => true, :min => 1, :max => 20, :default => 5
  property :code,              String, :length => 14, :nullable => false, :index => true
  property :created_by_staff_member_id,  Integer, :nullable => false, :index => true

  validates_is_unique   :code, :scope => :center_id
  validates_length      :code, :min => 1, :max => 14

  has n, :clients
  belongs_to :center
  belongs_to :created_by_staff,  :child_key => [:created_by_staff_member_id], :model => 'StaffMember'
  validates_is_unique :name, :scope => :center_id  

  def self.from_csv(row, headers)
    center = Center.first(:code => row[headers[:center_code]])
    obj    = new(:name => row[headers[:name]], :center_id => center.id, :code => row[headers[:code]])
    [obj.save, obj]
  end

  def self.search(q)
    if /^\d+$/.match(q)
      all(:conditions => ["id = ? or code=?", q, q])
    else
      all(:conditions => ["code=? or name like ?", q, q+'%'])
    end
  end

  def add_created_by_staff_member
    if self.center and self.new?
      self.created_by_staff_member_id = self.center.manager_staff_id
    end
  end
end
