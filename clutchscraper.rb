#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'

def scrape_page(page_number = 0)
    base_url = 'https://clutch.co/agencies'
    unless page_number == 0
        url_to_scrape = "#{base_url}?page=#{page_number}"
    else
        url_to_scrape = base_url
    end
    
    doc = Nokogiri::HTML(URI.open(url_to_scrape))
    rows = doc.css('div[data-clutch-nid]')

    website_rows = doc.css('.provider-link-details')
    
    leads = []

    rows.each do |row|
        lead = {
            company_name: row.children[1].children[1].css('h3').inner_text.strip,
            website: row.children[3].css('.website-link')[0].children[1].attributes["href"].value.split("/?").first
        }
        leads << lead
    end

    return leads
end

def export_to_csv(leads)
    file_name = "clutch-scraped-leads-#{(leads.size).to_s}"
    sleep(1)
    puts "All done."

    puts "Saving lead file to exports/#{file_name}.csv"

    CSV.open("./exports/#{file_name}.csv", "ab") do |csv|
        leads.each do |lead|
            csv << [lead[:company_name], lead[:website]]
        end
    end 
end

def run
    puts "Enter the number of agency pages you want to scrape on Clutch.co (max: 500)"
    input = gets.chomp

    leads = [] 

    puts "Preparing to scrape #{input} pages"

    input.to_i.times do |num|
        puts "Scraping Clutch.co Agencies page #{num + 1}"
        leads << scrape_page(num)
        sleep(3)
    end

    leads = leads.flatten
    puts "A total of #{leads.size} leads were scraped."

    export_to_csv(leads)

end

run