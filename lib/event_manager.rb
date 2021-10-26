require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'


puts "Event Manager Initialized!"

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def legislator_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thankyou_letter(id,form)
    Dir.mkdir('output') unless Dir.exist?('output')
    filename="output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form
    end
end

def clean_phone(phone)
    phone.gsub!(/[^0-9]/, '')
    if phone.length==10
        phone
    elsif phone.length==11 && phone[0]=="1"
        phone[1..9]
    else
        "invalid number"
    end
end
def clean_time(regDate) #Month Day Year hour min "%m/%d/%Y/ %k/%M"
    Time.strptime(regDate,"%m/%d/%Y %k:%M")
end
def clean_date(regDate)
    Date.strptime(regDate,"%m/%d/%Y %k:%M")
end

def pop_hour(time,hours)
    if !hours[time.hour]
        hours[time.hour]=1
    else
        hours[time.hour]+=1
    end
end
def pop_days(time,days)
    if !days[time.wday]
        days[time.wday]=1
    else
        days[time.wday]+=1
    end
end
contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template=ERB.new template_letter
hours={}
days={}
contents.each do |line|
    phone=clean_phone(line[:homephone])
    id=line[0]
    name=line[:first_name]
    zipcode=clean_zipcode(line[:zipcode])
    
    reg_date=line[:regdate]

    time=clean_time(reg_date)
    date=clean_date(reg_date)
    pop_hour(time,hours)
    pop_days(date,days)

    #puts "#{name} #{id} #{zipcode} #{phone} #{time}"
    puts "#{name} #{time}"
    #legislators=legislator_by_zipcode(zipcode)

    #form_letter=erb_template.result(binding)
    #save_thankyou_letter(id,form_letter)
end
p hours
p days


