class Medal
  module UserMethods
    def self.included(base)
      base.send :include, InstanceMethods

      base.has_many(:user_medals,
                    :class_name  => "Medal::UserMedal",
                    :foreign_key => :user_id)

      UserMedal.belongs_to(:user,
                           :class_name  => base.to_s,
                           :foreign_key => :user_id)
    end

    module InstanceMethods
      def medals
        self.user_medals.where("").map do |user_medal|
          Medal.get(user_medal.medal_name)
        end.sort_by {|medal| medal.name}
      end

      def has_medal?(medal, options = {})
        _medal = medal.is_a?(Medal) ? medal : Medal.get(medal)

        _medal.users(options).include?(self) &&
        self.medals.include?(_medal)
      end
    end
  end
end
