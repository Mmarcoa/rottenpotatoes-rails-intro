class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  
  def checkboxes(all_ratings, checked)
    @checks = []
    all_ratings.each do |rating|
      if checked.include?(rating)
        @checks << 'checked'
      else
        @checks << nil
      end  
    end
    return @checks    
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.pluck(:rating).uniq
    # params completo?
    if params[:order] && params[:ratings]
      # Ordenar y filtrar con params completo @movies
      @movies = Movie.where(rating: params[:ratings].keys).order(params[:order])
      # Control de 'hilite'
      params[:order] == 'title' ? @hilite_title = 'hilite' : @hilite_release = 'hilite'
      # Colocar en una función, control de checkboxes @checks
      @checks = checkboxes(@all_ratings, params[:ratings].keys)

    elsif params[:order] && session[:ratings]
      session[:order] = params[:order]
      params[:ratings] = session[:ratings]
      if flash[:notice]
        flash.keep
      end
      redirect_to movies_path(params)
      
    elsif params[:ratings] && session[:order]
      session[:ratings] = params[:ratings]
      params[:order] = session[:order]
      if flash[:notice]
        flash.keep
      end
      redirect_to movies_path(params)        
      
    elsif (!params[:ratings]) && (!params[:order]) && (session[:ratings] || session[:order])
      params[:ratings] = session[:ratings]
      params[:order] = session[:order]
      if flash[:notice]
        flash.keep
      end
      redirect_to movies_path(params)      
          
    elsif params[:ratings]
      session[:ratings] = params[:ratings]
      @checked_ratings = params[:ratings].keys
      @movies = Movie.where(rating: params[:ratings].keys)
      @checks = checkboxes(@all_ratings, params[:ratings].keys)

    elsif params[:order] == "title"
      session[:order] = 'title'
      @movies = Movie.order("lower(title)")
      @hilite_title = 'hilite'
      @checks = ['checked']*@all_ratings.size

    elsif params[:order] == 'release_date'
      session[:order] = 'release_date'
      @movies = Movie.order("release_date")
      @hilite_release = 'hilite'      
      @checks = ['checked']*@all_ratings.size
           
    else
      # Movie.all
      @movies = Movie.all
      @checks = ['checked']*@all_ratings.size
    end
    
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
