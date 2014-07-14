# This model represents SCIM groups. These groups show up as the list of
# authorities that an Identity has, and in turn affects what scopes they
# may be granted on oauth2 tokens.
class Group < ActiveRecord::Base
  has_and_belongs_to_many :identities, :uniq => true
  has_and_belongs_to_many :groups,
    :foreign_key => "group_a_id",
    :association_foreign_key => "group_b_id",
    :before_add => :no_circular_groups,
    :uniq => true
  has_and_belongs_to_many :parent_groups,
    :join_table => "groups_groups",
    :class_name => "Group",
    :foreign_key => "group_b_id",
    :association_foreign_key => "group_a_id",
    :uniq => true
  before_validation do
    self.guid ||= SecureRandom.uuid
  end

  self.locking_column = :version

  validates :name,
    :uniqueness => { :case_sensitive => false },
    :length => { :maximum => 255 },
    :presence => true

  validates :guid,
    :uniqueness => { :case_sensitive => true },
    :length => { :maximum => 255 },
    :presence => true

  def no_circular_groups(gs, seen={})
    if gs.kind_of? Group
      seen[guid] = true
      seen[gs.guid] = true
      gs = gs.groups
    end
    gs.uniq!
    gs.each do |g|
      if seen[g.guid]
        raise ActiveRecord::RecordInvalid.new(
          "Groups can't have circular references. Group #{g.guid} already seen.")
        break
      end
      seen[g.guid] = true
      no_circular_groups(g.groups, seen)
    end
  end

end
