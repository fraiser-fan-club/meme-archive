class CommandsController < ApplicationController
  def create
    @meme = Meme.find(params[:meme_id])
    @command = @meme.commands.create(command_params)
    redirect_to meme_path(@meme)
  end

  private
    def command_params
      params.require(:command).permit(:name)
    end
end
