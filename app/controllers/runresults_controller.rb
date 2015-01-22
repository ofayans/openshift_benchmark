class RunresultsController < ApplicationController
  before_action :authenticate_user!, :set_run, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  def new
    @runresult = Runresult.new
  end

  def index
    @runresults = Runresults.all
  end
end


