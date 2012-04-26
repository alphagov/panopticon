require "test_helper"
require "need_listener"
require "gds_api/needotron"

class NeedListenerTest < ActiveSupport::TestCase
  def mock_messenger
    mock("messenger").tap { |messenger|
      messenger.stubs(:join)
      messenger.stubs(:when)
    }
  end

  test "should update artefact when need is updated" do
    message = {"id" => 1234, "title" => "TITLE"}

    messenger = mock_messenger
    messenger.expects(:when).with("need-o-tron", "needs", "updated").yields(message)

    artefact = Artefact.new
    artefact.expects(:save!)
    Artefact.expects(:find_by_need_id).with(1234).returns(artefact)

    need_data = mock("need_data")
    need_data.stubs(:writing_team).returns(stub(:name => "WRITING TEAM NAME"))
    need_data.stubs(:fact_checkers).returns([
      stub(:fact_checker => stub(:email => "A")),
      stub(:fact_checker => stub(:email => "B"))
    ])

    api = mock("api")
    api.expects(:need_by_id).with(1234).returns(need_data)
    GdsApi::Needotron.expects(:new).returns(api)

    NeedListener.new(messenger, stub_everything).listen

    assert_equal "WRITING TEAM NAME", artefact.department
    assert_equal "A, B", artefact.fact_checkers
  end
end
