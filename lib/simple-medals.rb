require 'active_record'

class Medal
  attr_reader :medal_name, :name, :desc, :icon

  def initialize(medal_name)
    @medal_name = medal_name.to_sym
    MEDALS[medal_name.to_sym].each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def after
    (@after || []).map {|name| self.class.get(name)}.sort_by {|medal| medal.name}
  end

  def icon_url
    "/assets/medals/#{icon}"
  end

  def give_to(user, options = {})
    instance = UserMedal.new(:medal_name => self.medal_name, :user => user)
    instance.data  = options[:data]  if options[:data]
    instance.model = options[:model] if options[:model]
    instance.save
  end

  def query_options(options)
    query = options.to_a.map do |pair|
      if pair[0] == :model
        [:model_id, pair[1].id, :model_type, pair[1].class.to_s]
      else
        pair
      end
    end.flatten.concat [:medal_name, medal_name]

    Hash[*query]
  end

  def users(options = {})
    User.joins(:user_medals).where(:user_medals => query_options(options))
  end

  def set_shown(user)
    update_shown_status(user, true)
  end

  def cancel_shown(user)
    update_shown_status(user, false)
  end

  def self.get(medal_name)
    instances[medal_name.to_sym]
  end

  def self.instances
    @instances ||= ::MEDALS.reduce({}) do |acc, (medal_name, _)|
      acc[medal_name] = Medal.new(medal_name)
      acc
    end
  end

private

  def update_shown_status(user, value)
    return false if !eligible_to_update_shown_status?(user, value)
    get_user_medal(user).update_attributes(:is_shown => value)
  end

  def eligible_to_update_shown_status?(user, value)
    user.send (value ? :has_medal? : :has_shown_medal?), self
  end

  def get_user_medal(user)
    user.user_medals.where(:medal_name => self.medal_name).first
  end
end

require 'simple-medals/model_methods'
require 'simple-medals/user_medals'
require 'simple-medals/user_methods'
