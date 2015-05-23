require 'email_spec/cucumber'

def parse_email_count_de(amount)
      case amount
      when "no"
        0
      when "one"
        1
      else
        amount.to_i
      end
    end