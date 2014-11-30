require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Documentation do
    describe 'CLAide' do
      it 'registers itself' do
        Command.parse(%w{ documentation }).should.be.instance_of Command::Documentation
      end
    end
  end
end
