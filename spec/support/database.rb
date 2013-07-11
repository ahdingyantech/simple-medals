require 'generators/templates/migration'

ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table :users unless table_exists?(:users)

  create_table :dummy_models, :force => true do |t|
    t.integer :user_id
    t.boolean :dummy, :default => false
  end unless table_exists?(:dummy_models)
end

SetupSimpleMedals.migrate(:up)

class DummyModel < ActiveRecord::Base
  include Medal::ModelMethods

  belongs_to :user

  give_medal(:NEWBIE,
             :on   => :create,
             :user => lambda {|model| model.user},
             :if   => lambda {|model, user| true})

  give_medal(:GURU,
             :on   => :update,
             :user => lambda {|model| model.user},
             :if   => lambda {|model, user| model.dummy})
end

class User < ActiveRecord::Base
  include Medal::UserMethods

  has_one :dummy_model
end
