class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Código para obtener el array @all_ratings de la base de datos
    @movies = Movie.where(rating: session[:ratings].keys).order(session[:order]) || Movie.all
    @all_ratings = Movie.pluck(:rating).uniq
    # @checks = ['checked']*@all_ratings.size
    @hilite_title = 'hilite' if session[:order] == 'title' 
    @hilite_release = 'hilite' if session[:order] == 'release_date'
    
    @checks2 = []
    @all_ratings.each do |rating|
      if session[:ratings].keys.include?(rating)
        @checks2 << 'checked'
      else
        @checks2 << nil
      end  
    end
    @checks = @checks2 || ['checked']*@all_ratings.size        
    
    if params[:ratings]
      @hilite_title = 'hilite' if session[:order] == 'title'
      @hilite_release = 'hilite' if session[:order] == 'release_date'
      session[:ratings] = params[:ratings]
      @checked_ratings = params[:ratings].keys
      @movies = Movie.where(rating: @checked_ratings).order(session[:order])
      
      @checks = []
      @all_ratings.each do |rating|
        if @checked_ratings.include?(rating)
          @checks << 'checked'
        else
          @checks << nil
        end  
      end
      session[:checks]=@checks
    end
    
    # Código para ordenar por título y por fecha de estreno
    if params[:order] == "title"
      session[:order] = 'title'
      @movies = Movie.where(rating: session[:ratings].keys).order("lower(title)") || Movie.order("lower(title)")
      @hilite_title = 'hilite'
    elsif params[:order] == "release_date"
      session[:order] = 'release_date'
      @movies = Movie.where(rating: session[:ratings].keys).order("release_date") || Movie.order("release_date")
      @hilite_release = 'hilite'
    end
    
    # Variable para debug
      @debug_params = params
      @session_ratings = session[:ratings]
      @session_checks = session[:checks]
      @session_order = session[:order]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
