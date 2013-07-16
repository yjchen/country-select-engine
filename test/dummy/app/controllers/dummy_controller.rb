class DummyController < ApplicationController
  def index
    @selected = User.new
    @selected.country = 'US'
  end
end
