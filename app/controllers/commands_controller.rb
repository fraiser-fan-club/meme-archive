class CommandsController < ApplicationController
  def create
    @meme = Meme.find(params[:meme_id])
    @command = @meme.commands.create(command_params)
    redirect_to edit_meme_path(@meme)
  end

  def destroy
    @meme = Meme.find(params[:meme_id])
    @command = @meme.commands.find(params[:id])
    @command.destroy
    redirect_to edit_meme_path(@meme)
  end

  private
    def command_params
      params.require(:command).permit(:name)
    end
end
