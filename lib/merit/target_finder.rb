module Merit
  class TargetFinder < Struct.new(:rule, :action)
    def self.find(*args)
      self.new(*args).find
    end

    def find
      target = case rule.to
               when :itself; base_target
               when :action_user; action_user
               else; other_target
               end
      Array.wrap(target)
    end

    private

    def base_target
      BaseTargetFinder.find rule, action
    end

    def action_user
      user = Merit.user_model.find_by_id action.user_id
      if user.nil?
        user_model = Merit.user_model
        message = "[merit] no #{user_model} found with id #{action.user_id}"
        Rails.logger.warn message
      end
      user
    end

    def other_target
      base_target.send rule.to
    rescue NoMethodError
      message = "[merit] NoMethodError on"
      message << " `#{base_target.class.name}##{rule.to}`"
      message << " (called from Merit::TargetFinder#other_target)"
      Rails.logger.warn message
    end

  end
end
