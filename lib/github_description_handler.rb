class GithubDescriptionHandler
  
  DELIMITER = "--- "
  
  #This method appears to block (for how long) for some examples of `from`
  def self.replace_or_append(from, to_insert, regex)
    unless from.gsub!(regex, to_insert)
      from += to_insert
    end
    from
  end
  
  def self.github_message(story)
    message = "\n#{TOKEN}\n"
    message += "**Pivotal Tracker** - [##{story.id}](#{story.url})\n"
    message += "*Estimation*: **#{story.estimate} points**\n" if !story.estimate.blank?
    message += eta_string
    message += "\n\n#{TOKEN}\n"
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
    message = "#{icon} *New* #{self.eta_string(options)}\nView in [Pivotal Tracker](#{url})" 
  end
  
end