require 'net/http'
require 'rexml/document'

# Function to get URLs from the HTML of a given URL
def get_urls(input_url)
  urls = []
  begin
    url = URI.parse(input_url)
    response = Net::HTTP.get_response(url)

    if response.code == '200'
      regex = Regexp.new(ARGV[0] + /[^"'`<>\\]*/i.source)
      links = response.body.scan(regex)
      links.each do |link|
        urls << link
      end
    else
      puts "HTTP request failed with response code #{response.code}"
    end

  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
  return urls
end

# Function to update the URL hash with new URLs (initializing with false if not already present)
def update_url_hash(urls, url_hash)
  urls.each { |url| url_hash[url] = false unless url_hash.key?(url) }
  return url_hash
end

# Function to generate XML from the URL hash
def generate_xml(url_hash)
  xml = REXML::Document.new
  xml.add_element('urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')

  url_hash.each do |url, _visited|
    url_element = xml.root.add_element('url')
    loc_element = url_element.add_element('loc')
    loc_element.text = url
  end

  formatter = REXML::Formatters::Pretty.new
  formatter.compact = true
  formatter.write(xml, $stdout)
end

def main
  if ARGV[0]
    input_url = ARGV[0]
    unless input_url.start_with?("http") || input_url.start_with?("https")
      input_url = "https://" + input_url
    end

    count = 1
    url_hash = {}
    url_hash[input_url] = true
    # Get URLs for the initial input URL
    initial_urls = get_urls(input_url)
    update_url_hash(initial_urls, url_hash)

    all_visited = false
    while !all_visited
      all_visited = true
      # Collect URLs to be added
      urls_to_add = []
      # Iterate through the URLs in the hash and update it based on new URLs found
      url_hash.each do |url, visited|
        next if visited  # Skip if already visited
        new_urls = get_urls(url)
        urls_to_add.concat(new_urls) unless new_urls.empty?
        url_hash[url] = true  # Mark as visited
      end
      puts "iteration #{count}"
      count += 1
      update_url_hash(urls_to_add, url_hash)
      all_visited = false if !url_hash.values.all?  # Check if all URLs are visited
    end

    # Print the updated URL hash
    # puts "Final URL Hash:"
    # url_hash.each { |url, visited| puts "#{url}: #{visited}" }
    generate_xml(url_hash)
  else
    puts "Run with URL"
  end
end

main()
