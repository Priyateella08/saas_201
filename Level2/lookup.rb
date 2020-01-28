def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument
# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  record_array = []
  dns_raw.reject { |row| row.empty? }.reject { |row| row[0] == "#" }.each do |row|
    column = row.split(",")
    record_array.push(column)
  end
  dns_records = {}
  record_array.each do |column|
    record_key = (column[0].to_s).strip
    domain_key = (column[1].to_s).strip
    dns_records[domain_key] = { :type => record_key, :val => (column[2].to_s).strip }
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  lookup_result = dns_records[domain]
  if (lookup_result = nil)
    lookup_chain = ["Error: record not found for #{domain}"]
  else
    lookup_chain.push lookup_result[:val]
    lookup_chain = resolve(dns_records, lookup_chain, lookup_result[:val]) if lookup_result[:type == "CNAME"]
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
