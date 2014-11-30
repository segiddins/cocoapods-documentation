require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Documentation do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ documentation }).should.be.instance_of Command::Documentation
      end
    end
  end
end

