require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'csv'

class TrelloJob < ActiveJob::Base
  queue_as :default

  def perform
    json = retrieve_json
    filename = "#{Time.now.getutc.to_i.to_s}_trello.csv"
    write_to_csv(json, filename)
    return filename
  end

  private

  def retrieve_json
    url = "https://trello.com/b/nPNSBZjB/trello-resources.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    return JSON.parse(response)
  end

  def write_to_csv(json, filename)
    csv_options = {col_sep: ',', write_headers: false,
      headers: ['source',
        'source_channel',
        'source_agent_id',
        'extraction_time',
        'agent_id',
        'category',
        'time',
        'date',
        'hour',
        'minute']}

    CSV.open(filename, 'w', csv_options) do |csv|
      json['cards'].each do |card|
        source = "trello"
        source_channel = ""
        card_time = card['dateLastActivity'][0...-5]
        time = DateTime.strptime("#{card_time}", '%Y-%m-%dT%H:%M:%S')
        date = time.strftime('%Y%m%d')
        hour = time.strftime('%H')
        minute = time.strftime('%M')
        source_agent_id = card['id']
        extraction_time = Time.now
        agent_id = (0..50).to_a.sample.to_s
        category = "production"
        csv << [source,
        source_channel,
        source_agent_id,
        extraction_time,
        agent_id, category,
        time, date, hour, minute]
      end
    end
  end

end
