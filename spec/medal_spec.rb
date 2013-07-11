require "spec_helper"

describe Medal do
  before do
    stub_const "MEDALS", {
      :NEWBIE => {
        :icon => "newbie.png",
        :name => "newbie",
        :desc => "dummy noooob"
      },
      :GURU => {
        :icon => "guru.png",
        :name => "guru",
        :desc => "awesome guru",
        :after => [:NEWBIE]
      }
    }
  end

  let(:data)     {"Newbie lv.1!"}
  let(:newbie)   {Medal.get(:NEWBIE)}
  let(:guru)     {Medal.get(:GURU)}
  let(:user)     {FactoryGirl.create :user}
  let(:dummy)    {FactoryGirl.create :dummy_model, user: user}
  let(:instance) {user.user_medals.first}

  describe ".get" do
    subject {guru}

    it             {should be_an Medal}
    its(:name)     {should eq "guru"}
    its(:desc)     {should eq "awesome guru"}
    its(:after)    {should eq [newbie]}
    its(:icon_url) {should eq "/assets/medals/guru.png"}
  end

  describe "#users" do
    before  {newbie.give_to(user, data: data, model: dummy)}

    context "without options" do
      subject {newbie.users}

      it {should include user}
    end

    context "with options" do
      context "with matching options" do
        subject {newbie.users data: data, model: dummy}

        it {should include user}
      end

      context "with unmatching options" do
        subject {newbie.users data: "Unmatching!", model: dummy}

        it {should_not include user}
      end
    end
  end

  describe "#give_to" do
    context "when user doesn't meet :after requirements" do
      subject {guru.give_to(user)}

      it {should be false}
    end

    context "when user already have this medal" do
      before  {newbie.give_to(user)}
      subject {newbie.give_to(user)}

      it {user.user_medals.count.should be 1}
      it {should be false}
    end

    context "when user is elegible to get this medal" do
      before  {newbie.give_to(user)}
      subject {guru.give_to(user)}

      it {should be true}
    end

    context "when give a medal with options" do
      subject {newbie.give_to(user, data: data, model: dummy)}

      specify "the created medal has additional infos " do
        subject
        instance.data.should eq data
        instance.model_id.should be dummy.id
        instance.model_type.should eq dummy.class.to_s
      end

      it {should be true}
    end
  end

  describe Medal::UserMethods do
    before do
      newbie.give_to(user)
      guru.give_to(user)
    end

    describe "#medals" do
      subject {user.medals}

      it {should =~ [newbie, guru]}
    end

    describe "#has_medal?" do
      it "without options" do
        user.has_medal?(guru).should be true
      end

      it "with options" do
        newbie.give_to(user, data: data, model: dummy)
        user.has_medal?(newbie, data: data, model: dummy).should be true
      end
    end
  end

  describe Medal::ModelMethods do
    context "when after model creation" do
      it {expect {dummy}.to change {user.user_medals.count}.by(1)}
    end

    context "when after model update" do
      before {dummy}

      it {
        expect {
          dummy.dummy = true
          dummy.save
        }.to change {user.user_medals.count}.from(1).to(2)
      }
    end
  end
end
