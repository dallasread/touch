class HomesController < ApplicationController
  before_action :set_organization
  before_action :set_folder
  before_action :set_permissions
  before_action :set_home, only: [:show, :edit, :update, :destroy]
  before_filter :redirect_to_folder, unless: Proc.new { @foldership.permits? controller_name, action_type }

  # GET /homes
  # GET /homes.json
  def index
    @does_have_sidebar = true
    @homes = @folder.homes
  end

  # GET /homes/1
  # GET /homes/1.json
  def show
    @does_have_sidebar = true
  end

  # GET /homes/new
  def new
    @does_have_sidebar = true
    @home = Home.new
  end

  # GET /homes/1/edit
  def edit
    @does_have_sidebar = true
  end

  # POST /homes
  # POST /homes.json
  def create
    @does_have_sidebar = true
    @home = @folder.homes.new(home_params)
    @home.creator = @member

    respond_to do |format|
      if @home.save
        format.html { redirect_to folder_homes_path(@org, @folder), notice: 'Home was successfully created.' }
        format.json { render :show, status: :created, location: @home }
      else
        format.html { render :new }
        format.json { render json: @home.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /homes/1
  # PATCH/PUT /homes/1.json
  def update
    @does_have_sidebar = true
    respond_to do |format|
      if @home.update(home_params)
        format.html { redirect_to folder_homes_path(@org, @folder), notice: 'Home was successfully updated.' }
        format.json { render :show, status: :ok, location: @home }
      else
        format.html { render :edit }
        format.json { render json: @home.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /homes/1
  # DELETE /homes/1.json
  def destroy
    @home.destroy
    respond_to do |format|
      format.html { redirect_to folder_homes_path(@org, @folder), notice: 'Home was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_home
      @home = @folder.homes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def home_params
      params.require(:home).permit(:long_address, :address, :city, :province, :postal_code, :beds, :baths, :price, :longitude, :latitude, :data)
    end
end
