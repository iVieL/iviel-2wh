class MoviesController < ApplicationController

  def initialize
    @all_ratings = ['G','PG','PG-13','R']
    super
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
                            # will render app/views/movies/show.<extension> by default
  end

  def index
    #puts "===> SESSION #{session}"
    #puts "===> COOKIES: saved [#{cookies[:saved]}]"
    #puts "===> PARAMS: [#{params[:ratings]}]"
    hash = {}
    #if session[:check].nil?
    #  begin
    #    hash = eval(cookies[:saved])
    #    rescue
    #    # nothing to do
    #  end
    #  session[:ratings] = hash[:ratings] if !hash[:ratings].nil?
    #  session[:order] = hash[:order] if !hash[:order].nil?
    #
    #  session[:check] = params[:check]
    #end

    #todo: al cambiar los valores de los filtros, le pelan
    #debugger
    # session validation
    redirect = false
    if !params[:ratings].nil?
      session.delete(:ratings) # will be replace
      cookies.delete(:saved, :value => :ratings)
    elsif !session[:ratings].nil?
      params[:ratings] = session[:ratings] # restore session values
      redirect = true
    end
    if !params[:order].nil?
      session.delete(:order)
      cookies.delete(:saved, :value => :order)
    elsif !session[:order].nil?
      params[:order] = session[:order] # restore session values
      redirect = true
    end

    redirect_to movies_path({:order => params[:order], :ratings => params[:ratings], :check => params[:check]}) if redirect

    where = []
    @ratingHash = params[:ratings]
    @ratingHash.each do |key, value|
      where << key
    end if !@ratingHash.nil?

    @sort = params[:order]

    str = "Movie."
    if !params[:order].nil? and params[:order].length > 0
      str += "order(params[:order])."
      hash[:order] = params[:order]
      #cookies[:saved] = {:value => hash, :expires => 1.year.from_now}
      session[:order] = params[:order]
    end
    if where.length > 0
      str += "where(:rating => #{where})."
      hash[:ratings] = params[:ratings]
      #cookies[:saved] = {:value => hash, :expires => 1.year.from_now}
      session[:ratings] = params[:ratings]
    end
    str += "all"

    #puts "to_eval: #{str} --- #{params[:order]}"
    @movies =eval(str)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def method_missing(method, *args)
    puts "Method Missing #{method}"
  end

  def search_tmdb
    # hardwire to simulate failure
    #flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
    #redirect_to movies_path
    @movies = Movie.find_in_tmdb(params[:search_terms])
  end

end
