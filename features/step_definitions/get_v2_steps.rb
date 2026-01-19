# frozen_string_literal: true

Given(/^I created an OVH client with my credentials and switched to v2$/) do
  # pending # Write code here that turns the phrase above into concrete actions

  @client = OVHApi::Client.new(application_key: 'app_key', application_secret: 'app_secret',
                               consumer_key: 'consumer_key')
end

When(%r{^I get '/iam/permissionsGroup' with the sdk$}) do
  # pending # Write code here that turns the phrase above into concrete actions
  stub_request(:get, 'https://eu.api.ovh.com/v2/iam/permissionsGroup')
  allow(Time).to receive(:now).and_return(Time.mktime(2010, 10, 8))
  @client.switch_to(:v2)
  @client.get('/iam/permissionsGroup')
end

Then(/^I should have called the v2 base url$/) do
  # pending # Write code here that turns the phrase above into concrete actions
  expect(WebMock).to have_requested(:get, 'https://eu.api.ovh.com/v2/iam/permissionsGroup')
    .with(headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'Host' => 'eu.api.ovh.com',
            'User-Agent' => 'Ruby',
            'X-Ovh-Application' => 'app_key',
            'X-Ovh-Consumer' => 'consumer_key',
            'X-Ovh-Signature' => '$1$1cd4294e08d11cb6150d4610c57e00048d592248',
            'X-Ovh-Timestamp' => '1286488800'
          })
end
