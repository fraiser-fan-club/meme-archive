require 'uri'
require 'json'

class MemesController < ApplicationController
  include MemesHelper

  before_action :logged_in_user
  before_action :set_meme, only: %i[ show edit update destroy ]
  before_action :set_embed_url, only: %i[ show ]

  # GET /memes or /memes.json
  def index
    @memes = Meme.all
  end

  # GET /memes/1 or /memes/1.json
  def show
  end

  # GET /memes/new
  def new
    @meme = Meme.new
    @meme.commands.build
  end

  # GET /memes/1/edit
  def edit
  end

  # POST /memes or /memes.json
  def create
    @meme = Meme.new(meme_params)

    set_video

    respond_to do |format|
      if @meme.save
        format.html { redirect_to @meme, notice: "Meme was successfully created." }
        format.json { render :show, status: :created, location: @meme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /memes/1 or /memes/1.json
  def update
    set_video if  meme_params[:source_url] != @meme.source_url ||
      meme_params[:start] != @meme.start ||
      meme_params[:end] != @meme.end
    
    respond_to do |format|
      if @meme.update(meme_params)
        format.html { redirect_to @meme, notice: "Meme was successfully updated." }
        format.json { render :show, status: :ok, location: @meme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memes/1 or /memes/1.json
  def destroy
    @meme.destroy
    respond_to do |format|
      format.html { redirect_to memes_url, notice: "Meme was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_meme
      @meme = Meme.find(params[:id])
    end

    def set_embed_url
      uri = URI(@meme.source_url)
      params = Hash[URI.decode_www_form(uri.query)]
      @embed_url = params['v']
    end

    def set_video
      uuid = SecureRandom.uuid
      path = "./tmp/#{uuid}.mp3"
      metadata = `node ./lib/archiver.mjs #{meme_params[:source_url]} #{meme_params[:start]} #{meme_params[:end]} #{path}`
      metadata = JSON.parse(metadata, {symbolize_names: true})
      @meme.duration = durationToSecs(metadata[:duration])
      @meme.loudness_i = metadata[:loudness][:i]
      @meme.loudness_lra = metadata[:loudness][:lra]
      @meme.loudness_tp = metadata[:loudness][:tp]
      @meme.loudness_thresh = metadata[:loudness][:thresh]
      if @meme.audio.attached?
        @meme.audio.purge
      end
      @meme.audio.attach(io: File.open(path), filename: "#{@meme.name}.mp3")
      File.delete(path)
      File.delete('./tmp/testdata')
    end

    def meme_params
      params.require(:meme).permit(:name, :source_url, :start, :end, :private, commands_attributes: [:id, :name, :_destroy])
    end

    def logged_in_user 
      unless logged_in?
        redirect_to new_session_path
      end
    end
end
