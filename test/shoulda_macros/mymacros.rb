# shoulda validation that a partial has been rendered by a view
#  
class Test::Unit::TestCase
   
  def self.should_render_partial(partial)
    should "render partial #{partial.inspect}" do
      assert_template :partial => partial.to_s
    end
  end
                           
end
