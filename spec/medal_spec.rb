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
  let(:newbie) {Medal.get(:NEWBIE)}
  let(:guru)   {Medal.get(:GURU)}
  let(:user)   {FactoryGirl.create :user}

  describe ".get" do
    subject {guru}

    it             {should be_an Medal}
    its(:name)     {should eq "guru"}
    its(:desc)     {should eq "awesome guru"}
    its(:after)    {should eq [newbie]}
    its(:icon_url) {should eq "/assets/medals/guru.png"}
  end

  describe "#give_to" do
    context "when user doesn't meet :after requirements" do
      subject {guru.give_to(user)}

      it {should be false}
    end

    context "when user already have this medal" do
      before {newbie.give_to(user)}
      subject {newbie.give_to(user)}

      it {user.user_medals.count.should be 1}
      it {should be false}
    end

    context "when user is elegible to get this medal" do
      before {newbie.give_to(user)}
      subject {guru.give_to(user)}

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
      subject {user.has_medal?(guru)}

      it {should be true}
    end
  end

  describe Medal::ModelMethods do
    let(:dummy)  {FactoryGirl.create :dummy_model, :user => user}

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
