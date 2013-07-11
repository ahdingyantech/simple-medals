# Simple Modal
____

## 安装

```bash
$ rails g simple_medals
$ rake db:migrate
```

## 配置

按照下边格式添加rails initializer

```ruby
MEDALS = {
  :NEWBIE => {
    :icon => 'xxxxxx.png',
    :name => 'xxxxxxxx',
    :desc => 'xxxxxxx',
    :after => [:AAA, :BBB]
  }
}
```

## 使用

```ruby
# 设置

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

# 调用

user = User.create
dummy = DummyModel.create :user => user

model.give_to(user, options = {})

# 使用方法，options里面可以选择性地传两个参数
medal.give_to(user, { :data => '', :model => dummy } )
=> true

# -------------------------

# 查找拥有指定奖牌的用户，此查询可分页
medal.users(options = {})

# 使用方法，options里面可以选择性地传两个参数
medal.users({ :data => '', :model => dummy })
=> users

# --------------------------------
# 查询用户是否拥有指定的奖牌
user.has_medal?(medal_name_or_medal, options = {}) # 参数可以传奖牌实例或奖牌名称标识
=> true
```
