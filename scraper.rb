require "scraperwiki"
require "json"
require "open-uri"

FETCH_TO_REQUEST_ID = 2246
base_url = "https://www.righttoknow.org.au"

(1..FETCH_TO_REQUEST_ID).each do |id|
  puts "Fetching request ID: #{id}..."

  url = "#{base_url}/request/#{id}.json"
  begin
    request = JSON.parse(open(url).read, symbolize_names: true)
  rescue OpenURI::HTTPError
    puts "Skipping missing request #{url}"
    next
  end

  record = {
    request_url:      "#{base_url}/request/#{request[:url_title]}",
    title:            request[:title],
    created_at:       request[:created_at],
    display_status:   request[:display_status],
    described_state:  request[:described_state],
    user_name:        request[:user][:name],
    user_url:         "#{base_url}/user/#{request[:user][:url_name]}",
    public_body_name: request[:public_body][:name],
    public_body_url:  "#{base_url}/body/#{request[:public_body][:url_name]}",
    public_body_tags: request[:public_body][:tags].collect { |t| t.first }.join(" "),
    response_count:   request[:info_request_events].select { |e| e[:event_type] == "response" }.count
  }

  ScraperWiki.save_sqlite([:request_url], record)
end

puts "Finished."
