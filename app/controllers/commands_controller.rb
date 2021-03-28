class CommandsController < ApplicationController
  def create
    @meme = Meme.find(params[:meme_id])
    @command = @meme.commands.create(command_params)
    redirect_to request.referrer
  end

  def destroy
    @meme = Meme.find(params[:meme_id])
    @command = @meme.commands.find(params[:id])
    @command.destroy
    redirect_to request.referrer
  end

  private
    def command_params
      params.require(:command).permit(:name)
    end
end
