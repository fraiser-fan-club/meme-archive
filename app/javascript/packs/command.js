(function () {
  const form = document.getElementById("meme-form");
  const button = document.getElementById("add-command");
  const commands = button.parentNode;
  button.addEventListener("click", () => {
    const epoch = Date.now();
    const text = document.createElement("input");
    text.type = "text";
    text.value = "";
    text.name = `meme[commands_attributes][${epoch}][name]`;
    text.id = `meme_commands_attributes_${epoch}_name`;
    commands.insertBefore(text, button);
    const close = document.createElement("div");
    close.setAttribute("class", "gg-close close-btn");
    commands.insertBefore(close, button);
    const br = document.createElement("br");
    commands.insertBefore(br, button);
    close.addEventListener("click", () => {
      commands.removeChild(br);
      commands.removeChild(close);
      commands.removeChild(text);
    });
  });
})();
