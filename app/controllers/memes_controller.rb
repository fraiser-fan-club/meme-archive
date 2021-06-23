require 'uri'
require 'json'

class MemesController < ApplicationController
  include MemesHelper

  before_action :logged_in_user
  before_action :set_meme, only: %i[show edit update destroy]
  before_action :set_embed_url, only: %i[show]

  # GET /memes or /memes.json
  def index
    @memes = Meme.paginate(page: params[:page])
  end

  # GET /memes/1 or /memes/1.json
  def show; end

  # GET /memes/new
  def new
    @meme = Meme.new
    @meme.commands.build
    @meme.tags.build
  end

  # GET /memes/1/edit
  def edit; end

  # POST /memes or /memes.json
  def create
    @meme = Meme.new(meme_params)

    respond_to do |format|
      if @meme.save
        format.html do
          redirect_to @meme, notice: 'Meme was successfully created.'
        end
        format.json { render :show, status: :created, location: @meme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /memes/1 or /memes/1.json
  def update
    @meme.assign_attributes(meme_params)

    respond_to do |format|
      if @meme.save
        format.html do
          redirect_to @meme, notice: 'Meme was successfully updated.'
        end
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
      format.html do
        redirect_to memes_url, notice: 'Meme was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_meme
    @meme = Meme.find(params[:id])
  end

  def set_embed_url
    @embed_url =
      if @meme.source_url.blank?
        'ubFq-wV3Eic'
      else
        get_video_id(URI(@meme.source_url))
      end
  end

  def meme_params
    params
      .require(:meme)
      .permit(
        :name,
        :source_url,
        :start,
        :end,
        :private,
        commands_attributes: %i[id name _destroy],
        tags_attributes: %i[id name _destroy],
      )
  end

  def logged_in_user
    redirect_to new_session_path unless logged_in?
  end
end
