# -*- coding: utf-8 -*-
class Medal
  class UserMedal < ActiveRecord::Base
    attr_accessible :medal_name, :user
    default_scope :order => 'id desc'

    validates :user_id, :medal_name, :presence => true
    validates :medal_name, :uniqueness => {:scope => :user_id}

    validate do
      errors.add(:base, "用户不符合前置奖牌要求") if !have_after_medals?
    end

    def medal
      @medal ||= Medal.get(medal_name)
    end

    def have_after_medals?
      medals = user.medals
      afters = medal.after

      (medals & afters) == afters
    end
  end
end
