class GithubDescriptionHandler
  
  DELIMITER = "--- "
  REGEX = /\n#{DELIMITER}(?>.|\n)*#{DELIMITER}\r?\n/m
  
  #This method appears to block (for how long) for some examples of `from`
  def self.replace_or_append(from, to_insert, regex)
    from += "\n" if from.last != "\n"
    unless from.gsub!(regex, to_insert)
      from += to_insert
    end
    from
  end
  
  def self.github_message(options)
    id = options.delete(:id)
    url = options.delete(:url)
    estimate = options.delete(:estimate)
    message = "\n#{DELIMITER}\n"
    message += "**Pivotal Tracker** - [##{id}](#{url})\n"
    message += "*Estimation*: **#{estimate} points**\n" if !estimate.blank?
    message += eta_string(options)
    message += "\n\n#{DELIMITER}\n"
  end
  
  def self.process_description(options)
    body = options.delete(:body).dup
    gh_message = GithubDescriptionHandler.github_message(options)
    GithubDescriptionHandler.replace_or_append(body, gh_message, REGEX)
  end
  
  def self.eta_string(options)
    pt_current_eta = options.delete(:current)
    pt_previous_eta = options.delete(:previous) 
    display_previous = options.delete(:display_previous) || false 
    message = "*ETA*: **#{pt_current_eta.strftime("#{pt_current_eta.day.ordinalize} %B %Y")}**" if !pt_current_eta.blank?
    message += " (was #{pt_previous_eta.strftime("#{pt_previous_eta.day.ordinalize} %B %Y")})" if display_previous && !pt_previous_eta.blank? && pt_previous_eta != pt_current_eta
    message ||= ""
  end
  
  def self.eta_comment(options)
    icon = options.delete(:icon) || ":checkered_flag:"
    url = options.delete(:url)
    options[:display_previous] = true
    message = "#{icon} *New* #{self.eta_string(options)}\nView in [Pivotal Tracker](#{url})" 
  end
  
end