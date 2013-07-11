# -*- coding: utf-8 -*-
class Medal
  class UserMedal < ActiveRecord::Base
    attr_accessible :medal_name, :user, :data, :model
    default_scope :order => 'id desc'

    validates :user_id, :medal_name, :presence => true
    validates :medal_name, :uniqueness => {
      :scope => [:user_id, :data, :model_id, :model_type]
    }

    validate do
      errors.add(:base, "用户不符合前置奖牌要求") if !have_after_medals?
    end

    def self.query_options(options)
      query = options.to_a.map do |pair|
        if pair[0] == :model
          [:model_id, pair[1].id, :model_type, pair[1].class.to_s]
        else
          pair
        end
      end.flatten.concat [:medal_name, medal_name]

      Hash[*query]
    end

    def model
      return if !(model_id && model_type)
      return @model if @model
      model_type.constantize.find(model_id)
    end

    def model=(obj)
      return if !obj
      self.model_type = obj.class.to_s
      self.model_id   = obj.id
      @model = obj
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
