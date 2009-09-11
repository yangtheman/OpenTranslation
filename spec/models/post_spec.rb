require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  before(:each) do
    @valid_attributes = {
      :url => 'http://yang.com' 
    }
  end
  
  it "should create a new instance given valid attributes" do
    Post.create!(@valid_attributes)
  end
  
  describe "validations" do
    describe "good urls" do
      it "should allow real urls" do
        lambda { Post.create!( :url => 'http://yang.com' ) }.should_not raise_error
      end
    end    
    describe "bad urls" do
      it "should choke on urls with no domain" do
        lambda { Post.create!( :url => 'bunk'           ) }.should raise_error( /Url is invalid/ )
      end
      it "should choke on malformed urls" do
        lambda { Post.create!( :url => 'httttttp://yang.com' ) }.should raise_error( /Url is invalid/ )
        lambda { Post.create!( :url => 'http://yang~.com' )    }.should raise_error( /Url is invalid/ )
      end
      it "should choke on malformed urls" do
        lambda { Post.create!( :url => 'httpXXXX' ) }.should raise_error( /Url is invalid/ )
      end
      it "should choke on malformed urls" do
        lambda { Post.create!( :url => 'http://yangcom' ) }.should raise_error( /Url is invalid/ )
      end
    end    
  end  
end
