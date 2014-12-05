require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SolverHelper. For example:
#
# describe SolverHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SolverHelper, :type => :helper do
  describe "inverting a matrix" do
    let(:x) { Matrix[[1,2],[3,4]] }
    it "works" do
      expect(helper.inv(x) * x).to eq Matrix[[1,0],[0,1]]
    end
    describe "logs inverting" do
      it "logs successfull inverting" do
        expect(Rails.logger).to receive(:info)
        expect(Rails.logger).not_to receive(:fatal)
        helper.inv(x)
      end
      it "logs unsuccessfull inverting" do
        expect(Rails.logger).not_to receive(:info)
        expect(Rails.logger).to receive(:fatal)
        helper.inv(nil)
      end
    end
  end

  describe "integrating" do
    let(:func) { lambda { |x| x*x } }
    let(:eps) { 1e-5 }
    it "works" do
      expect((9 - helper.integrate(0,3,&func)).abs < eps).to be(true)
    end
  end
end
