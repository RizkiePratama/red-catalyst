require 'spec_helper'

describe RedCatalystAPI do
    let(:app) {RedCatalystAPI.new}

    context "POST to /whitelist (Allow Client to Play Media)" do
        it "returns status 200 OK if Played from the Host itself" do
            post "/whitelist", { :action => "on_play", :ip => "0.0.0.0" }.to_json , format: :json
            expect(last_response.status).to eq 200
        end

        it "returns status 200 OK if Within Listed IP's" do
            post "/whitelist", { :action => "on_play", :ip => "139.255.75.23" }.to_json , format: :json
            expect(last_response.status).to eq 200
        end
    end
end