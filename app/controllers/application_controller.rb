class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  allow_browser versions: :modern
  before_action do
    I18n.locale = :fr
  end
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
